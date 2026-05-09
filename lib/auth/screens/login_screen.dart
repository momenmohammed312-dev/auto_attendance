import 'package:auto_attendace/core/biometric/biometric_service.dart'; // Biometric authentication service
import 'package:auto_attendace/core/storage/secure_storage.dart'; // Secure storage for saved user data
import 'package:auto_attendace/router/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart'; // Import auth provider for Riverpod state management

/// LoginScreen - Main entry point for user authentication
/// Uses ConsumerStatefulWidget to access Riverpod's ref and maintain local state
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

/// _LoginScreenState - State class for LoginScreen
/// Manages text controllers, selected role, and handles login logic
class _LoginScreenState extends ConsumerState<LoginScreen> {
  // Text controllers for email and password input fields
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Currently selected role: 'Student' or 'Doctor'
  String _selectedRole = 'Student';

  // Controls password visibility (show/hide)
  bool _isPasswordVisible = false;

  // Remember me checkbox state
  bool _rememberMe = false;

  // Check if there's a saved user for biometric login
  // This will be true if user previously logged in with Remember Me enabled
  bool _hasSavedUser = false;

  // Prevent repeating snackbars/navigation on every rebuild.
  String? _lastShownError;
  bool _didNavigate = false;

  @override
  void initState() {
    super.initState();
    // Check if user has saved credentials (for biometric login option)
    _checkSavedUser();
  }

  /// Check if there's a saved user in secure storage
  /// If yes, show biometric login button
  Future<void> _checkSavedUser() async {
    final user = await secureStorage.getUser();
    if (mounted) {
      setState(() {
        _hasSavedUser = user != null;
      });
    }
  }

  @override
  void dispose() {
    // Clean up controllers when widget is disposed to prevent memory leaks
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Watch auth state from Riverpod provider
    final authState = ref.watch(authProvider);

    // Show error snackbar if there's an error in auth state
    if (authState.error != null && authState.error != _lastShownError) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(authState.error!)));
      });
      _lastShownError = authState.error;
    }

    // Navigate to dashboard if user is logged in
    if (authState.user != null && !authState.isLoading && !_didNavigate) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final role = authState.user!.role;
        Navigator.of(context).pushReplacementNamed(
          role == 'doctor'
              ? AppRoutes.doctorDashboard
              : AppRoutes.studentDashboard,
        );
      });
      _didNavigate = true;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        // SingleChildScrollView allows scrolling when keyboard appears (prevents overflow)
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLoginBackground(),
                const SizedBox(height: 24),
                _buildText(),
                const SizedBox(height: 24),
                _buildSelectedRoleButtons(), // Role toggle: Student/Doctor
                const SizedBox(height: 16),
                _buildLoginForm(
                  authState.isLoading,
                ), // Pass loading state to show spinner
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the university image header with shadow
  Widget _buildLoginBackground() {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(2.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.asset(
              'assets/uni_img.png',
              fit: BoxFit.cover,
              width: double.infinity,
              height: 180,
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the welcome text header
  Widget _buildText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Welcome back',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Sign in to access your dashboard',
          style: TextStyle(fontSize: 14, color: Colors.black54),
        ),
      ],
    );
  }

  /// Builds the role selection toggle (Student/Doctor)
  /// Allows user to switch between student and doctor login
  Widget _buildSelectedRoleButtons() {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [_buildRoleButton('Student'), _buildRoleButton('Doctor')],
      ),
    );
  }

  /// Helper method to build individual role button
  /// [role] - either 'Student' or 'Doctor'
  Widget _buildRoleButton(String role) {
    final isSelected = _selectedRole == role;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedRole = role),
        child: Container(
          margin: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              role,
              style: TextStyle(
                color: isSelected ? const Color(0xFF2E5BFF) : Colors.black54,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the login form with email, password, forgot password, and login button
  /// [isLoading] - disables inputs and shows spinner when true
  Widget _buildLoginForm(bool isLoading) {
    return Column(
      children: [
        // Email Input Field
        TextFormField(
          controller: _emailController,
          decoration: InputDecoration(
            hintText: 'University Email',
            prefixIcon: const Icon(Icons.email_outlined, color: Colors.grey),
            filled: true,
            fillColor: const Color(0xFFF8F9FA),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
          ),
          keyboardType: TextInputType.emailAddress,
          enabled: !isLoading, // Disable when loading
        ),

        // Password Input Field with visibility toggle
        TextFormField(
          controller: _passwordController,
          obscureText: !_isPasswordVisible, // Toggle visibility based on state
          decoration: InputDecoration(
            hintText: 'Password',
            prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey),
            // Eye icon button to toggle password visibility
            suffixIcon: IconButton(
              icon: Icon(
                _isPasswordVisible
                    ? Icons
                          .visibility // Eye open when visible
                    : Icons.visibility_off, // Eye closed when hidden
                color: Colors.grey,
              ),
              onPressed: isLoading
                  ? null // Disable when loading
                  : () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible; // Toggle
                      });
                    },
            ),
            filled: true,
            fillColor: const Color(0xFFF8F9FA),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
          ),
          enabled: !isLoading, // Disable when loading
        ),

        const SizedBox(height: 12),

        // Remember Me is placed here (between password and login button) so the
        // user can decide *after* entering credentials whether to save them.
        Row(
          children: [
            Checkbox(
              value: _rememberMe,
              onChanged: (value) {
                setState(() {
                  _rememberMe = value ?? false;
                });
              },
              activeColor: const Color(0xFF2E5BFF),
            ),
            const Text(
              'Remember Me',
              style: TextStyle(color: Colors.black54, fontSize: 14),
            ),
            const Spacer(), // يدفع الباقي لليمين
          ],
        ),

        const SizedBox(height: 16),

        // Login Button - Shows spinner when loading
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: isLoading ? null : _handleLogin,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E5BFF),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Login',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward, size: 18),
                    ],
                  ),
          ),
        ),

        // Biometric Login Button - Only shown if user has saved credentials
        // This allows quick login with fingerprint/face instead of typing email/password
        if (_hasSavedUser) ...[
          const SizedBox(height: 16),
          const Row(
            children: [
              Expanded(child: Divider()),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'OR',
                  style: TextStyle(color: Colors.black54, fontSize: 14),
                ),
              ),
              Expanded(child: Divider()),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: isLoading ? null : _loginWithBiometric,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF2E5BFF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                  side: const BorderSide(color: Color(0xFF2E5BFF)),
                ),
              ),
              icon: const Icon(Icons.fingerprint, size: 24),
              label: const Text(
                'Login with Biometric',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ],
    );
  }

  /// Handles login button press
  /// Validates inputs and calls auth provider login method
  Future<void> _handleLogin() async {
    // Get and trim input values
    final email = _emailController.text.trim(); // .trim() needs ()
    final password = _passwordController.text;
    final role = _selectedRole.toLowerCase(); // 'student' or 'doctor'

    // Validate inputs are not empty
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    // Call login method from auth provider with Remember Me preference.
    // We `await` here so that if login succeeds and Remember Me is enabled,
    // the user data is already saved into secure storage before we re-check it.
    await ref
        .read(authProvider.notifier)
        .login(email, password, role, rememberMe: _rememberMe);

    // UX improvement:
    // If the user enabled Remember Me, update `_hasSavedUser` immediately so
    // the biometric login button becomes visible without restarting the app.
    if (_rememberMe) {
      await _checkSavedUser();
    }
  }

  /// Handles biometric login button press
  ///
  /// Flow:
  /// 1. Check if device supports biometrics
  /// 2. Prompt user for fingerprint/face/PIN
  /// 3. If authenticated, retrieve saved user and login
  /// 4. Navigate to dashboard
  Future<void> _loginWithBiometric() async {
    // Step 1: Check if the device supports local authentication at all.
    // We use `isDeviceSupported` (not only `canCheckBiometrics`) because some
    // devices may still allow device credentials fallback.
    final bool deviceSupported = await biometricService.isDeviceSupported();

    // Debugging on real devices: this helps us understand why auth returns false.
    // You can watch these logs in `flutter run` output.
    final available = await biometricService.getAvailableBiometrics();
    debugPrint(
      'Biometric: deviceSupported=$deviceSupported available=$available',
    );

    if (!deviceSupported) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Biometric authentication is not supported on this device',
            ),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    // Step 2: Authenticate with biometric (fingerprint/face/PIN)
    final bool authenticated = await biometricService.authenticate(
      reason: 'تأكيد دخولك للتطبيق', // Arabic message for user
      allowPinFallback: true, // Allow device PIN if biometric fails/unavailable
    );

    debugPrint('Biometric: authenticated=$authenticated');

    if (!authenticated) {
      // Authentication failed or cancelled
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Authentication failed. Please use email and password.',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    // Step 3: Biometric succeeded! Get saved user data
    final userData = await secureStorage.getUser();

    debugPrint('Biometric: userDataExists=${userData != null}');

    if (userData == null) {
      // Shouldn't happen if _hasSavedUser is true, but handle just in case
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'No saved user found. Please login with email and password.',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }

      // Refresh the local flag so the biometric button can disappear if the
      // stored user was cleared for any reason.
      await _checkSavedUser();
      return;
    }

    // Step 4: Set user in auth provider (without calling API again)
    // This bypasses the normal login flow since user is already verified via biometric
    ref.read(authProvider.notifier).setUserFromStorage(userData);

    // Step 5: Navigate to appropriate dashboard based on role
    if (mounted) {
      final String role = userData['role'] ?? 'student';
      Navigator.pushReplacementNamed(
        context,
        role == 'doctor'
            ? AppRoutes.doctorDashboard
            : AppRoutes.studentDashboard,
      );
    }
  }
}
