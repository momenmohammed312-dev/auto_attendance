import 'package:flutter/material.dart';

/// Biometric Enrollment Screen
///
/// This screen is displayed the first time a user sets up biometric authentication.
/// It guides the user through the process of registering their fingerprint
/// or face ID for quick attendance marking.
///
/// This is a ONE-TIME setup screen that appears only during initial app configuration.
/// After successful enrollment, users will be taken directly to the verification
/// screen when marking attendance.
///
/// Features:
/// - Animated biometric icon to guide user
/// - Step-by-step enrollment instructions
/// - Success/Error state handling
/// - Skip option for users who prefer manual attendance
///
/// Navigation:
/// - Called from: Dashboard (first time only)
/// - Goes to: IdentityVerificationScreen (after enrollment)
/// - Can skip to: Dashboard (if user declines)
class BiometricEnrollmentScreen extends StatefulWidget {
  const BiometricEnrollmentScreen({super.key});

  @override
  State<BiometricEnrollmentScreen> createState() =>
      _BiometricEnrollmentScreenState();
}

class _BiometricEnrollmentScreenState extends State<BiometricEnrollmentScreen>
    with SingleTickerProviderStateMixin {
  /// Animation controller for the biometric icon pulse effect
  late AnimationController _pulseController;

  /// Current step in the enrollment process
  /// 0 = Introduction, 1 = Scanning, 2 = Success
  int _currentStep = 0;

  /// Loading state during biometric check
  bool _isLoading = false;

  /// Error message if enrollment fails
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Initialize pulse animation for biometric icon
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    // Clean up animation controller to prevent memory leaks
    _pulseController.dispose();
    super.dispose();
  }

  /// Starts the biometric enrollment process
  ///
  /// This method:
  /// 1. Checks if device supports biometric authentication
  /// 2. Requests permission to use biometrics
  /// 3. Guides user through fingerprint/face scan
  /// 4. Stores enrollment status in local storage
  ///
  /// Called when user taps the "Start Setup" button
  Future<void> _startEnrollment() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _currentStep = 1; // Move to scanning step
    });

    // Simulate biometric check (will be replaced with local_auth)
    await Future.delayed(const Duration(seconds: 2));

    // Mock success - in real implementation, this uses local_auth package
    setState(() {
      _isLoading = false;
      _currentStep = 2; // Move to success step
    });
  }

  /// Skips biometric enrollment and returns to dashboard
  ///
  /// Called when user taps "Skip for now" button
  /// Stores preference to not use biometric attendance
  void _skipEnrollment() {
    // TODO: Store skip preference in local storage
    Navigator.of(context).pop();
  }

  /// Completes enrollment and returns to dashboard
  ///
  /// Called after successful biometric registration
  /// Navigates back to dashboard with enrollment complete status
  void _completeEnrollment() {
    // TODO: Mark enrollment as complete in local storage
    Navigator.of(context).pop(true); // Return success result
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

  /// Builds the main content based on current enrollment step
  ///
  /// Returns different UI for:
  /// - Step 0: Introduction with setup button
  /// - Step 1: Scanning animation with loading indicator
  /// - Step 2: Success confirmation
  Widget _buildContent() {
    switch (_currentStep) {
      case 0:
        return _buildIntroductionStep();
      case 1:
        return _buildScanningStep();
      case 2:
        return _buildSuccessStep();
      default:
        return _buildIntroductionStep();
    }
  }

  /// Builds the introduction step UI
  ///
  /// Displays:
  /// - Animated biometric icon with pulse effect
  /// - Title and description text
  /// - Benefits list (quick, secure, convenient)
  /// - Start Setup and Skip buttons
  Widget _buildIntroductionStep() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Animated biometric icon with pulse effect
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
                  Icons.fingerprint,
                  size: 60,
                  color: Color(0xFF2E5BFF),
                ),
              ),
            );
          },
        ),

        const SizedBox(height: 40),

        // Title text
        const Text(
          'Set Up Biometric Attendance',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 16),

        // Description text
        const Text(
          'Use your fingerprint or face ID to quickly mark your attendance. No more manual check-ins!',
          style: TextStyle(fontSize: 16, color: Colors.black54, height: 1.5),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 40),

        // Benefits list
        _buildBenefitItem(Icons.speed, 'Quick', 'Mark attendance in seconds'),
        const SizedBox(height: 16),
        _buildBenefitItem(
          Icons.security,
          'Secure',
          'Your biometric data stays on device',
        ),
        const SizedBox(height: 16),
        _buildBenefitItem(Icons.touch_app, 'Convenient', 'No passwords needed'),

        const Spacer(),

        // Error message display
        if (_errorMessage != null) ...[
          Text(
            _errorMessage!,
            style: const TextStyle(color: Colors.red, fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
        ],

        // Start Setup button
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

        // Skip button
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

  /// Builds a single benefit item with icon and text
  ///
  /// Parameters:
  /// - [icon]: The icon to display
  /// - [title]: Benefit title (e.g., "Quick")
  /// - [description]: Benefit description
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

  /// Builds the scanning step UI
  ///
  /// Displays animated scanning interface while
  /// waiting for user to scan fingerprint/face
  Widget _buildScanningStep() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Animated scanning indicator
        SizedBox(
          width: 150,
          height: 150,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer rotating ring
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
              // Inner biometric icon
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: const Color(0xFF2E5BFF).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.fingerprint,
                  size: 50,
                  color: Color(0xFF2E5BFF),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 48),

        // Scanning status text
        Text(
          _isLoading ? 'Place your finger...' : 'Processing...',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),

        const SizedBox(height: 16),

        // Loading indicator
        if (_isLoading)
          const LinearProgressIndicator(
            backgroundColor: Colors.grey,
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2E5BFF)),
          ),

        const SizedBox(height: 32),

        // Instructions
        const Text(
          'Touch the fingerprint sensor on your device to complete enrollment',
          style: TextStyle(fontSize: 14, color: Colors.black54, height: 1.5),
          textAlign: TextAlign.center,
        ),

        const Spacer(),

        // Cancel button
        TextButton(
          onPressed: () {
            setState(() {
              _currentStep = 0;
              _isLoading = false;
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

  /// Builds the success step UI
  ///
  /// Displayed after successful biometric enrollment
  /// Shows confirmation and completes setup
  Widget _buildSuccessStep() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Success icon
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

        // Success title
        const Text(
          'Setup Complete!',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),

        const SizedBox(height: 16),

        // Success description
        const Text(
          'Your biometric authentication is now ready. You can use it to quickly mark attendance for all your lectures.',
          style: TextStyle(fontSize: 16, color: Colors.black54, height: 1.5),
          textAlign: TextAlign.center,
        ),

        const Spacer(),

        // Complete button
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
