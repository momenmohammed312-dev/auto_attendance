// ============================================================
// STUDENT PROFILE SCREEN - User Profile and Settings
// ============================================================
// This screen displays the student's profile information,
// app settings, and provides logout functionality.
//
// Features:
// - User avatar with initials
// - Name and email display
// - Settings options (notifications, password, language)
// - Logout button
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../router/app_router.dart';

/// Student Profile Screen - Displays user info and settings
///
/// Uses Riverpod to access the current authenticated user.
/// Shows profile header with avatar, name, and email.
/// Contains settings section and logout button.
class StudentProfileScreen extends ConsumerWidget {
  /// Creates the student profile screen
  const StudentProfileScreen({super.key});

  /// Builds the profile screen UI
  ///
  /// [context] - Build context for UI rendering
  /// [ref] - Riverpod widget reference for state access
  /// Returns the complete profile screen widget tree
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get current user data from auth provider
    final user = ref.watch(authProvider).user;

    return Scaffold(
      // Light grey background for modern look
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile Header Section - Avatar, Name, and Email
            // Profile Card Container
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  // User Avatar - Shows first letter of name
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: const Color(0xFF2E5BFF),
                    child: Text(
                      // Display first letter of user name, fallback to 'S'
                      user?.name.substring(0, 1).toUpperCase() ?? 'S',
                      style: const TextStyle(
                        fontSize: 32,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Display user name or fallback text
                  Text(
                    user?.name ?? 'Student Name',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Display user email or fallback text
                  Text(
                    user?.email ?? 'student@university.edu',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Settings Section - Contains app configuration options
            _buildSection(
              title: 'Settings',
              items: [
                // Notifications settings option
                _buildItem(
                  icon: Icons.notifications,
                  title: 'Notifications',
                  onTap: () {
                    // TODO: Navigate to notification settings
                  },
                ),
                // Password change option
                _buildItem(
                  icon: Icons.lock,
                  title: 'Change Password',
                  onTap: () {
                    // TODO: Show password change dialog
                  },
                ),
                // Language selection option
                _buildItem(
                  icon: Icons.language,
                  title: 'Language',
                  trailing: const Text('English'),
                  onTap: () {
                    // TODO: Show language selection dialog
                  },
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Logout Section - Allows user to sign out
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: ListTile(
                // Logout icon in red color
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text(
                  'Logout',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  // Call logout method from auth provider
                  ref.read(authProvider.notifier).logout();
                  // Navigate to login screen and clear navigation stack
                  Navigator.pushReplacementNamed(context, AppRoutes.login);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds a section container with title and list items
  ///
  /// [title] - Section header text
  /// [items] - List of widgets to display in the section
  /// Returns a styled container with the section content
  Widget _buildSection({required String title, required List<Widget> items}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          ...items,
        ],
      ),
    );
  }

  /// Builds a single settings item with icon, title, and optional trailing widget
  ///
  /// [icon] - Leading icon for the item
  /// [title] - Item label text
  /// [trailing] - Optional widget shown on the right (e.g., Text, Icon)
  /// [onTap] - Callback function when item is tapped
  /// Returns a styled ListTile for the settings item
  Widget _buildItem({
    required IconData icon,
    required String title,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF2E5BFF)),
      title: Text(title),
      trailing: trailing ?? const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
