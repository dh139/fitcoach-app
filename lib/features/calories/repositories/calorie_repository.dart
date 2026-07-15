import 'dart:convert';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../models/daily_summary_model.dart';
import '../models/food_log_model.dart';
import '../models/food_search_result.dart';

class CalorieRepository {
  const CalorieRepository();

  // ── Search ──────────────────────────────────────────────────────────────────
  Future<List<FoodSearchResult>> searchFood(String query) async {
    final res = await ApiClient.get(
      ApiEndpoints.calorieSearch,
      params: {'q': query},
    );
    if (res.statusCode == 200 && res.data['success'] == true) {
      final list = res.data['data'] as List<dynamic>;
      return list
          .map((e) => FoodSearchResult.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  // ── Photo analysis ──────────────────────────────────────────────────────────
  Future<PhotoAnalysisResult> analyzePhoto({
    required String base64Image,
    required String mimeType,
    String description = '',
  }) async {
    final res = await ApiClient.post(ApiEndpoints.calorieAnalyze, data: {
      'base64Image': base64Image,
      'mimeType':    mimeType,
      'description': description,
    });
    if (res.statusCode == 200 && res.data['success'] == true) {
      return PhotoAnalysisResult.fromJson(
          res.data['data'] as Map<String, dynamic>);
    }
    return PhotoAnalysisResult(
      success: false,
      items:   [],
      totalCalories: 0,
      notes:   '',
      message: res.data['message'] as String? ?? 'Analysis failed',
    );
  }

  // ── Log food ────────────────────────────────────────────────────────────────
  Future<FoodLogModel> logFood({
    required String name,
    required int    calories,
    String  brand       = '',
    double  quantity    = 1.0,
    String  unit        = 'serving',
    double  protein     = 0,
    double  carbs       = 0,
    double  fat         = 0,
    double  fiber       = 0,
    String  mealType    = 'snack',
    String  source      = 'manual',
    String? loggedDate,
    String  aiAnalysis  = '',
  }) async {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final res   = await ApiClient.post(ApiEndpoints.calorieLog, data: {
      'name':       name,
      'brand':      brand,
      'quantity':   quantity,
      'unit':       unit,
      'calories':   calories,
      'protein':    protein,
      'carbs':      carbs,
      'fat':        fat,
      'fiber':      fiber,
      'mealType':   mealType,
      'source':     source,
      'loggedDate': loggedDate ?? today,
      'aiAnalysis': aiAnalysis,
    });
    if (res.statusCode == 201 && res.data['success'] == true) {
      return FoodLogModel.fromJson(
          res.data['data'] as Map<String, dynamic>);
    }
    throw Exception(res.data['message'] ?? 'Failed to log food');
  }

  // ── Get day log ─────────────────────────────────────────────────────────────
  Future<DailySummaryModel> getDayLog(String date) async {
    final res = await ApiClient.get(
      ApiEndpoints.calorieLog,
      params: {'date': date},
    );
    if (res.statusCode == 200 && res.data['success'] == true) {
      return DailySummaryModel.fromJson(
          res.data['data'] as Map<String, dynamic>);
    }
    throw Exception('Failed to load day log');
  }

  // ── Delete entry ────────────────────────────────────────────────────────────
  Future<void> deleteEntry(String id) async {
    final res = await ApiClient.delete(ApiEndpoints.calorieLogById(id));
    if (res.statusCode != 200 || res.data['success'] != true) {
      throw Exception(res.data['message'] ?? 'Failed to delete entry');
    }
  }

  // ── Weekly summary ──────────────────────────────────────────────────────────
  Future<List<WeeklyDayModel>> getWeeklySummary() async {
    final res = await ApiClient.get(ApiEndpoints.calorieWeekly);
    if (res.statusCode == 200 && res.data['success'] == true) {
      final list = res.data['data'] as List<dynamic>;
      return list
          .map((e) => WeeklyDayModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }
}