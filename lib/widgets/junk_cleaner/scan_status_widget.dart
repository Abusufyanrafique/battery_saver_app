import 'package:flutter/material.dart';

class ScanStatusWidget extends StatefulWidget {
  final String scanningText;

  const ScanStatusWidget({super.key, required this.scanningText});

  @override
  State<ScanStatusWidget> createState() => _ScanStatusWidgetState();
}

class _ScanStatusWidgetState extends State<ScanStatusWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _fadeAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Text(
          widget.scanningText,
          style: const TextStyle(
            color: Color(0xFF00E5CC),
            fontSize: 13,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }
}