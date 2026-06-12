import 'package:battery_saver_app/utils/SizeConfig.dart';
import 'package:flutter/material.dart';

class StopButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String label; // 'Stop' ya 'Optimize Again' — Bloc se aayega

  const StopButton({
    super.key,
    required this.onPressed,
    this.label = 'Stop', // default same rakha
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        height: getHeight(60),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFF55D0FF),
              Color(0xFF0E5AA7),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                label == 'Stop' ? Icons.stop : Icons.refresh,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}