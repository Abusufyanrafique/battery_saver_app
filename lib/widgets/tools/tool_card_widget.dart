// tool_card_widget.dart

import 'package:battery_saver_app/configs/text_style/text_style.dart';
import 'package:battery_saver_app/models/tools/tool_item.dart';
import 'package:battery_saver_app/utils/SizeConfig.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class ToolCardWidget extends StatelessWidget {
  final ToolItem tool;
  final VoidCallback? onTap;

  const ToolCardWidget({
    super.key,
    required this.tool,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: getHeight(144),
        width: getWidth(122),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        // boxShadow: [
        //   BoxShadow(
        //     color: Colors.black.withOpacity(0.25),
        //     blurRadius: 10,
        //     offset: const Offset(0, 6),
        //   ),
        // ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Ink(
            padding: EdgeInsets.all(getWidth(6)),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF1B235C),
                  Color(0xFF1B2153),
                  Color(0xFF13173A),
                ],
              ),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Color(0xFF4103AC),
                width: 1.2,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // ───────── ICON ─────────
                _ToolIcon(tool: tool),
      
                SizedBox(height: getHeight(5)),
      
                // ───────── TITLE ─────────
 // ───────── TITLE ─────────
SizedBox(
  width: double.infinity,
  child: FittedBox(
    fit: BoxFit.scaleDown,
    child: Text(
      tool.title,
      maxLines: 1,
      textAlign: TextAlign.center,
      style: AppTextStyles.bodyLarge.copyWith(
        fontSize: getFont(12),
        fontWeight: FontWeight.w600,
      ),
    ),
  ),
),  
                SizedBox(height: getHeight(1)),
      
                // ───────── SUBTITLE ─────────
                Expanded(
                  child: Text(
                    tool.subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                     textAlign: TextAlign.center,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Color(0xFFD9D9D9),
                      fontSize: getFont(9),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
      
                // ───────── ARROW ─────────
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                    
                    ),
                    child: Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: Color(0xFF9A3CFF),
                      // color: tool.iconColor,
                      size: getWidth(14),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// TOOL ICON
// ─────────────────────────────────────────────────────────────

class _ToolIcon extends StatelessWidget {
  final ToolItem tool;
  
  const _ToolIcon({
    required this.tool,
  });

  @override
  Widget build(BuildContext context) {
      debugPrint('=== imagepath: ${tool.imagepath}');  // ← add karo
    return Container(
      width: getWidth(60),
      height: getWidth(60),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: tool.iconBgColor,
        boxShadow: [
          BoxShadow(
            // color: tool.iconColor.withOpacity(0.22),
            blurRadius: 12,
            spreadRadius: 1,
          ),
        ],
      ),
       child: Center(
  child: tool.imagepath != null
      ? Image.asset(
          tool.imagepath!,
          width: getWidth(25),
          height: getWidth(25),
          fit: BoxFit.contain,

          errorBuilder: (context, error, stackTrace) {
            debugPrint('=== PNG FAILED: ${tool.imagepath}');
            
            return Icon(
              Icons.broken_image,
              color: Colors.red,
              size: getWidth(25),
            );
          },
        )
      : Icon(
          tool.icon,
          color: tool.iconColor,
          size: getWidth(25),
        ),
),
    );
  }
}