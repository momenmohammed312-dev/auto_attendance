import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/auth_repository.dart';
import '../data/model/login_request.dart'; // ← مهم
import '../data/model/user_model.dart';
import '../../core/storage/secure_storage.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

class AuthState {
  final UserModel? user;
  final bool isLoading;
  final String? error;

  AuthState({this.user, this.isLoading = false, this.error}); // ← default false

  AuthState copyWith({UserModel? user, bool? isLoading, String? error}) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(AuthState());

  /// Login method with optional Remember Me functionality
  ///
  /// Parameters:
  /// - [email]: User's email address
  /// - [password]: User's password
  /// - [role]: User role ('student' or 'doctor')
  /// - [rememberMe]: If true, saves user data to secure storage for auto-login
  Future<void> login(
    String email,
    String password,
    String role, {
    bool rememberMe = false,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Call API to authenticate user
      final user = await _repository.login(
        LoginRequest(email: email, password: password, role: role),
      );

      // Save to secure storage if remember me is checked
      // This allows auto-login on next app launch
      if (rememberMe) {
        await secureStorage.saveUser(user.toJson());
        await secureStorage.setRememberMe(true);
      }

      state = state.copyWith(user: user, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> logout() async {
    await secureStorage.clearAll(); // امسح كل البيانات المحفوظة
    state = AuthState();
  }

  /// Set user from storage (for biometric login)
  ///
  /// This method is called after successful biometric authentication
  /// It creates a UserModel from stored data without calling the API
  ///
  /// Parameters:
  /// - [userData]: Map containing user data from secure storage
  void setUserFromStorage(Map<String, dynamic> userData) {
    try {
      final user = UserModel.fromJson(userData);
      state = state.copyWith(user: user, isLoading: false, error: null);
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to restore user session: $e',
        isLoading: false,
      );
    }
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(authRepositoryProvider));
});
