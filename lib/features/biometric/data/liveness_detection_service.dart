import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class LivenessPreCheckResult {
  final bool passed;
  final String? reason;
  final String? message;

  const LivenessPreCheckResult({
    required this.passed,
    this.reason,
    this.message,
  });
}

class LivenessDetectionService {
  final FaceDetector _faceDetector;

  LivenessDetectionService()
      : _faceDetector = FaceDetector(
          options: FaceDetectorOptions(
            enableContours: false,
            enableClassification: true,
            enableLandmarks: false,
            enableTracking: false,
          ),
        );

  Future<LivenessPreCheckResult> preCheck(InputImage image) async {
    try {
      final faces = await _faceDetector.processImage(image);

      if (faces.isEmpty) {
        return const LivenessPreCheckResult(
          passed: false,
          reason: 'no_face',
          message: 'No face detected. Please face the camera.',
        );
      }

      if (faces.length > 1) {
        return const LivenessPreCheckResult(
          passed: false,
          reason: 'multiple_faces',
          message: 'Multiple faces detected. Ensure only your face is visible.',
        );
      }

      final face = faces.first;
      final leftEyeOpen = face.leftEyeOpenProbability ?? 0.0;
      final rightEyeOpen = face.rightEyeOpenProbability ?? 0.0;

      if (leftEyeOpen < 0.15 && rightEyeOpen < 0.15) {
        return const LivenessPreCheckResult(
          passed: false,
          reason: 'eyes_closed',
          message: 'Please keep your eyes open.',
        );
      }

      return const LivenessPreCheckResult(passed: true);
    } catch (e) {
      return const LivenessPreCheckResult(
        passed: false,
        reason: 'detection_error',
        message: 'Face detection error. Please try again.',
      );
    }
  }

  void dispose() {
    _faceDetector.close();
  }
}
