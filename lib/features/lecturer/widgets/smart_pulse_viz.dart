// smart_pulse_viz.dart
// --------------------
// Widget يعرض Animated Pulse للدلالة على أن الجلسة نشطة
// بيعرض عدد الحاضرين في الوسط مع دوائر نابضة حوليه

import 'package:flutter/material.dart';
import 'package:auto_attendace/core/app_colors.dart';

class SmartPulseViz extends StatefulWidget {
  final int presentCount;
  final int totalCount;
  final bool isActive;

  const SmartPulseViz({
    super.key,
    required this.presentCount,
    required this.totalCount,
    this.isActive = true,
  });

  @override
  State<SmartPulseViz> createState() => _SmartPulseVizState();
}

class _SmartPulseVizState extends State<SmartPulseViz> with TickerProviderStateMixin {
  late AnimationController _pulse1Controller;
  late AnimationController _pulse2Controller;

  late Animation<double> _pulse1Scale;
  late Animation<double> _pulse1Opacity;
  late Animation<double> _pulse2Scale;
  late Animation<double> _pulse2Opacity;

  @override
  void initState() {
    super.initState();

    _pulse1Controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 2000));
    _pulse1Scale = Tween<double>(begin: 0.8, end: 2.0).animate(CurvedAnimation(parent: _pulse1Controller, curve: Curves.easeOut));
    _pulse1Opacity = Tween<double>(begin: 0.6, end: 0.0).animate(CurvedAnimation(parent: _pulse1Controller, curve: Curves.easeOut));

    _pulse2Controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 2000));
    _pulse2Scale = Tween<double>(begin: 0.8, end: 2.0).animate(CurvedAnimation(parent: _pulse2Controller, curve: Curves.easeOut));
    _pulse2Opacity = Tween<double>(begin: 0.6, end: 0.0).animate(CurvedAnimation(parent: _pulse2Controller, curve: Curves.easeOut));

    if (widget.isActive) _startAnimations();
  }

  void _startAnimations() {
    _pulse1Controller.repeat();
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) _pulse2Controller.repeat();
    });
  }

  @override
  void didUpdateWidget(SmartPulseViz oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        _startAnimations();
      } else {
        _pulse1Controller.stop();
        _pulse2Controller.stop();
      }
    }
  }

  @override
  void dispose() {
    _pulse1Controller.dispose();
    _pulse2Controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double rate = widget.totalCount > 0 ? widget.presentCount / widget.totalCount : 0.0;

    final Color pulseColor = rate < 0.3
        ? AppColors.warning
        : rate < 0.7
            ? AppColors.primary
            : AppColors.success;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                if (widget.isActive)
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle),
                  ),
                if (widget.isActive) const SizedBox(width: 6),
                Text(
                  widget.isActive ? 'Live Session' : 'Session Ended',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Center(
              child: SizedBox(
                width: 140,
                height: 140,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    AnimatedBuilder(
                      animation: _pulse1Controller,
                      builder: (_, __) => Transform.scale(
                        scale: _pulse1Scale.value,
                        child: Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(shape: BoxShape.circle, color: pulseColor.withValues(alpha: _pulse1Opacity.value)),
                        ),
                      ),
                    ),
                    AnimatedBuilder(
                      animation: _pulse2Controller,
                      builder: (_, __) => Transform.scale(
                        scale: _pulse2Scale.value,
                        child: Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(shape: BoxShape.circle, color: pulseColor.withValues(alpha: _pulse2Opacity.value)),
                        ),
                      ),
                    ),
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: pulseColor,
                        boxShadow: [BoxShadow(color: pulseColor.withValues(alpha: 0.3), blurRadius: 12, spreadRadius: 2)],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('${widget.presentCount}',
                              style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold, height: 1)),
                          Text('of ${widget.totalCount}', style: const TextStyle(color: Colors.white70, fontSize: 11)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _StatItem(label: 'Present', value: '${widget.presentCount}', color: AppColors.success),
                _StatItem(label: 'Absent', value: '${widget.totalCount - widget.presentCount}', color: AppColors.danger),
                _StatItem(label: 'Rate', value: '${(rate * 100).toStringAsFixed(0)}%', color: pulseColor),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatItem({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
      ],
    );
  }
}
