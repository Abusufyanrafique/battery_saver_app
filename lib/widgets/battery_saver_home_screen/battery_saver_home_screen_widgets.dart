import 'package:battery_saver_app/configs/text_style/text_style.dart';
import 'package:battery_saver_app/utils/SizeConfig.dart';
import 'package:battery_saver_app/utils/app_icons.dart';
import 'package:battery_saver_app/utils/app_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

// ─── Enums & Model ────────────────────────────────────────────────────────────

enum SaverMode { smart, ultra, custom }

class SaverOption {
  final SaverMode mode;
  final String title;
  final String subtitle;
  final String svgPath;

  const SaverOption({
    required this.mode,
    required this.title,
    required this.subtitle,
    required this.svgPath,
  });
}

// ─── Constants ────────────────────────────────────────────────────────────────

const _kActiveIcon = Color(0xFFFE39C6);
const _kActiveRadio = Color(0xFFFE39C6);
const _kInactiveRadio = Color(0xFF4A4F8A);

// ─── OPTIONS ────────────────────────────────────────────────────────────────

List<SaverOption> _options = [
  SaverOption(
    mode: SaverMode.smart,
    title: AppText.smartSaver,
    subtitle: AppText.settingsbasedbatterylevel,
    svgPath: AppIcons.smarticon,
  ),
  SaverOption(
    mode: SaverMode.ultra,
    title: AppText.ultraSaver,
    subtitle: AppText.backgroundactivitynotifications,
    svgPath: AppIcons.ultarsaver,
  ),
  SaverOption(
    mode: SaverMode.custom,
    title: AppText.customSaver,
    subtitle: AppText.whichfeaturesoptimize,
    svgPath: AppIcons.customsaver,
  ),
];

// ─── MAIN CARD ────────────────────────────────────────────────────────────────

class BatterySaverModeCard extends StatelessWidget {
  final SaverMode selected;
  final ValueChanged<SaverMode> onChanged;

  const BatterySaverModeCard({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(color: const Color(0xFF4103AC), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Text(
              AppText.batterySaverMode,
              style: AppTextStyles.bodyLarge.copyWith(
                fontSize: getFont(16),
                color: Colors.white,
              ),
            ),
          ),
          const Divider(
            color: Color(0xFF838283),
            thickness: 1,
            height: 1,
            endIndent: 16,
            indent: 16,
          ),

          ...List.generate(_options.length, (index) {
            final option = _options[index];
            final isLast = index == _options.length - 1;

            return Column(
              children: [
                _SaverOptionTile(
                  option: option,
                  isSelected: selected == option.mode,
                  onTap: () => onChanged(option.mode),
                ),
                if (!isLast)
                  const Divider(
                    color: Color(0xFF838283),
                    thickness: 1,
                    height: 1,
                    endIndent: 16,
                    indent: 16,
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }
}

// ─── TILE ────────────────────────────────────────────────────────────────

class _SaverOptionTile extends StatelessWidget {
  final SaverOption option;
  final bool isSelected;
  final VoidCallback onTap;

  const _SaverOptionTile({
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final radioColor = isSelected ? _kActiveRadio : _kInactiveRadio;

    // Icon container colors
    final iconBgColor = isSelected ? const Color(0xFFC563A9) : const Color(0xFF232C6D);
    final iconBorderColor = isSelected ? const Color(0xFFFE39C6) : const Color(0xFF4103AC);

    return InkWell(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            // ── SVG ICON ─────────────────────────────
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              width: getWidth(40),
              height: getHeight(40),
              decoration: BoxDecoration(
                color: iconBgColor,
                shape: BoxShape.circle,
                border: Border.all(color: iconBorderColor),
              ),
              child: Center(
                child: SvgPicture.asset(
                  option.svgPath,
                  width: getWidth(20),
                  height: getHeight(20),
                  colorFilter: ColorFilter.mode(
                    isSelected ? _kActiveIcon : const Color(0xFF989CDF),
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),

             SizedBox(width: 14),

            // TEXT
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    option.title,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: getFont(12),
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    option.subtitle,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: getFont(10),
                      color: const Color(0xFFD9D9D9),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            // RADIO
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              width: getWidth(14),
              height: getHeight(14),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: radioColor,
                  width: isSelected ? 0 : 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: getWidth(6),
                        height: getHeight(6),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFFFE39C6),
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}