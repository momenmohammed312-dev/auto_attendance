class ApiEndpoints {
  ApiEndpoints._();

  // ── ML API (Face Recognition) ──
  static const String mlBaseUrl = 'https://hassanhamamsi-ml-api.hf.space';
  static const String mlSecretHeader = 'X-ML-Secret';

  // ML Secret Key — set via --dart-define=ML_SECRET_KEY=your_key
  // Usage: flutter run --dart-define=ML_SECRET_KEY=actual_secret
  static const String mlSecretKey = String.fromEnvironment(
    'ML_SECRET_KEY',
    defaultValue: 'ml-secret-2024-graduation',
  );

  static const String mlHealth = '/health';
  static const String mlDetectFace = '/detect-face';
  static const String mlRegisterFace = '/register-face';
  static const String mlRecognizeFace = '/recognize-face';
  static const String mlLivenessCheck = '/liveness-check';
  static const String mlAttendanceCheckIn = '/attendance/check-in';

  static String mlRegisterFaceById(String employeeId) =>
      '/register-face/$employeeId';
  static String mlAttendanceCheckInById(String employeeId) =>
      '/attendance/check-in/$employeeId';

  // ── Backend API (Dashboard) ──
  static const String backendBaseUrl = 'https://medoedress999-backendapi.hf.space';
}
