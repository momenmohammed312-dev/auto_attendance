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
    if (authState.error != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(authState.error!)));
      });
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

        const SizedBox(height: 12),

        // Password Input Field
        TextFormField(
          controller: _passwordController,
          decoration: InputDecoration(
            hintText: 'Password',
            prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey),
            suffixIcon: const Icon(Icons.visibility_off, color: Colors.grey),
            filled: true,
            fillColor: const Color(0xFFF8F9FA),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
          ),
          obscureText: true,
          enabled: !isLoading, // Disable when loading
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
      ],
    );
  }

  /// Handles login button press
  /// Validates inputs and calls auth provider login method
  void _handleLogin() {
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

    // Call login method from auth provider
    ref.read(authProvider.notifier).login(email, password, role);
  }
}
