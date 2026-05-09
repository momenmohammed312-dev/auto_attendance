import 'package:local_auth/local_auth.dart';
import 'package:flutter/foundation.dart';

/// BiometricService
///
/// Wrapper around local_auth for fingerprint/face authentication
/// Handles all biometric operations in one place
class BiometricService {
  static final BiometricService _instance = BiometricService._internal();
  factory BiometricService() => _instance;
  BiometricService._internal();

  final LocalAuthentication _auth = LocalAuthentication();

  /// Check if device supports biometric authentication
  Future<bool> canCheckBiometrics() async {
    return await _auth.canCheckBiometrics;
  }

  /// Check if the device supports any kind of local authentication.
  ///
  /// This can be true even when `canCheckBiometrics` is false (e.g. the user
  /// didn't enroll fingerprints/face yet). In that case, we may still allow
  /// device credentials (PIN/Pattern/Password) if the caller enables fallback.
  Future<bool> isDeviceSupported() async {
    return await _auth.isDeviceSupported();
  }

  /// Get list of available biometric types
  /// Returns: [BiometricType.fingerprint, BiometricType.face, ...]
  Future<List<BiometricType>> getAvailableBiometrics() async {
    return await _auth.getAvailableBiometrics();
  }

  /// Authenticate with biometric (fingerprint or face)
  ///
  /// Parameters:
  /// - [reason]: Message shown to user during auth
  /// - [allowPinFallback]: If true, allows device PIN as backup
  ///
  /// Returns: true if authenticated, false otherwise
  Future<bool> authenticate({
    String reason = 'Authenticate to continue',
    bool allowPinFallback = false,
  }) async {
    try {
      return await _auth.authenticate(
        localizedReason: reason,
        // Platform-specific messages (Android/iOS) require adding extra packages
        // like `local_auth_android` / `local_auth_ios`.
        // Since the project currently depends only on `local_auth`, we keep this
        // empty so the OS shows its default biometric messages.
        authMessages: const [],
        options: AuthenticationOptions(
          biometricOnly: !allowPinFallback, // true = بصمة بس، false = PIN مسموح
          stickyAuth: true, // يفضل شغال لو الموبايل اتقفل
          sensitiveTransaction: true, // transaction حساسة
        ),
      );
    } catch (e) {
      // Helpful for real-device debugging: if auth fails due to missing
      // enrollment, lockout, or configuration, we can see the reason in logs.
      debugPrint('Biometric auth error: $e');
      return false;
    }
  }
}

// Global instance
final biometricService = BiometricService();
