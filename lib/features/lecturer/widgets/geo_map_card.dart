import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/session_provider.dart';
import 'package:auto_attendace/core/app_colors.dart';

class GeoMapCard extends ConsumerStatefulWidget {
  final void Function(double lat, double lng)? onLocationSelected;

  const GeoMapCard({super.key, this.onLocationSelected});

  @override
  ConsumerState<GeoMapCard> createState() => _GeoMapCardState();
}

class _GeoMapCardState extends ConsumerState<GeoMapCard> {
  double? _latitude;
  double? _longitude;
  bool _fetchingLocation = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchCurrentLocation());
  }

  Future<void> _fetchCurrentLocation() async {
    setState(() => _fetchingLocation = true);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever) {
        _showPermissionError();
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
        _fetchingLocation = false;
      });

      widget.onLocationSelected?.call(position.latitude, position.longitude);
    } catch (e) {
      setState(() => _fetchingLocation = false);
      _showError('Could not get location: $e');
    }
  }

  void _showPermissionError() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Location permission denied. Please enable it in settings.'),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.orange),
    );
  }

  @override
  Widget build(BuildContext context) {
    final radius = ref.watch(sessionProvider).radiusMeters;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.location_on, color: AppColors.primary),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text('Lecture Location',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                ),
                IconButton(
                  onPressed: _fetchingLocation ? null : _fetchCurrentLocation,
                  icon: _fetchingLocation
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.my_location, color: AppColors.primary),
                  tooltip: 'Use my location',
                ),
              ],
            ),
          ),
          SizedBox(
            height: 220,
            child: _fetchingLocation
                ? const Center(child: CircularProgressIndicator())
                : _latitude != null && _longitude != null
                    ? _buildLocationPreview(radius)
                    : _buildPlaceholder(),
          ),
          if (_latitude != null && _longitude != null)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: const [
                  Icon(Icons.check_circle, color: AppColors.success, size: 16),
                  SizedBox(width: 6),
                  Text('Location set', style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLocationPreview(double radius) {
    return Container(
      width: double.infinity,
      color: AppColors.surfaceAlt,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.map, size: 48, color: AppColors.primary.withValues(alpha: 0.5)),
          const SizedBox(height: 12),
          Text(
            'Lat: ${_latitude!.toStringAsFixed(6)}',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
          ),
          Text(
            'Lng: ${_longitude!.toStringAsFixed(6)}',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Radius: ${radius.toStringAsFixed(0)} m',
              style: const TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: double.infinity,
      color: AppColors.surfaceAlt,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.location_off, size: 48, color: AppColors.textMuted),
          const SizedBox(height: 12),
          const Text('No location set', style: TextStyle(fontSize: 14, color: AppColors.textMuted)),
          const SizedBox(height: 4),
          const Text('Tap the location button to set lecture location',
              style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
        ],
      ),
    );
  }
}
