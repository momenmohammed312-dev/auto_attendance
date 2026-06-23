import 'dart:ui';

/// Safely converts a hex color string to a [Color].
///
/// Accepts formats: `'#2E5BFF'`, `'2E5BFF'`, `'#FF2E5BFF'`, `'0xFF2E5BFF'`.
/// Returns [fallback] if the input is null, empty, or malformed.
Color tryColorFromHex(String? hex, {Color fallback = const Color(0xFF9E9E9E)}) {
  if (hex == null || hex.isEmpty) return fallback;

  var sanitized = hex.replaceFirst('#', '');

  // If it starts with '0x' or '0X', parse as-is
  if (sanitized.toLowerCase().startsWith('0x')) {
    final value = int.tryParse(sanitized, radix: 16);
    if (value == null) return fallback;
    // If it's 6-digit (no alpha), add 0xFF prefix
    final hexDigits = sanitized.substring(2);
    if (hexDigits.length <= 6) {
      return Color(value | 0xFF000000);
    }
    return Color(value);
  }

  // Strip leading 'FF' alpha if 8-digit hex (backend sometimes sends this)
  if (sanitized.length == 8 && sanitized.toUpperCase().startsWith('FF')) {
    sanitized = sanitized.substring(2);
  }

  if (sanitized.length != 6) return fallback;

  final value = int.tryParse(sanitized, radix: 16);
  if (value == null) return fallback;

  return Color(value | 0xFF000000);
}
