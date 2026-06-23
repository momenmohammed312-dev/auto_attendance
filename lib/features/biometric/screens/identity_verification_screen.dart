import 'dart:async';
import 'dart:math' show cos, sqrt, atan2, pi, sin;
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Biometric Service for real fingerprint/face authentication
import '../../../core/biometric/biometric_service.dart';

// Auth provider for current user ID
import '../../../auth/providers/auth_provider.dart';

// Face recognition API service
import '../data/face_recognition_service.dart';

// Location services for campus verification
import 'package:geolocator/geolocator.dart';

/// Identity Verification Screen
///
/// ============================================================================
/// REAL BIOMETRIC IMPLEMENTATION USING local_auth
/// ============================================================================
/// This screen uses the device's native biometric authentication:
/// - Fingerprint sensor (Android/iOS)
/// - Face ID / Face Recognition (Android/iOS)
/// - Device PIN/Pattern (fallback)
///
/// Powered by: local_auth package + BiometricService
///
/// ============================================================================
/// SUPPORTED BIOMETRIC METHODS:
/// ============================================================================
/// 1. FINGERPRINT - Uses device fingerprint sensor via local_auth
/// 2. FACE ID / FACE RECOGNITION - Uses device face recognition via local_auth
/// 3. DEVICE PIN - Fallback using device PIN/Pattern/Password
///
/// ============================================================================
/// VERIFICATION FLOW:
/// ============================================================================
/// 1. Check if device supports biometric authentication
/// 2. Trigger native biometric prompt (system UI)
/// 3. User authenticates (fingerprint/face/PIN)
/// 4. Verify location (mock - geolocator coming soon)
/// 5. Record attendance and return to dashboard
///
/// ============================================================================
/// FUTURE: AI LIVENESS DETECTION (Anti-Spoofing):
/// ============================================================================
/// Currently uses device built-in biometric security.
/// Future enhancement: Add ML model for liveness detection to prevent:
/// - Photo attacks
/// - Video replay attacks
/// - Mask attacks
///
/// ---
///
/// This screen is the main biometric verification interface for marking attendance.
///
/// Verification Flow:
/// 1. Initial - Shows biometric prompt (fingerprint/face icon)
/// 2. Scanning - Animates while authenticating
/// 3. Success - Attendance recorded, shows confirmation card
/// 4. Error - Shows error message with retry option
///
/// Navigation:
/// - Called from: Dashboard (Attend button) or VerificationMethodsScreen
/// - Goes to: Dashboard (after success)
/// - Arguments: {method: 'fingerprint'|'face'|'pin'}
class IdentityVerificationScreen extends ConsumerStatefulWidget {
  const IdentityVerificationScreen({super.key});

  @override
  ConsumerState<IdentityVerificationScreen> createState() =>
      _IdentityVerificationScreenState();
}

class _IdentityVerificationScreenState extends ConsumerState<IdentityVerificationScreen>
    with TickerProviderStateMixin {
  /// Animation controller for pulse effect on biometric icon
  late AnimationController _pulseController;

  /// Animation controller for rotation effect during scanning
  late AnimationController _rotationController;

  /// Current verification state
  /// 'idle' -> 'scanning' -> 'verifying_location' -> 'success'|'error'
  String _verificationState = 'idle';

  /// Selected biometric method (passed from previous screen)
  String _selectedMethod = 'fingerprint';

  /// Student and session IDs from route arguments / auth state
  String _studentId = '';
  String _subjectName = 'Unknown Subject';

  /// Error message if verification fails
  String? _errorMessage;

  /// Attendance data to be recorded
  Map<String, dynamic>? _attendanceData;

  // ==================== FACE LIVENESS (CAMERA) ====================
  CameraController? _cameraController;
  bool _cameraReady = false;
  bool _startingCamera = false;

  // ==================== FACE RECOGNITION (API) ====================
  final FaceRecognitionService _faceService = FaceRecognitionService();

  // ==================== LOCATION VERIFICATION ====================
  Position? _currentPosition;
  bool _locationReady = false;

  @override
  void initState() {
    super.initState();

    // Initialize pulse animation (slow breathing effect)
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    // Initialize rotation animation (for scanning state)
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    // Get arguments from navigation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments as Map?;
      if (args != null) {
        setState(() {
          _selectedMethod = args['method'] ?? 'fingerprint';
          _studentId = args['studentId']?.toString() ?? '';
          _subjectName = args['subjectName']?.toString() ?? 'Unknown Subject';
        });
      }

      // Fallback: use auth provider if studentId is empty
      if (_studentId.isEmpty) {
        final authUserId = ref.read(currentUserIdProvider);
        if (authUserId != null && authUserId.isNotEmpty) {
          _studentId = authUserId;
        }
      }

      if (_selectedMethod == 'face') {
        _ensureCamera();
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotationController.dispose();

    final controller = _cameraController;
    _cameraController = null;
    _cameraReady = false;
    _locationReady = false;
    if (controller != null) {
      controller.dispose().catchError((_) {});
    }

    super.dispose();
  }

  /// Starts the biometric verification process
  ///
  /// Uses BiometricService to authenticate with device biometrics.
  ///
  /// Flow:
  /// 1. Check device supports biometric (isDeviceSupported)
  /// 2. Trigger biometric prompt (authenticate with allowPinFallback)
  /// 3. On success: verify location, record attendance
  /// 4. On failure: show error with retry option
  ///
  /// Called when user taps "Start Verification" button
  Future<void> _startVerification() async {
    setState(() {
      _verificationState = 'scanning';
      _errorMessage = null;
    });

    // Start rotation animation
    _rotationController.repeat();

    if (_selectedMethod == 'face') {
      // Step 1: Ensure camera is ready
      final bool ready = await _ensureCamera();
      if (!ready) {
        _showError('Camera is not available. Please try again.');
        return;
      }
      if (!mounted) return;

      // Step 2: Capture actual image from camera
      setState(() {
        _verificationState = 'scanning';
      });
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;

      XFile capturedImage;
      try {
        capturedImage = await _cameraController!.takePicture();
      } catch (e) {
        _showError('Failed to capture image. Please try again.');
        return;
      }
      if (!mounted) return;
      final Uint8List imageBytes = await capturedImage.readAsBytes();
      if (!mounted) return;

      // Step 3: Send to ML API — attendance check-in (does detect + liveness + recognize in one call)
      setState(() {
        _verificationState = 'verifying_location';
      });

      // Resolve studentId: prefer route args, fallback to auth provider
      final effectiveStudentId = _studentId.isNotEmpty
          ? _studentId
          : (ref.read(currentUserIdProvider) ?? '');
      debugPrint('IdentityVerify: effectiveStudentId=$effectiveStudentId (from _studentId=$_studentId)');

      if (effectiveStudentId.isEmpty) {
        _showError('Student ID not found. Please login again.');
        return;
      }

      final checkInResult = await _faceService.attendanceCheckIn(
        employeeId: effectiveStudentId,
        imageBytes: imageBytes,
      );
      if (!mounted) return;

      if (!checkInResult.success) {
        _showError(checkInResult.errorMessage ?? 'Face not recognized. Attendance not recorded.');
        return;
      }

      // Step 4: Location verification
      await _initializeMap();
      if (!mounted) return;
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;

      final bool locationValid = await _verifyLocation();
      if (!locationValid) {
        _showError('You must be on campus to mark attendance.');
        return;
      }

      // Step 5: Record attendance
      setState(() {
        _verificationState = 'recording';
      });

      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;

      setState(() {
        _verificationState = 'success';
        _attendanceData = {
          'subject': _subjectName,
          'time': _getCurrentTime(),
          'date': DateTime.now().toString(),
          'verified': true,
          'method': 'face',
          'status': checkInResult.status,
          'employee_id': checkInResult.employeeId,
        };
      });

      _rotationController.stop();
      return;
    }

    // ============================================================================
    // STEP 1: Check device supports biometric authentication
    // ============================================================================
    final bool deviceSupported = await biometricService.isDeviceSupported();
    debugPrint('IdentityVerify: deviceSupported=$deviceSupported');
    if (!mounted) return;

    if (!deviceSupported) {
      _showError('Biometric authentication is not supported on this device.');
      return;
    }

    // ============================================================================
    // STEP 2: Start REAL biometric authentication using local_auth
    // ============================================================================
    final bool biometricSuccess = await biometricService.authenticate(
      reason: 'Verify your identity to mark attendance',
      allowPinFallback: true,
    );
    if (!mounted) return;

    debugPrint('IdentityVerify: biometricSuccess=$biometricSuccess');

    if (!biometricSuccess) {
      _showError('Biometric verification failed. Please try again.');
      return;
    }

    // Step 2: Location verification with map
    setState(() {
      _verificationState = 'verifying_location';
    });

    // Initialize map and get current location
    await _initializeMap();
    if (!mounted) return;

    // Wait a moment to show the map
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final bool locationValid = await _verifyLocation();

    if (!locationValid) {
      _showError('You must be on campus to mark attendance.');
      return;
    }

    // Step 3: Record attendance
    setState(() {
      _verificationState = 'recording';
    });

    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;

    // Success!
    setState(() {
      _verificationState = 'success';
      _attendanceData = {
        'subject': _subjectName,
        'time': _getCurrentTime(),
        'date': DateTime.now().toString(),
        'verified': true,
      };
    });

    // Stop rotation animation
    _rotationController.stop();
  }

  // ==================== FACE LIVENESS HELPERS ====================

  Future<bool> _ensureCamera() async {
    if (_cameraReady) return true;
    if (_startingCamera) return false;
    _startingCamera = true;

    try {
      final List<CameraDescription> cameras = await availableCameras();
      if (cameras.isEmpty) {
        _startingCamera = false;
        return false;
      }

      CameraDescription? front;
      for (final cam in cameras) {
        if (cam.lensDirection == CameraLensDirection.front) {
          front = cam;
          break;
        }
      }

      final selectedCamera = front ?? cameras.first;
      final controller = CameraController(
        selectedCamera,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.unknown,
      );

      await controller.initialize();
      if (!mounted) {
        await controller.dispose();
        _startingCamera = false;
        return false;
      }

      await _cameraController?.dispose();
      _cameraController = controller;

      setState(() {
        _cameraReady = true;
      });

      _startingCamera = false;
      return true;
    } catch (e) {
      debugPrint('FaceCamera init error: $e');
      _startingCamera = false;
      return false;
    }
  }

  /// Initializes the map and gets current location
  Future<void> _initializeMap() async {
    try {
      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      _currentPosition = position;

      // Location verification complete
      _locationReady = true;

      setState(() {
        _locationReady = true;
      });
    } catch (e) {
      debugPrint('Map initialization error: $e');
      _showError('Unable to get location. Please check GPS settings.');
    }
  }

  /// Campus coordinates (Cairo University - Giza, Egypt)
  /// Replace with your actual campus location
  static const double _campusLatitude = 30.0131; // خط العرض (Cairo University)
  static const double _campusLongitude = 31.2089; // خط الطول (Cairo University)
  static const double _campusRadiusMeters =
      200.0; // 200 meters campus radius

  /// Verifies the student's location using GPS
  ///
  /// Checks if student is within campus boundaries.
  /// Uses Haversine formula to calculate distance.
  ///
  /// Returns: true if on campus, false otherwise
  Future<bool> _verifyLocation() async {
    try {
      // ============================================================================
      // STEP 1: Check location permission
      // ============================================================================
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          debugPrint('Location: Permission denied');
          return false;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        debugPrint('Location: Permission denied forever');
        return false;
      }

      // ============================================================================
      // STEP 2: Check if location service is enabled
      // ============================================================================
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('Location: GPS service disabled');
        return false;
      }

      // ============================================================================
      // STEP 3: Reuse position from _initializeMap or get new one
      // ============================================================================
      Position position;
      if (_currentPosition != null) {
        position = _currentPosition!;
      } else {
        position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        _currentPosition = position;
      }

      debugPrint(
        'Location: Current = ${position.latitude}, ${position.longitude}',
      );
      debugPrint('Location: Campus = $_campusLatitude, $_campusLongitude');

      // ============================================================================
      // STEP 4: Calculate distance using Haversine formula
      // ============================================================================
      double distance = _calculateDistance(
        position.latitude,
        position.longitude,
        _campusLatitude,
        _campusLongitude,
      );

      debugPrint('Location: Distance = ${distance.toStringAsFixed(2)} meters');
      debugPrint('Location: Radius = $_campusRadiusMeters meters');
      debugPrint(
        'Location: Within campus = ${distance <= _campusRadiusMeters}',
      );

      // Check if within campus radius
      return distance <= _campusRadiusMeters;
    } catch (e) {
      debugPrint('Location error: $e');
      return false;
    }
  }

  /// Calculates distance between two coordinates using Haversine formula
  ///
  /// Returns distance in meters
  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadius = 6371000; // Earth radius in meters

    // Convert to radians
    double lat1Rad = lat1 * pi / 180;
    double lat2Rad = lat2 * pi / 180;
    double deltaLat = (lat2 - lat1) * pi / 180;
    double deltaLon = (lon2 - lon1) * pi / 180;

    // Haversine formula
    double a =
        (sin(deltaLat / 2) * sin(deltaLat / 2)) +
        cos(lat1Rad) * cos(lat2Rad) * (sin(deltaLon / 2) * sin(deltaLon / 2));
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }

  /// Shows error state with message
  ///
  /// Stops animations and displays error UI
  /// with option to retry or cancel.
  ///
  /// Parameters:
  /// - [message]: Error message to display
  void _showError(String message) {
    _rotationController.stop();
    setState(() {
      _verificationState = 'error';
      _errorMessage = message;
    });
  }

  /// Cancels verification and returns to dashboard
  ///
  /// Called when user taps Cancel button
  /// Returns without recording attendance
  void _cancelVerification() {
    Navigator.of(context).pop();
  }

  /// Returns to dashboard after successful verification
  ///
  /// Called when user taps "Back to Dashboard" button
  /// Can pass attendance data back to refresh UI
  void _returnToDashboard() {
    Navigator.of(context).pop(_attendanceData);
  }

  /// Gets the icon for current verification method
  IconData get _methodIcon {
    switch (_selectedMethod) {
      case 'face':
        return Icons.face;
      case 'pin':
        return Icons.pin_outlined;
      case 'fingerprint':
      default:
        return Icons.fingerprint;
    }
  }

  /// Gets display text for current state
  ///
  /// Shows different messages based on:
  /// - Current verification state (idle, scanning, etc.)
  /// - Selected biometric method (face vs fingerprint)
  String get _statusText {
    switch (_verificationState) {
      case 'idle':
        // Different prompt based on selected method
        if (_selectedMethod == 'face') {
          return 'Look at the camera';
        } else if (_selectedMethod == 'pin') {
          return 'Enter your PIN';
        } else {
          return 'Place your finger';
        }
      case 'scanning':
        return _selectedMethod == 'face' ? 'Scanning face...' : 'Scanning...';
      case 'verifying_location':
        return 'Verifying location...';
      case 'recording':
        return 'Recording attendance...';
      case 'success':
        return 'Attendance Recorded!';
      case 'error':
        return 'Verification Failed';
      default:
        return 'Verifying...';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Verify Identity'),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        titleTextStyle: const TextStyle(
          color: Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        actions: [
          // Cancel button in app bar
          if (_verificationState != 'success')
            TextButton(
              onPressed: _cancelVerification,
              child: const Text('Cancel', style: TextStyle(color: Colors.red)),
            ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: _buildContent(),
        ),
      ),
    );
  }

  /// Builds content based on verification state
  Widget _buildContent() {
    switch (_verificationState) {
      case 'success':
        return _buildSuccessContent();
      case 'error':
        return _buildErrorContent();
      default:
        return _buildScanningContent();
    }
  }

  /// Builds the scanning/verification content
  ///
  /// Shows animated biometric icon with status text
  /// and progress indicators
  Widget _buildScanningContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (_verificationState == 'verifying_location')
          _buildLocationMapCard()
        else if (_selectedMethod == 'face')
          _buildFaceCameraCard()
        else
          // Animated biometric icon
          SizedBox(
            width: 200,
            height: 200,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Outer rotating ring (shows during scanning)
                if (_verificationState == 'scanning')
                  RotationTransition(
                    turns: _rotationController,
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF2E5BFF),
                          width: 4,
                        ),
                      ),
                    ),
                  ),

                // Pulse effect ring
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    return Container(
                      width: 160 + (_pulseController.value * 20),
                      height: 160 + (_pulseController.value * 20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2E5BFF).withValues(
                          alpha: 0.1 - (_pulseController.value * 0.05),
                        ),
                        shape: BoxShape.circle,
                      ),
                    );
                  },
                ),

                // Main icon container
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2E5BFF), Color(0xFF1E3FAF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2E5BFF).withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Icon(_methodIcon, size: 60, color: Colors.white),
                ),
              ],
            ),
          ),

        const SizedBox(height: 48),

        // Biometric prompt indicator
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF2E5BFF).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF2E5BFF)),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.verified_user, color: Color(0xFF2E5BFF), size: 16),
              SizedBox(width: 6),
              Text(
                'SECURE VERIFICATION',
                style: TextStyle(
                  color: Color(0xFF2E5BFF),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Status text
        Text(
          _statusText,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),

        const SizedBox(height: 16),

        // Subtitle with current step info
        Text(
          _getSubtitleText(),
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black54,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 48),

        // Progress indicator
        if (_verificationState != 'idle')
          SizedBox(
            width: 200,
            child: LinearProgressIndicator(
              backgroundColor: Colors.grey.withValues(alpha: 0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF2E5BFF),
              ),
            ),
          ),

        const Spacer(),

        // Manual trigger button (for testing)
        if (_verificationState == 'idle')
          ElevatedButton.icon(
            onPressed: _startVerification,
            icon: const Icon(Icons.fingerprint),
            label: const Text('Start Verification'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E5BFF),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildLocationMapCard() {
    return Column(
      children: [
        SizedBox(
          width: 320,
          height: 320,
          child: Stack(
            alignment: Alignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  color: Colors.grey.withValues(alpha: 0.1),
                  child: _currentPosition != null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.location_on,
                                size: 80,
                                color: Color(0xFF2E5BFF),
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Location Verified',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2E5BFF),
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Within campus area',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        )
                      : const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(
                                color: Color(0xFF2E5BFF),
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Getting your location...',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
              ),

              // Location verification overlay
              if (_locationReady)
                IgnorePointer(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.location_on,
                          color: Color(0xFF2E5BFF),
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Verifying Location',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2E5BFF),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF2E5BFF).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF2E5BFF)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.map_outlined,
                color: Color(0xFF2E5BFF),
                size: 16,
              ),
              const SizedBox(width: 6),
              const Text(
                'LOCATION VERIFICATION',
                style: TextStyle(
                  color: Color(0xFF2E5BFF),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFaceCameraCard() {
    final controller = _cameraController;

    return Column(
      children: [
        SizedBox(
          width: 260,
          height: 260,
          child: Stack(
            alignment: Alignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  color: Colors.black12,
                  child: (controller != null && _cameraReady)
                      ? CameraPreview(controller)
                      : const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF2E5BFF),
                          ),
                        ),
                ),
              ),

              // Corner brackets overlay
              IgnorePointer(
                child: CustomPaint(
                  size: const Size(260, 260),
                  painter: _CornerFramePainter(color: const Color(0xFF2E5BFF)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        if (_verificationState == 'scanning')
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Text(
              'Camera ready - verifying identity...',
              style: const TextStyle(fontSize: 12, color: Colors.black87),
            ),
          ),
      ],
    );
  }

  /// Gets subtitle text based on current state and method
  ///
  /// Returns appropriate instruction text for:
  /// - Face recognition: Camera/position instructions
  /// - Fingerprint: Sensor instructions
  /// - PIN: Device prompt instructions
  String _getSubtitleText() {
    switch (_verificationState) {
      case 'idle':
        if (_selectedMethod == 'face') {
          return 'Position your face in front of the camera to verify identity';
        } else if (_selectedMethod == 'pin') {
          return 'Use your device PIN to verify and mark attendance';
        } else {
          return 'Touch the fingerprint sensor to verify your identity';
        }
      case 'scanning':
        if (_selectedMethod == 'face') {
          return 'Follow the on-screen steps to confirm it\'s really you';
        } else if (_selectedMethod == 'pin') {
          return 'Enter PIN on device prompt...';
        } else {
          return 'Keep your finger on the sensor...';
        }
      case 'verifying_location':
        return 'Showing your location and campus area on map...';
      case 'recording':
        return 'Saving your attendance record...';
      default:
        return '';
    }
  }

  /// Builds the success content
  ///
  /// Shows success animation and attendance confirmation
  Widget _buildSuccessContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Success icon with animation
        Container(
          width: 150,
          height: 150,
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check_circle, size: 80, color: Colors.green),
        ),

        const SizedBox(height: 40),

        // Success title
        const Text(
          'Attendance Recorded!',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),

        const SizedBox(height: 24),

        // Attendance details card
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.green.withValues(alpha: 0.2)),
          ),
          child: Column(
            children: [
              _buildDetailRow(Icons.book, 'Subject', _subjectName),
              const Divider(height: 24),
              _buildDetailRow(Icons.access_time, 'Time', _getCurrentTime()),
              const Divider(height: 24),
              _buildDetailRow(Icons.calendar_today, 'Date', _getCurrentDate()),
              const Divider(height: 24),
              _buildDetailRow(Icons.verified, 'Status', 'Verified ✓'),
            ],
          ),
        ),

        const Spacer(),

        // Back to dashboard button
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _returnToDashboard,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Back to Dashboard',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  /// Builds the error content
  ///
  /// Shows error message with retry option
  Widget _buildErrorContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Error icon
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: Colors.red.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.error_outline, size: 60, color: Colors.red),
        ),

        const SizedBox(height: 32),

        // Error title
        const Text(
          'Verification Failed',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),

        const SizedBox(height: 16),

        // Error message
        Text(
          _errorMessage ?? 'Something went wrong. Please try again.',
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black54,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 48),

        // Retry button
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _verificationState = 'idle';
                _errorMessage = null;
              });
            },
            icon: const Icon(Icons.refresh),
            label: const Text(
              'Try Again',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E5BFF),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Cancel button
        TextButton(
          onPressed: _cancelVerification,
          child: const Text(
            'Cancel',
            style: TextStyle(color: Colors.black54, fontSize: 16),
          ),
        ),
      ],
    );
  }

  /// Builds a detail row for the success card
  ///
  /// Parameters:
  /// - [icon]: Icon to display
  /// - [label]: Label text (e.g., "Subject")
  /// - [value]: Value text (e.g., "AI")
  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.green),
        const SizedBox(width: 12),
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Colors.black54),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  /// Gets current date formatted
  String _getCurrentDate() {
    final now = DateTime.now();
    return '${now.day}/${now.month}/${now.year}';
  }

  /// Gets current time formatted (e.g., "2:45 PM")
  String _getCurrentTime() {
    final now = DateTime.now();
    final hour = now.hour > 12
        ? now.hour - 12
        : (now.hour == 0 ? 12 : now.hour);
    final minute = now.minute.toString().padLeft(2, '0');
    final period = now.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }
}

class _CornerFramePainter extends CustomPainter {
  const _CornerFramePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const double cornerLen = 26;
    const double radius = 18;

    // Top-left
    canvas.drawLine(
      const Offset(radius, 0),
      Offset(radius + cornerLen, 0),
      paint,
    );
    canvas.drawLine(
      const Offset(0, radius),
      Offset(0, radius + cornerLen),
      paint,
    );

    // Top-right
    canvas.drawLine(
      Offset(size.width - radius, 0),
      Offset(size.width - radius - cornerLen, 0),
      paint,
    );
    canvas.drawLine(
      Offset(size.width, radius),
      Offset(size.width, radius + cornerLen),
      paint,
    );

    // Bottom-left
    canvas.drawLine(
      Offset(0, size.height - radius),
      Offset(0, size.height - radius - cornerLen),
      paint,
    );
    canvas.drawLine(
      Offset(radius, size.height),
      Offset(radius + cornerLen, size.height),
      paint,
    );

    // Bottom-right
    canvas.drawLine(
      Offset(size.width, size.height - radius),
      Offset(size.width, size.height - radius - cornerLen),
      paint,
    );
    canvas.drawLine(
      Offset(size.width - radius, size.height),
      Offset(size.width - radius - cornerLen, size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _CornerFramePainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
