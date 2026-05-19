import 'package:flutter/material.dart';
import 'dart:math' as math;

class CleanerOrbWidget extends StatefulWidget {
  final String totalSize;
  final String label;

  const CleanerOrbWidget({
    super.key,
    required this.totalSize,
    required this.label,
  });

  @override
  State<CleanerOrbWidget> createState() => _CleanerOrbWidgetState();
}

class _CleanerOrbWidgetState extends State<CleanerOrbWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
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
    return Column(
      children: [
        AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _pulseAnimation.value,
              child: child,
            );
          },
          child: SizedBox(
            width: 160,
            height: 160,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Outer glow ring
                CustomPaint(
                  size: const Size(160, 160),
                  painter: _OrbGlowPainter(),
                ),
                // Inner circle with broom icon
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const RadialGradient(
                      colors: [
                        Color(0xFF00E5CC),
                        Color(0xFF00897B),
                        Color(0xFF004D40),
                      ],
                      stops: [0.0, 0.5, 1.0],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00E5CC).withOpacity(0.6),
                        blurRadius: 30,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.cleaning_services_rounded,
                    color: Colors.white,
                    size: 44,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          widget.totalSize,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 30,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          widget.label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.6),
            fontSize: 14,
            letterSpacing: 0.4,
          ),
        ),
      ],
    );
  }
}

class _OrbGlowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Outer faint glow ring
    final outerPaint = Paint()
      ..color = const Color(0xFF00E5CC).withOpacity(0.15)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, outerPaint);

    // Middle ring
    final middlePaint = Paint()
      ..color = const Color(0xFF00E5CC).withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, radius - 8, middlePaint);

    // Bright arc top
    final arcPaint = Paint()
      ..shader = const SweepGradient(
        startAngle: -math.pi / 2,
        endAngle: math.pi * 1.5,
        colors: [
          Color(0xFF00E5CC),
          Color(0xFF00BCD4),
          Color(0xFF004D40),
          Color(0xFF00E5CC),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius - 4))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius - 4, arcPaint);

    // Bottom platform shadow/reflection
    final reflectionPaint = Paint()
      ..color = const Color(0xFF00E5CC).withOpacity(0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx, size.height - 4),
        width: 80,
        height: 16,
      ),
      reflectionPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}