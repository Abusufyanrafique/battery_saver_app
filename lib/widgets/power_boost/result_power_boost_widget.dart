import 'package:battery_saver_app/configs/text_style/text_style.dart';
import 'package:battery_saver_app/utils/SizeConfig.dart';
import 'package:battery_saver_app/utils/app_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

// ─── Status Enum ────────────────────────────────────────────────────────────
enum RowStatus { done, inProgress, pending }

// ─── Data Model ─────────────────────────────────────────────────────────────
class OptimizeItem {
  final String svgPath;
  final String title;
  final String? badge;
  final RowStatus status;

  const OptimizeItem({
    required this.svgPath,
    required this.title,
    this.badge,
    required this.status,
  });
}

// ─── MAIN WIDGET ─────────────────────────────────────────────────────────────
class ResultPowerBoostWidget extends StatelessWidget {
  const ResultPowerBoostWidget({super.key});

  static  List<OptimizeItem> items = [
    OptimizeItem(
      svgPath: AppIcons.clearram,
      title: 'Clear RAM',
      badge: '1.2 GB',
      status: RowStatus.done,
    ),
    OptimizeItem(
      svgPath: AppIcons.optimizecup,
      title: 'Optimize CPU',
      badge: 'In Progress',
      status: RowStatus.inProgress,
    ),
    OptimizeItem(
      svgPath: AppIcons.closebackgroundapps,
      title: 'Close Background Apps',
      badge: 'Pending',
      status: RowStatus.pending,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
          gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF232C6D),
            Color(0xFF1B2153),
            Color(0xFF13173A),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF3A3FCC),
          width: 1.2,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(items.length, (index) {
          return _StatusRow(
            item: items[index],
            isLast: index == items.length - 1,
          );
        }),
      ),
    );
  }
}

// ─── ROW ──────────────────────────────────────────────────────────────
class _StatusRow extends StatelessWidget {
  final OptimizeItem item;
  final bool isLast;

  const _StatusRow({required this.item, required this.isLast});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              // SVG ICON
              Container(
                width: getWidth(40),
                height: getHeight(40),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF232C6D),
                  border: Border.all(
                    color: const Color(0xFF4103AC),
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: SvgPicture.asset(
                    item.svgPath,
                    width: getWidth(15),
                    height: getHeight(15),
                    colorFilter: const ColorFilter.mode(
                      Color(0xFF8A8FCC),
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 16),

              // TITLE
              Expanded(
                child: Text(
                  item.title,
                 style: AppTextStyles.bodyMedium.copyWith(
                  fontSize: getFont(14),
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                 ),
                ),
              ),

              // BADGE + STATUS
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (item.badge != null)
                    Text(
                      item.badge!,
                      style:AppTextStyles.bodyMedium.copyWith(
                        fontSize: getFont(12),
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF55D0FF)
                      )
                    ),
                  const SizedBox(width: 10),
                  _StatusIcon(status: item.status),
                ],
              ),
            ],
          ),
        ),

        if (!isLast)
          const Divider(
            color: Color(0xFF838283),
            thickness: 1,
            height: 1,
          ),
      ],
    );
  }

  Color _badgeColor(RowStatus status) {
    switch (status) {
      case RowStatus.done:
        return const Color(0xFF4A8EFF);
      case RowStatus.inProgress:
        return const Color(0xFF7B7FFF);
      case RowStatus.pending:
        return const Color(0xFF7B7FFF);
    }
  }
}

// ─── STATUS ICON (UNCHANGED) ───────────────────────────────────────────────
class _StatusIcon extends StatefulWidget {
  final RowStatus status;

  const _StatusIcon({required this.status});

  @override
  State<_StatusIcon> createState() => _StatusIconState();
}

class _StatusIconState extends State<_StatusIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.status) {
      case RowStatus.done:
        return Container(
          width: getWidth(16),
          height: getHeight(16),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFFEDC009), 
              width: 2
              ),
          ),
          child: const Icon(
            Icons.check,
            size: 10,
            color: Color(0xFFFFCC00),
          ),
        );

      case RowStatus.inProgress:
        return SizedBox(
          width:getWidth(16),
          height: getHeight(16),
          child: RotationTransition(
            turns: _controller,
            child: CustomPaint(
              painter: _ArcPainter(color: const Color(0xFF7B7FFF)),
            ),
          ),
        );

      case RowStatus.pending:
        return Container(
          // width: ,
          
        );
    }
  }
}

// ─── ARC PAINTER ────────────────────────────────────────────────────────────
class _ArcPainter extends CustomPainter {
  final Color color;

  _ArcPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final rect = Rect.fromLTWH(2, 2, size.width - 4, size.height - 4);
    canvas.drawArc(rect, 0, 4.5, false, paint);
  }

  @override
  bool shouldRepaint(_ArcPainter oldDelegate) => false;
}