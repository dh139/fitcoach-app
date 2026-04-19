import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../features/auth/models/user_model.dart';
import '../../../../shared/widgets/fc_button.dart';
import '../../../../shared/widgets/fc_text_field.dart';
import '../../providers/profile_provider.dart';

class EditProfileSheet extends ConsumerStatefulWidget {
  final UserModel user;

  const EditProfileSheet({super.key, required this.user});

  static Future<void> show(
    BuildContext context,
    UserModel user,
  ) => showModalBottomSheet(
    context:            context,
    isScrollControlled: true,
    backgroundColor:    Colors.transparent,
    builder: (_) => ProviderScope(
      parent: ProviderScope.containerOf(context),
      child:  EditProfileSheet(user: user),
    ),
  );

  @override
  ConsumerState<EditProfileSheet> createState() =>
      _EditProfileSheetState();
}

class _EditProfileSheetState extends ConsumerState<EditProfileSheet> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _weightCtrl;
  late final TextEditingController _heightCtrl;
  late final TextEditingController _ageCtrl;

  late String _gender;
  late String _goal;
  late String _activity;

  static const _goals = [
    (value: 'lose_weight',       label: 'Lose weight'),
    (value: 'build_muscle',      label: 'Build muscle'),
    (value: 'improve_endurance', label: 'Endurance'),
    (value: 'stay_fit',          label: 'Stay fit'),
    (value: 'gain_weight',       label: 'Gain weight'),
  ];

  static const _activities = [
    (value: 'sedentary',   label: 'Sedentary'),
    (value: 'light',       label: 'Light'),
    (value: 'moderate',    label: 'Moderate'),
    (value: 'active',      label: 'Active'),
    (value: 'very_active', label: 'Very active'),
  ];

  @override
  void initState() {
    super.initState();
    final u   = widget.user;
    _nameCtrl   = TextEditingController(text: u.name);
    _weightCtrl = TextEditingController(
        text: u.weight != null ? '${u.weight}' : '');
    _heightCtrl = TextEditingController(
        text: u.height != null ? '${u.height}' : '');
    _ageCtrl    = TextEditingController(
        text: u.age    != null ? '${u.age}'    : '');
    _gender   = u.gender       ?? 'male';
    _goal     = u.fitnessGoal;
    _activity = u.activityLevel;
  }

  @override
  void dispose() {
    _nameCtrl.dispose(); _weightCtrl.dispose();
    _heightCtrl.dispose(); _ageCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final data = <String, dynamic>{
      'name':          _nameCtrl.text.trim(),
      'gender':        _gender,
      'fitnessGoal':   _goal,
      'activityLevel': _activity,
      if (_ageCtrl.text.isNotEmpty)
        'age':    int.tryParse(_ageCtrl.text),
      if (_weightCtrl.text.isNotEmpty)
        'weight': double.tryParse(_weightCtrl.text),
      if (_heightCtrl.text.isNotEmpty)
        'height': double.tryParse(_heightCtrl.text),
    };
    data.removeWhere((_, v) => v == null);

    final ok = await ref.read(profileEditProvider.notifier).save(data);
    if (ok && mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final saving = ref.watch(
        profileEditProvider.select((s) => s.saving));
    final error  = ref.watch(
        profileEditProvider.select((s) => s.error));
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      padding: EdgeInsets.only(bottom: bottom),
      decoration: const BoxDecoration(
        color:        AppColors.surface1,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(children: [
        // Handle
        Container(
          margin: const EdgeInsets.only(top: 10, bottom: 4),
          width: 40, height: 4,
          decoration: BoxDecoration(
            color:        AppColors.border3,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: 20, vertical: 10),
          child: Row(children: [
            const Text('Edit profile', style: TextStyle(
              fontFamily:    'Inter',
              fontSize:      17,
              fontWeight:    FontWeight.w700,
              color:         AppColors.textPrimary,
              letterSpacing: -0.3,
            )),
            const Spacer(),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Icon(Icons.close_rounded,
                  color: AppColors.textTertiary, size: 22),
            ),
          ]),
        ),
        const Divider(height: 1, color: AppColors.border2),

        // Form
        Expanded(child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (error != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.dangerDim,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: AppColors.dangerBorder, width: 0.5),
                  ),
                  child: Text(error, style: const TextStyle(
                    fontFamily: 'Inter', fontSize: 12,
                    color: Color(0xFFFF8888),
                  )),
                ),
                const SizedBox(height: 14),
              ],

              // Name
              _Label('Full name'),
              FCTextField(
                hint:       'Your name',
                controller: _nameCtrl,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 14),

              // Age / Weight / Height
              Row(children: [
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Label('Age'),
                    FCTextField(
                      hint:        '—',
                      controller:  _ageCtrl,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                    ),
                  ],
                )),
                const SizedBox(width: 10),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Label('Weight (kg)'),
                    FCTextField(
                      hint:        '—',
                      controller:  _weightCtrl,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                      textInputAction: TextInputAction.next,
                    ),
                  ],
                )),
                const SizedBox(width: 10),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Label('Height (cm)'),
                    FCTextField(
                      hint:        '—',
                      controller:  _heightCtrl,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.done,
                    ),
                  ],
                )),
              ]),
              const SizedBox(height: 14),

              // Gender
              _Label('Gender'),
              const SizedBox(height: 8),
              Row(children: ['male', 'female', 'other'].map((g) {
                final sel = _gender == g;
                return Expanded(child: GestureDetector(
                  onTap: () => setState(() => _gender = g),
                  child: Container(
                    margin: EdgeInsets.only(
                        right: g != 'other' ? 8 : 0),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: sel ? AppColors.lime : AppColors.surface2,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: sel ? AppColors.lime : AppColors.border3,
                        width: 0.5,
                      ),
                    ),
                    child: Text(
                      g[0].toUpperCase() + g.substring(1),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Inter', fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: sel ? AppColors.bg : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ));
              }).toList()),
              const SizedBox(height: 14),

              // Fitness goal
              _Label('Fitness goal'),
              const SizedBox(height: 8),
              GridView.count(
                crossAxisCount:  2,
                shrinkWrap:      true,
                physics:         const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 8,
                mainAxisSpacing:  8,
                childAspectRatio: 3.5,
                children: _goals.map((g) {
                  final sel = _goal == g.value;
                  return GestureDetector(
                    onTap: () => setState(() => _goal = g.value),
                    child: Container(
                      decoration: BoxDecoration(
                        color: sel
                            ? AppColors.limeDim : AppColors.surface2,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: sel
                              ? AppColors.limeBorder : AppColors.border3,
                          width: sel ? 1 : 0.5,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(g.label, style: TextStyle(
                        fontFamily: 'Inter', fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: sel
                            ? AppColors.lime : AppColors.textSecondary,
                      )),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 14),

              // Activity level
              _Label('Activity level'),
              const SizedBox(height: 8),
              Column(children: _activities.map((a) {
                final sel = _activity == a.value;
                return GestureDetector(
                  onTap: () => setState(() => _activity = a.value),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 7),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 11),
                    decoration: BoxDecoration(
                      color: sel
                          ? AppColors.limeDim : AppColors.surface2,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: sel
                            ? AppColors.limeBorder : AppColors.border3,
                        width: sel ? 1 : 0.5,
                      ),
                    ),
                    child: Row(children: [
                      Expanded(child: Text(a.label, style: TextStyle(
                        fontFamily: 'Inter', fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: sel
                            ? AppColors.lime : AppColors.textPrimary,
                      ))),
                      if (sel)
                        Container(
                          width: 18, height: 18,
                          decoration: const BoxDecoration(
                            color:  AppColors.lime,
                            shape:  BoxShape.circle,
                          ),
                          child: const Icon(Icons.check_rounded,
                              color: AppColors.bg, size: 11),
                        ),
                    ]),
                  ),
                );
              }).toList()),
              const SizedBox(height: 8),

              FCButton(
                label:     saving ? 'Saving...' : 'Save changes',
                loading:   saving,
                fullWidth: true,
                size:      FCButtonSize.lg,
                onPressed: _save,
              ),
            ],
          ),
        )),
      ]),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(text.toUpperCase(), style: const TextStyle(
      fontFamily: 'Inter', fontSize: 9, fontWeight: FontWeight.w700,
      color: AppColors.textTertiary, letterSpacing: 0.9,
    )),
  );
}