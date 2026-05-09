import 'dart:ui';
import 'package:auto_attendace/router/app_router.dart'; // App routes for navigation
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  // Using global secureStorage instance from secure_storage.dart (Singleton pattern)

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();

    // Check if user is already logged in (auto-login with Remember Me)
    // This replaces the old 5-second delay that always went to LoginScreen
    _checkLoginStatus();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// Checks if user has saved login credentials (Remember Me feature)
  ///
  /// Flow:
  /// 1. Wait 2 seconds for splash animation to complete
  /// 2. Navigate to LoginScreen
  ///
  /// Note (Option A - Biometric button on LoginScreen):
  /// We do NOT auto-login from SplashScreen.
  /// If a saved user exists, LoginScreen will show the biometric login button
  /// and the user can choose biometric login or manual email/password.
  Future<void> _checkLoginStatus() async {
    // Wait 2 seconds for splash animation to complete
    // This gives users time to see the logo and branding
    await Future.delayed(const Duration(seconds: 2));

    // mounted check prevents setState/navigation errors if widget was disposed
    if (!mounted) return;

    // Always go to login screen.
    // Any saved-user / Remember Me checks are handled by LoginScreen UI + biometric flow.
    Navigator.pushReplacementNamed(context, AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0040E0), Color(0xFF2E5BFF)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 48.0,
              vertical: 96.0,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedBuilder(
                          animation: _scaleAnimation,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _scaleAnimation.value,
                              child: Container(
                                width: 128,
                                height: 128,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.2),
                                    width: 1,
                                  ),
                                ),
                                child: ClipOval(
                                  child: BackdropFilter(
                                    filter: ImageFilter.blur(
                                      sigmaX: 6,
                                      sigmaY: 6,
                                    ),
                                    child: Center(
                                      child: Icon(
                                        Icons.school,
                                        size: 55,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 31.25),
                        Column(
                          children: [
                            Text(
                              'University Smart',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w800,
                                fontSize: 30,
                                color: Colors.white,
                                letterSpacing: -0.75,
                                height: 1.25,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            Text(
                              'Attendance',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w800,
                                fontSize: 30,
                                color: Colors.white,
                                letterSpacing: -0.75,
                                height: 1.25,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Academic Luminary Systems',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.7),
                                height: 1.43,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Column(
                  children: [
                    const SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'LOADING SYSTEM',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.8),
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
