const axios  = require('axios');
const Groq   = require('groq-sdk');

const groq = new Groq({ apiKey: process.env.GROQ_API_KEY });

// ─── Open Food Facts search (free, no key needed) ─────────────────────────────
const searchFood = async (query) => {
  try {
    const { data } = await axios.get(
      'https://world.openfoodfacts.org/cgi/search.pl',
      {
        params: {
          search_terms:       query,
          search_simple:      1,
          action:             'process',
          json:               1,
          page_size:          10,
          fields: 'product_name,brands,nutriments,serving_size,image_small_url',
        },
        timeout: 8000,
      }
    );

    if (!data.products?.length) return [];

    return data.products
      .filter((p) => p.product_name && p.nutriments)
      .slice(0, 8)
      .map((p) => {
        const n = p.nutriments;
        // Open Food Facts stores per 100g — convert to per-serving
        const servingG = parseFloat(p.serving_size) || 100;
        const factor   = servingG / 100;

        return {
          name:         p.product_name,
          brand:        p.brands || '',
          servingSize:  p.serving_size || '100g',
          imageUrl:     p.image_small_url || '',
          per100g: {
            calories: Math.round(n['energy-kcal_100g'] || n['energy-kcal'] || 0),
            protein:  Math.round((n.proteins_100g   || 0) * 10) / 10,
            carbs:    Math.round((n.carbohydrates_100g || 0) * 10) / 10,
            fat:      Math.round((n.fat_100g        || 0) * 10) / 10,
            fiber:    Math.round((n.fiber_100g      || 0) * 10) / 10,
          },
          perServing: {
            calories: Math.round((n['energy-kcal_100g'] || 0) * factor),
            protein:  Math.round((n.proteins_100g   || 0) * factor * 10) / 10,
            carbs:    Math.round((n.carbohydrates_100g || 0) * factor * 10) / 10,
            fat:      Math.round((n.fat_100g        || 0) * factor * 10) / 10,
            fiber:    Math.round((n.fiber_100g      || 0) * factor * 10) / 10,
          },
        };
      });
  } catch (err) {
    console.error('Open Food Facts search error:', err.message);
    return [];
  }
};

// ─── Fallback common Indian foods (when API misses) ───────────────────────────
const INDIAN_FOODS = [
  { name: 'Dal Tadka',          calories: 180, protein: 9,  carbs: 28, fat: 4,  fiber: 6,  unit: 'bowl (200ml)' },
  { name: 'Chapati / Roti',     calories: 104, protein: 3,  carbs: 20, fat: 2,  fiber: 2,  unit: '1 piece (40g)' },
  { name: 'Basmati Rice',       calories: 210, protein: 4,  carbs: 46, fat: 0,  fiber: 1,  unit: 'cup cooked' },
  { name: 'Paneer',             calories: 265, protein: 18, carbs: 3,  fat: 20, fiber: 0,  unit: '100g' },
  { name: 'Chole',              calories: 270, protein: 14, carbs: 40, fat: 6,  fiber: 12, unit: 'bowl (200g)' },
  { name: 'Aloo Paratha',       calories: 300, protein: 6,  carbs: 45, fat: 11, fiber: 3,  unit: '1 piece' },
  { name: 'Samosa',             calories: 262, protein: 4,  carbs: 33, fat: 13, fiber: 2,  unit: '1 piece (100g)' },
  { name: 'Idli',               calories: 39,  protein: 2,  carbs: 8,  fat: 0,  fiber: 1,  unit: '1 piece' },
  { name: 'Dosa',               calories: 168, protein: 4,  carbs: 28, fat: 4,  fiber: 2,  unit: '1 medium' },
  { name: 'Rajma',              calories: 230, protein: 13, carbs: 38, fat: 3,  fiber: 10, unit: 'bowl (200g)' },
  { name: 'Biryani (Chicken)',  calories: 290, protein: 18, carbs: 38, fat: 7,  fiber: 2,  unit: 'plate (250g)' },
  { name: 'Butter Chicken',     calories: 240, protein: 20, carbs: 8,  fat: 14, fiber: 1,  unit: 'bowl (200g)' },
  { name: 'Poha',               calories: 180, protein: 3,  carbs: 36, fat: 3,  fiber: 2,  unit: 'plate (150g)' },
  { name: 'Upma',               calories: 200, protein: 4,  carbs: 35, fat: 5,  fiber: 3,  unit: 'plate (150g)' },
  { name: 'Lassi (Sweet)',       calories: 150, protein: 5,  carbs: 25, fat: 4,  fiber: 0,  unit: 'glass (250ml)' },
  { name: 'Chai with milk',     calories: 80,  protein: 2,  carbs: 12, fat: 2,  fiber: 0,  unit: 'cup (150ml)' },
  { name: 'Egg (boiled)',       calories: 78,  protein: 6,  carbs: 1,  fat: 5,  fiber: 0,  unit: '1 large egg' },
  { name: 'Banana',             calories: 89,  protein: 1,  carbs: 23, fat: 0,  fiber: 3,  unit: '1 medium (118g)' },
  { name: 'Apple',              calories: 72,  protein: 0,  carbs: 19, fat: 0,  fiber: 3,  unit: '1 medium (182g)' },
  { name: 'Almonds',            calories: 164, protein: 6,  carbs: 6,  fat: 14, fiber: 3,  unit: '28g (handful)' },
];

const searchIndianFoods = (query) => {
  const q = query.toLowerCase();
  return INDIAN_FOODS.filter((f) =>
    f.name.toLowerCase().includes(q)
  ).map((f) => ({
    name:       f.name,
    brand:      'Common Indian Food',
    servingSize: f.unit,
    imageUrl:   '',
    perServing: { calories: f.calories, protein: f.protein, carbs: f.carbs, fat: f.fat, fiber: f.fiber },
    per100g:    { calories: f.calories, protein: f.protein, carbs: f.carbs, fat: f.fat, fiber: f.fiber },
  }));
};

// Combined search — tries API first, fills with Indian food fallback
const searchFoodCombined = async (query) => {
  const [apiResults, indianResults] = await Promise.all([
    searchFood(query),
    Promise.resolve(searchIndianFoods(query)),
  ]);

  // Merge — put Indian food matches first if relevant
  const merged = [...indianResults, ...apiResults];
  // Deduplicate by name (case-insensitive)
  const seen = new Set();
  return merged.filter((f) => {
    const key = f.name.toLowerCase();
    if (seen.has(key)) return false;
    seen.add(key);
    return true;
  }).slice(0, 10);
};

// ─── Groq vision photo analysis ─────────────────────────────────────────────
const analyzePhotoWithNvidia = async (base64Image, mimeType = 'image/jpeg', description = '') => {
  try {
    const textPrompt = `Analyze this food image.${description ? ' User described this meal as: "' + description + '".' : ''} Identify every food item visible.
For each item, estimate realistic nutrition values.
Respond ONLY with valid JSON in this exact format, no extra text:
{
  "items": [
    {
      "name": "food name",
      "estimatedQuantity": "portion description e.g. 1 cup, 2 pieces, 150g",
      "calories": 250,
      "protein": 12,
      "carbs": 30,
      "fat": 8,
      "fiber": 3,
      "confidence": "high|medium|low"
    }
  ],
  "totalCalories": 250,
  "notes": "brief note about the meal"
}`;

    const response = await groq.chat.completions.create({
      model: 'meta-llama/llama-4-scout-17b-16e-instruct',
      messages: [
        {
          role: 'user',
          content: [
            { type: 'text', text: textPrompt },
            {
              type: 'image_url',
              image_url: { url: `data:${mimeType};base64,${base64Image}` },
            },
          ],
        },
      ],
      max_tokens: 1024,
      temperature: 0.1,
    });

    const raw = response.choices[0]?.message?.content || '';
    // Strip markdown code fences if present
    const json = raw.replace(/```json\s*/g, '').replace(/```\s*/g, '').trim();
    const parsed = JSON.parse(json);

    return { success: true, ...parsed, rawResponse: raw };
  } catch (err) {
    console.error('Photo analysis error:', err.message);
    return {
      success: false,
      message: 'Photo analysis failed — please try manual entry',
      items: [],
    };
  }
};

module.exports = { searchFoodCombined, analyzePhotoWithNvidia, INDIAN_FOODS };