// radius_slider_card.dart
// -----------------------
// Widget يعرض Slider لتحديد نصف قطر نطاق الحضور

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/session_provider.dart';
import 'package:auto_attendace/core/app_colors.dart';

class RadiusSliderCard extends ConsumerWidget {
  const RadiusSliderCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final radius = ref.watch(sessionProvider.select((s) => s.radiusMeters));

    final String radiusLabel = radius < 1000
        ? '${radius.toStringAsFixed(0)} m'
        : '${(radius / 1000).toStringAsFixed(1)} km';

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.radar, color: AppColors.primary),
                const SizedBox(width: 8),
                const Text('Attendance Radius',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(20)),
                  child: Text(radiusLabel,
                      style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 14)),
                ),
              ],
            ),
            const SizedBox(height: 4),
            const Text('Students must be within this distance to check in',
                style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
            const SizedBox(height: 16),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: AppColors.primary,
                inactiveTrackColor: AppColors.primaryLight,
                thumbColor: AppColors.primary,
                overlayColor: AppColors.primary.withValues(alpha: 0.2),
                valueIndicatorColor: AppColors.primary,
                valueIndicatorTextStyle: const TextStyle(color: Colors.white),
                trackHeight: 4,
              ),
              child: Slider(
                value: radius,
                min: 10,
                max: 500,
                divisions: 49,
                label: radiusLabel,
                onChanged: (value) => ref.read(sessionProvider.notifier).updateRadius(value),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('10 m', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                  Text('100 m', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                  Text('250 m', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                  Text('500 m', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _QuickButton(label: '25 m', value: 25, currentRadius: radius, ref: ref),
                _QuickButton(label: '50 m', value: 50, currentRadius: radius, ref: ref),
                _QuickButton(label: '100 m', value: 100, currentRadius: radius, ref: ref),
                _QuickButton(label: '200 m', value: 200, currentRadius: radius, ref: ref),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickButton extends StatelessWidget {
  final String label;
  final double value;
  final double currentRadius;
  final WidgetRef ref;

  const _QuickButton({
    required this.label,
    required this.value,
    required this.currentRadius,
    required this.ref,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = (currentRadius - value).abs() < 1.0;
    return GestureDetector(
      onTap: () => ref.read(sessionProvider.notifier).updateRadius(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surfaceAlt,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? AppColors.primary : AppColors.divider),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : AppColors.textSub,
          ),
        ),
      ),
    );
  }
}
