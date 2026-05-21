import 'package:flutter/material.dart';

class BatteryProgressBar extends StatelessWidget {
  final int percentage;

  const BatteryProgressBar({
    super.key,
    required this.percentage,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: LinearProgressIndicator(
        value: percentage / 100,
        minHeight: 8,
        backgroundColor: Colors.white.withOpacity(0.1),
        valueColor: const AlwaysStoppedAnimation<Color>(
          Color(0xFF3B82F6),
        ),
      ),
    );
  }
}