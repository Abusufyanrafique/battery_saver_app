// tools_screen.dart

import 'package:battery_saver_app/bloc/battery_saver/battery_saver_bloc.dart';
import 'package:battery_saver_app/configs/colors/app_colors.dart';
import 'package:battery_saver_app/configs/text_style/text_style.dart';
import 'package:battery_saver_app/models/tools/quick_widget_item.dart';
import 'package:battery_saver_app/utils/SizeConfig.dart';
import 'package:battery_saver_app/utils/app_text.dart';
import 'package:battery_saver_app/widgets/tools/quick_widget_card.dart';
import 'package:battery_saver_app/widgets/tools/tool_card_widget.dart';
import 'package:battery_saver_app/widgets/tools/tools_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class ToolsScreen extends StatelessWidget {
  const ToolsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      backgroundColor: AppColors.allscreenBackgroundColor,
      appBar: ToolsAppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children:  [
              _ToolsGrid(),
              SizedBox(height: getHeight(20)),
              _QuickWidgetsSection(),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFF0F1628),
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(
          Icons.chevron_left_rounded,
          color: Colors.white,
          size: 30,
        ),
        onPressed: () => Navigator.maybePop(context),
      ),
      actions: const [
        Padding(
          padding: EdgeInsets.only(right: 12),
          child: Center(
            child: _PremiumBadge(),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// TOOLS GRID
// ─────────────────────────────────────────────────────────────

class _ToolsGrid extends StatelessWidget {
  const _ToolsGrid();

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: toolsData.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 0.82,
      ),
      itemBuilder: (context, index) {
        final tool = toolsData[index];
        return ToolCardWidget(
          tool: tool,
          onTap: () {
            if (tool.onTap != null) {
              tool.onTap!(context);
            } else if (tool.route != null && tool.route!.isNotEmpty) {
              context.push(tool.route!);
            }
          },
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────
// QUICK WIDGETS SECTION
// ─────────────────────────────────────────────────────────────

class _QuickWidgetsSection extends StatelessWidget {
  const _QuickWidgetsSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Color(0xFF07082C),
            Color(0xFF0C27A7),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppText.quickWidgets,
            style: AppTextStyles.bodySmall.copyWith(
              fontSize: getFont(12),
              fontWeight: FontWeight.w600,
              color: AppColors.textwhitecolor,
            ),
          ),

          SizedBox(height: getHeight(16)),

          // BlocBuilder — sirf battery percentage ke liye rebuild hoga
          BlocBuilder<BatterySaverBloc, BatterySaverState>(
            buildWhen: (prev, curr) =>
                prev.batteryLevel != curr.batteryLevel,
            builder: (context, batteryState) {
              // Battery item mein real level inject karo
              final items = quickWidgetsData.map((item) {
                if (item.label == AppText.batterytext) {
                  return QuickWidgetItem(
                    label:       item.label,
                    svgIcon:     item.svgIcon,
                    borderColor: item.borderColor,
                    color:       item.color,
                    percentage:  batteryState.batteryLevel, //  real value
                  );
                }
                //  BOOST dynamic (LAST CARD)
  if (item.label == AppText.boost) {
    final boostValue = 100 - batteryState.batteryLevel;

    return QuickWidgetItem(
      label: item.label,
      svgIcon: item.svgIcon,
      borderColor: item.borderColor,
      color: item.color,
      percentage: boostValue, // REAL BOOST VALUE
    );
  }
                return item;
              }).toList();

              return Row(
                children: List.generate(
                  items.length,
                  (index) {
                    final item = items[index];
                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                          right: index == items.length - 1 ? 0 : 10,
                        ),
                        child: QuickWidgetCard(
                          item: item,
                          onTap: () {
                            debugPrint('Quick Widget: ${item.label}');
                          },
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// PREMIUM BADGE
// ─────────────────────────────────────────────────────────────

class _PremiumBadge extends StatelessWidget {
  const _PremiumBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: const Color(0xFFD4A017),
          width: 1.3,
        ),
        gradient: LinearGradient(
          colors: [
            const Color(0xFFD4A017).withOpacity(0.15),
            Colors.transparent,
          ],
        ),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '👑',
            style: TextStyle(fontSize: 13),
          ),
          SizedBox(width: 5),
          Text(
            'Premium',
            style: TextStyle(
              color: Color(0xFFD4A017),
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}