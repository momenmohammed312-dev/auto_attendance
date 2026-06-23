import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/providers/auth_provider.dart';
import '../data/face_recognition_service.dart';

class BiometricEnrollmentScreen extends ConsumerStatefulWidget {
  const BiometricEnrollmentScreen({super.key});

  @override
  ConsumerState<BiometricEnrollmentScreen> createState() =>
      _BiometricEnrollmentScreenState();
}

class _BiometricEnrollmentScreenState
    extends ConsumerState<BiometricEnrollmentScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  int _currentStep = 0; // 0=intro, 1=camera, 2=processing, 3=success
  bool _isLoading = false;
  String? _errorMessage;

  // Camera
  CameraController? _cameraController;
  bool _cameraReady = false;
  bool _startingCamera = false;

  // Services
  final FaceRecognitionService _faceService = FaceRecognitionService();

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    final controller = _cameraController;
    _cameraController = null;
    _cameraReady = false;
    if (controller != null) {
      controller.dispose().catchError((_) {});
    }
    super.dispose();
  }

  Future<bool> _initCamera() async {
    if (_cameraReady) return true;
    if (_startingCamera) return false;
    _startingCamera = true;

    try {
      final cameras = await availableCameras();
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

      final controller = CameraController(
        front ?? cameras.first,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await controller.initialize();
      if (!mounted) {
        await controller.dispose();
        _startingCamera = false;
        return false;
      }

      await _cameraController?.dispose();
      _cameraController = controller;
      _cameraReady = true;
      _startingCamera = false;
      return true;
    } catch (e) {
      debugPrint('Enrollment camera error: $e');
      _startingCamera = false;
      return false;
    }
  }

  Future<void> _startEnrollment() async {
    setState(() {
      _currentStep = 1;
      _errorMessage = null;
    });

    final ready = await _initCamera();
    if (!ready) {
      setState(() {
        _errorMessage = 'Camera is not available.';
        _currentStep = 0;
      });
    }
  }

  Future<void> _captureAndEnroll() async {
    if (_cameraController == null || !_cameraReady) {
      setState(() {
        _errorMessage = 'Camera is not ready.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _currentStep = 2;
      _errorMessage = null;
    });

    try {
      // Capture image
      final XFile capturedImage = await _cameraController!.takePicture();
      final Uint8List imageBytes = await capturedImage.readAsBytes();

      // Send to ML API for face registration
      final userId = ref.read(currentUserIdProvider) ?? '1';
      final result = await _faceService.registerFace(
        employeeId: userId,
        imageBytes: imageBytes,
      );

      setState(() {
        _isLoading = false;
      });

      if (result.success) {
        setState(() {
          _currentStep = 3;
        });
      } else {
        setState(() {
          _errorMessage = result.errorMessage;
          _currentStep = 1;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Enrollment failed. Please try again.';
        _currentStep = 1;
      });
    }
  }

  void _skipEnrollment() {
    Navigator.of(context).pop();
  }

  void _completeEnrollment() {
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Biometric Setup'),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        titleTextStyle: const TextStyle(
          color: Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: _buildContent(),
        ),
      ),
    );
  }

  Widget _buildContent() {
    switch (_currentStep) {
      case 0:
        return _buildIntroductionStep();
      case 1:
        return _buildCameraStep();
      case 2:
        return _buildProcessingStep();
      case 3:
        return _buildSuccessStep();
      default:
        return _buildIntroductionStep();
    }
  }

  Widget _buildIntroductionStep() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            return Transform.scale(
              scale: 1.0 + (_pulseController.value * 0.1),
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: const Color(0xFF2E5BFF).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.face,
                  size: 60,
                  color: Color(0xFF2E5BFF),
                ),
              ),
            );
          },
        ),

        const SizedBox(height: 40),

        const Text(
          'Set Up Face Recognition',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 16),

        const Text(
          'Register your face to quickly mark attendance. The camera will capture your face and send it securely to our server.',
          style: TextStyle(fontSize: 16, color: Colors.black54, height: 1.5),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 40),

        _buildBenefitItem(Icons.speed, 'Quick', 'Mark attendance in seconds'),
        const SizedBox(height: 16),
        _buildBenefitItem(Icons.security, 'Secure', 'Face data is encrypted on server'),
        const SizedBox(height: 16),
        _buildBenefitItem(Icons.face, 'Accurate', 'AI-powered face matching'),

        const Spacer(),

        if (_errorMessage != null) ...[
          Text(
            _errorMessage!,
            style: const TextStyle(color: Colors.red, fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
        ],

        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _startEnrollment,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E5BFF),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Start Setup',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),

        const SizedBox(height: 16),

        TextButton(
          onPressed: _skipEnrollment,
          child: const Text(
            'Skip for now',
            style: TextStyle(color: Colors.black54, fontSize: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildBenefitItem(IconData icon, String title, String description) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFF2E5BFF).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: const Color(0xFF2E5BFF), size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Text(
                description,
                style: const TextStyle(fontSize: 14, color: Colors.black54),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCameraStep() {
    final controller = _cameraController;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Camera preview
        SizedBox(
          width: 280,
          height: 280,
          child: Stack(
            alignment: Alignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  color: Colors.black12,
                  child: (controller != null && _cameraReady)
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: CameraPreview(controller),
                        )
                      : const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF2E5BFF),
                          ),
                        ),
                ),
              ),

              // Face guide overlay
              IgnorePointer(
                child: CustomPaint(
                  size: const Size(280, 280),
                  painter: _FaceGuidePainter(color: const Color(0xFF2E5BFF)),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        const Text(
          'Position your face in the frame',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),

        const SizedBox(height: 8),

        const Text(
          'Keep a neutral expression and look straight at the camera',
          style: TextStyle(fontSize: 14, color: Colors.black54),
          textAlign: TextAlign.center,
        ),

        if (_errorMessage != null) ...[
          const SizedBox(height: 16),
          Text(
            _errorMessage!,
            style: const TextStyle(color: Colors.red, fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],

        const Spacer(),

        // Capture button
        if (_isLoading)
          const CircularProgressIndicator(
            color: Color(0xFF2E5BFF),
          )
        else
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: _captureAndEnroll,
              icon: const Icon(Icons.camera_alt),
              label: const Text(
                'Capture & Register',
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

        TextButton(
          onPressed: () {
            setState(() {
              _currentStep = 0;
            });
          },
          child: const Text(
            'Cancel',
            style: TextStyle(color: Colors.red, fontSize: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildProcessingStep() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 150,
          height: 150,
          child: Stack(
            alignment: Alignment.center,
            children: [
              RotationTransition(
                turns: _pulseController,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF2E5BFF),
                      width: 3,
                    ),
                  ),
                ),
              ),
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: const Color(0xFF2E5BFF).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.face,
                  size: 50,
                  color: Color(0xFF2E5BFF),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 48),

        const Text(
          'Registering your face...',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),

        const SizedBox(height: 16),

        const LinearProgressIndicator(
          backgroundColor: Colors.grey,
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2E5BFF)),
        ),

        const SizedBox(height: 32),

        const Text(
          'Sending encrypted face data to server.\nThis may take a few seconds.',
          style: TextStyle(fontSize: 14, color: Colors.black54, height: 1.5),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSuccessStep() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check_circle, size: 60, color: Colors.green),
        ),

        const SizedBox(height: 40),

        const Text(
          'Face Registered!',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),

        const SizedBox(height: 16),

        const Text(
          'Your face has been securely registered. You can now use face recognition to mark attendance.',
          style: TextStyle(fontSize: 16, color: Colors.black54, height: 1.5),
          textAlign: TextAlign.center,
        ),

        const Spacer(),

        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _completeEnrollment,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Done',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }
}

class _FaceGuidePainter extends CustomPainter {
  const _FaceGuidePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    const ovalWidth = 140.0;
    final ovalHeight = ovalWidth * 1.3;

    final rect = Rect.fromCenter(
      center: center,
      width: ovalWidth,
      height: ovalHeight,
    );

    const cornerLen = 30.0;
    const radius = 20.0;

    // Top-left
    canvas.drawLine(
      Offset(rect.left + radius, rect.top),
      Offset(rect.left + radius + cornerLen, rect.top),
      paint,
    );
    canvas.drawLine(
      Offset(rect.left, rect.top + radius),
      Offset(rect.left, rect.top + radius + cornerLen),
      paint,
    );

    // Top-right
    canvas.drawLine(
      Offset(rect.right - radius, rect.top),
      Offset(rect.right - radius - cornerLen, rect.top),
      paint,
    );
    canvas.drawLine(
      Offset(rect.right, rect.top + radius),
      Offset(rect.right, rect.top + radius + cornerLen),
      paint,
    );

    // Bottom-left
    canvas.drawLine(
      Offset(rect.left, rect.bottom - radius),
      Offset(rect.left, rect.bottom - radius - cornerLen),
      paint,
    );
    canvas.drawLine(
      Offset(rect.left + radius, rect.bottom),
      Offset(rect.left + radius + cornerLen, rect.bottom),
      paint,
    );

    // Bottom-right
    canvas.drawLine(
      Offset(rect.right, rect.bottom - radius),
      Offset(rect.right, rect.bottom - radius - cornerLen),
      paint,
    );
    canvas.drawLine(
      Offset(rect.right - radius, rect.bottom),
      Offset(rect.right - radius - cornerLen, rect.bottom),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _FaceGuidePainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
