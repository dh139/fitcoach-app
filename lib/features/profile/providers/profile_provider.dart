import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_provider.dart';

// Profile editing state — wraps AuthNotifier's updateProfile
class ProfileEditState {
  final bool    saving;
  final bool    success;
  final String? error;

  const ProfileEditState({
    this.saving  = false,
    this.success = false,
    this.error,
  });

  ProfileEditState copyWith({
    bool?   saving,
    bool?   success,
    Object? error = _s,
  }) => ProfileEditState(
    saving:  saving  ?? this.saving,
    success: success ?? this.success,
    error:   error == _s ? this.error : error as String?,
  );
}

const _s = Object();

class ProfileEditNotifier extends StateNotifier<ProfileEditState> {
  final AuthNotifier _auth;

  ProfileEditNotifier(this._auth) : super(const ProfileEditState());

  Future<bool> save(Map<String, dynamic> data) async {
    state = state.copyWith(saving: true, success: false, error: null);
    try {
      await _auth.updateProfile(data);
      state = state.copyWith(saving: false, success: true);
      return true;
    } catch (e) {
      state = state.copyWith(saving: false, error: e.toString());
      return false;
    }
  }

  void reset() => state = const ProfileEditState();
}

final profileEditProvider =
    StateNotifierProvider<ProfileEditNotifier, ProfileEditState>((ref) {
  return ProfileEditNotifier(ref.watch(authProvider.notifier));
});