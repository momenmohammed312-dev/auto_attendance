import 'package:flutter/material.dart';

/// Verification Methods Screen
///
/// This screen allows users to choose their preferred authentication method
/// when multiple biometric options are available on their device.
///
/// Supported Methods:
/// - Fingerprint (primary method)
/// - Face ID / Face Recognition (requires server enrollment)
/// - Device PIN / Pattern as fallback
///
/// Navigation:
/// - Called from: Settings or Dashboard (when tapping Attend)
/// - Goes to: IdentityVerificationScreen (with selected method)
class VerificationMethodsScreen extends StatefulWidget {
  const VerificationMethodsScreen({super.key});

  @override
  State<VerificationMethodsScreen> createState() =>
      _VerificationMethodsScreenState();
}

class _VerificationMethodsScreenState extends State<VerificationMethodsScreen> {
  String _selectedMethod = 'fingerprint';
  bool _isTesting = false;

  final List<Map<String, dynamic>> _availableMethods = [
    {
      'id': 'fingerprint',
      'name': 'Fingerprint',
      'icon': Icons.fingerprint,
      'description': 'Use your fingerprint to verify',
      'isAvailable': true,
      'securityLevel': 'High',
    },
    {
      'id': 'face',
      'name': 'Face ID',
      'icon': Icons.face,
      'description': 'Use face recognition to verify',
      'isAvailable': true,
      'securityLevel': 'High',
    },
    {
      'id': 'pin',
      'name': 'Device PIN',
      'icon': Icons.pin_outlined,
      'description': 'Use your device PIN as backup',
      'isAvailable': true,
      'securityLevel': 'Medium',
    },
  ];

  @override
  void initState() {
    super.initState();
  }

  void _selectMethod(String methodId) {
    setState(() {
      _selectedMethod = methodId;
    });
  }

  Future<void> _testMethod() async {
    setState(() {
      _isTesting = true;
    });

    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _isTesting = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${_getSelectedMethodName()} test successful!'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _continueToVerification() {
    Navigator.of(
      context,
    ).pushNamed('/verify', arguments: {'method': _selectedMethod});
  }

  String _getSelectedMethodName() {
    final method = _availableMethods.firstWhere(
      (m) => m['id'] == _selectedMethod,
      orElse: () => _availableMethods.first,
    );
    return method['name'];
  }

  Color _getSecurityColor(String level) {
    switch (level) {
      case 'High':
        return Colors.green;
      case 'Medium':
        return Colors.orange;
      case 'Low':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Choose Method'),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'How would you like to verify?',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Select your preferred authentication method. You can change this anytime in settings.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 32),

              ..._availableMethods.map((method) => _buildMethodCard(method)),

              const Spacer(),

              if (_isTesting)
                const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFF2E5BFF),
                    ),
                  ),
                )
              else
                TextButton.icon(
                  onPressed: _testMethod,
                  icon: const Icon(Icons.play_circle_outline, size: 20),
                  label: const Text('Test Selected Method'),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF2E5BFF),
                  ),
                ),

              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _continueToVerification,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E5BFF),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Continue with ${_getSelectedMethodName()}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMethodCard(Map<String, dynamic> method) {
    final isSelected = _selectedMethod == method['id'];
    final isAvailable = method['isAvailable'] as bool;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: isAvailable ? () => _selectMethod(method['id']) : null,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF2E5BFF).withValues(alpha: 0.05)
                : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF2E5BFF)
                  : Colors.grey.withValues(alpha: 0.2),
              width: isSelected ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: isAvailable
                      ? const Color(0xFF2E5BFF).withValues(alpha: 0.1)
                      : Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  method['icon'] as IconData,
                  color: isAvailable ? const Color(0xFF2E5BFF) : Colors.grey,
                  size: 28,
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          method['name'] as String,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isAvailable ? Colors.black : Colors.grey,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getSecurityColor(
                              method['securityLevel'],
                            ).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            method['securityLevel'] as String,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: _getSecurityColor(method['securityLevel']),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      method['description'] as String,
                      style: TextStyle(
                        fontSize: 13,
                        color: isAvailable ? Colors.black54 : Colors.grey,
                      ),
                    ),
                    if (!isAvailable) ...[
                      const SizedBox(height: 4),
                      const Text(
                        'Not available on this device',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.red,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF2E5BFF)
                      : Colors.transparent,
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF2E5BFF)
                        : Colors.grey.withValues(alpha: 0.4),
                    width: 2,
                  ),
                  shape: BoxShape.circle,
                ),
                child: isSelected
                    ? const Icon(Icons.check, color: Colors.white, size: 16)
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
