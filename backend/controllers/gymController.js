const Gym = require('../models/Gym');
const Membership = require('../models/Membership');
const GymCheckIn = require('../models/GymCheckIn');

// ── OWNER ENDPOINTS ─────────────────────────────────────────────────────────

// POST /api/gyms - Register a new gym (Owner only)
const registerGym = async (req, res) => {
  try {
    if (req.user.role !== 'owner') {
      return res.status(403).json({ success: false, message: 'Forbidden. Owner role required.' });
    }

    const { name, address, description, occupancyLimit } = req.body;
    if (!name || !address) {
      return res.status(400).json({ success: false, message: 'Name and address are required.' });
    }

    const gym = await Gym.create({
      name,
      address,
      description,
      owner: req.user._id,
      occupancyLimit: occupancyLimit || 100,
      plans: [],
      staff: [],
    });

    res.status(201).json({ success: true, gym });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// GET /api/gyms/owner - List gyms registered by the logged-in owner
const getOwnerGyms = async (req, res) => {
  try {
    if (req.user.role !== 'owner') {
      return res.status(403).json({ success: false, message: 'Forbidden. Owner role required.' });
    }

    const gyms = await Gym.find({ owner: req.user._id });
    res.status(200).json({ success: true, gyms });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// PATCH /api/gyms/:id/plans - Add or update plans for a gym
const updateGymPlans = async (req, res) => {
  try {
    if (req.user.role !== 'owner') {
      return res.status(403).json({ success: false, message: 'Forbidden. Owner role required.' });
    }

    const { plans } = req.body;
    if (!plans || !Array.isArray(plans)) {
      return res.status(400).json({ success: false, message: 'Plans array is required.' });
    }

    const gym = await Gym.findOne({ _id: req.params.id, owner: req.user._id });
    if (!gym) {
      return res.status(404).json({ success: false, message: 'Gym not found or unauthorized.' });
    }

    gym.plans = plans.map(p => ({
      name: p.name,
      price: Number(p.price),
      durationDays: Number(p.durationDays),
      roamingEnabled: !!p.roamingEnabled,
    }));

    await gym.save();
    res.status(200).json({ success: true, gym });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// GET /api/gyms/:id/members - View active memberships & checkout logs (Owner only)
const getGymMembers = async (req, res) => {
  try {
    if (req.user.role !== 'owner') {
      return res.status(403).json({ success: false, message: 'Forbidden. Owner role required.' });
    }

    const gym = await Gym.findOne({ _id: req.params.id, owner: req.user._id });
    if (!gym) {
      return res.status(404).json({ success: false, message: 'Gym not found or unauthorized.' });
    }

    const memberships = await Membership.find({ gym: gym._id, status: 'active' }).populate('user', 'name email avatar');
    const checkIns = await GymCheckIn.find({ gym: gym._id, checkOutTime: null }).populate('user', 'name email avatar');

    res.status(200).json({ success: true, memberships, activeCheckIns: checkIns });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// ── USER ENDPOINTS ──────────────────────────────────────────────────────────

// GET /api/gyms - List all gyms
const listGyms = async (req, res) => {
  try {
    const gyms = await Gym.find({});
    res.status(200).json({ success: true, gyms });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// GET /api/gyms/:id - Get specific gym details & plans
const getGymDetails = async (req, res) => {
  try {
    const gym = await Gym.findById(req.params.id);
    if (!gym) {
      return res.status(404).json({ success: false, message: 'Gym not found.' });
    }
    res.status(200).json({ success: true, gym });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// POST /api/gyms/:id/memberships - Buy custom membership plan (Dummy checkout)
const buyMembership = async (req, res) => {
  try {
    const { planName, price, durationDays, roamingEnabled } = req.body;
    if (!planName || !price || !durationDays) {
      return res.status(400).json({ success: false, message: 'Plan details are required.' });
    }

    const gym = await Gym.findById(req.params.id);
    if (!gym) {
      return res.status(404).json({ success: false, message: 'Gym not found.' });
    }

    // Deactivate previous active memberships for this gym/user
    await Membership.updateMany(
      { user: req.user._id, gym: gym._id, status: 'active' },
      { status: 'expired' }
    );

    const startDate = new Date();
    const endDate = new Date();
    endDate.setDate(startDate.getDate() + Number(durationDays));

    const membership = await Membership.create({
      user: req.user._id,
      gym: gym._id,
      planName,
      price: Number(price),
      startDate,
      endDate,
      status: 'active',
      paymentStatus: 'paid', // Dummy checkout defaults to paid
      roamingEnabled: !!roamingEnabled,
    });

    res.status(201).json({ success: true, membership });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// GET /api/gyms/memberships/active - Get active memberships for current user
const getActiveMembership = async (req, res) => {
  try {
    const memberships = await Membership.find({ user: req.user._id, status: 'active' }).populate('gym', 'name address');
    res.status(200).json({ success: true, memberships });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// POST /api/gyms/:id/checkin - QR Check-in
const checkIn = async (req, res) => {
  try {
    const { zone } = req.body;
    const gym = await Gym.findById(req.params.id);
    if (!gym) {
      return res.status(404).json({ success: false, message: 'Gym not found.' });
    }

    // Verify user has active membership at this gym, or a roaming pass
    const hasMembership = await Membership.findOne({
      user: req.user._id,
      status: 'active',
      $or: [{ gym: gym._id }, { roamingEnabled: true }],
    });

    if (!hasMembership) {
      return res.status(403).json({ success: false, message: 'Access denied. Active membership required.' });
    }

    // Check if already checked in
    const activeCheckIn = await GymCheckIn.findOne({ user: req.user._id, checkOutTime: null });
    if (activeCheckIn) {
      return res.status(400).json({ success: false, message: 'Already checked in. Please check out first.' });
    }

    const checkInLog = await GymCheckIn.create({
      user: req.user._id,
      gym: gym._id,
      zone: zone || null,
    });

    res.status(201).json({ success: true, checkIn: checkInLog });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// POST /api/gyms/:id/checkout - QR Check-out
const checkOut = async (req, res) => {
  try {
    const activeCheckIn = await GymCheckIn.findOne({
      user: req.user._id,
      gym: req.params.id,
      checkOutTime: null,
    });

    if (!activeCheckIn) {
      return res.status(400).json({ success: false, message: 'No active check-in session found for this gym.' });
    }

    activeCheckIn.checkOutTime = new Date();
    await activeCheckIn.save();

    res.status(200).json({ success: true, checkOut: activeCheckIn });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

// GET /api/gyms/:id/occupancy - Get current active occupant count
const getOccupancy = async (req, res) => {
  try {
    const liveCount = await GymCheckIn.countDocuments({ gym: req.params.id, checkOutTime: null });
    
    // Aggregation of zone occupancy
    const zones = await GymCheckIn.aggregate([
      { $match: { gym: new require('mongoose').Types.ObjectId(req.params.id), checkOutTime: null } },
      { $group: { _id: '$zone', count: { $sum: 1 } } }
    ]);

    const zoneMap = { cardio: 0, weights: 0, studio: 0 };
    zones.forEach(z => {
      if (z._id && zoneMap[z._id] !== undefined) {
        zoneMap[z._id] = z.count;
      }
    });

    res.status(200).json({
      success: true,
      liveCount,
      zones: zoneMap,
    });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

module.exports = {
  registerGym,
  getOwnerGyms,
  updateGymPlans,
  getGymMembers,
  listGyms,
  getGymDetails,
  buyMembership,
  getActiveMembership,
  checkIn,
  checkOut,
  getOccupancy,
};
