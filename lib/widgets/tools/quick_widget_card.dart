import 'package:battery_saver_app/utils/SizeConfig.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:battery_saver_app/models/tools/quick_widget_item.dart';

class QuickWidgetCard extends StatelessWidget {
  final QuickWidgetItem item;
  final VoidCallback? onTap;

  const QuickWidgetCard({
    super.key,
    required this.item,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: getHeight(110),
        width: getWidth(80),
        decoration: BoxDecoration(
          color: const Color(0xFF151A30),
          borderRadius: BorderRadius.circular(6),
           border: Border.all(color: item.borderColor, width: 1),   
          
        ),
        // padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

           
            _PlainIcon(item: item),
            const SizedBox(height: 8),
            Text(
              item.label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.85),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}



/// ─────────────────────────────────────────────
/// SVG ICON (NO RING)
/// ─────────────────────────────────────────────
class _PlainIcon extends StatelessWidget {
  final QuickWidgetItem item;

  const _PlainIcon({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: SvgPicture.asset(
          item.svgIcon,
          width: 46,
          height: 46,
        ),
      ),
    );
  }
}

