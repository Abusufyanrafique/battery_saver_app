import 'package:battery_saver_app/bloc/junk_cleaner/junk_state.dart';
import 'package:flutter/material.dart';

class ScanStatusWidget extends StatefulWidget {
  final ScanPhase phase;
  final String currentPackage;

  const ScanStatusWidget({
    super.key,
    required this.phase,
    required this.currentPackage,
  });

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
    if (widget.phase == ScanPhase.cleaning ||
        widget.phase == ScanPhase.cleaned) {
      return const SizedBox.shrink();
    }

    final text = widget.phase == ScanPhase.scanning
        ? 'Scanning: ${widget.currentPackage}...'
        : 'Scan Complete';

    return Align(
      alignment: Alignment.centerLeft,
      child: FadeTransition(
        opacity: widget.phase == ScanPhase.scanning
            ? _fadeAnimation
            : const AlwaysStoppedAnimation(1.0),
        child: Text(
          text,
          style: const TextStyle(
            color: Color(0xFFD9D9D9),
            fontSize: 13,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }
}