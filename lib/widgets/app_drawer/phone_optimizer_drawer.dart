// ─────────────────────────────────────────────
//  MAIN DRAWER WIDGET
// ─────────────────────────────────────────────
import 'package:battery_saver_app/configs/text_style/text_style.dart';
import 'package:battery_saver_app/utils/SizeConfig.dart';
import 'package:flutter/material.dart';

class PhoneOptimizerDrawer extends StatelessWidget {
  final String selectedItem;
  final ValueChanged<String> onItemSelected;

  const PhoneOptimizerDrawer({
    super.key,
    required this.selectedItem,
    required this.onItemSelected,
  });

  static final List<_DrawerItem> _mainItems = [
    _DrawerItem('Home', Icons.home_rounded, Color(0xFF9A3CFF).withOpacity(0.20)),
    _DrawerItem('Junk Cleaner', Icons.delete_outline_rounded, Color(0xFF2FE55D).withOpacity(0.20)),
    _DrawerItem('Phone Boost', Icons.bolt_rounded, Color(0xFF55D0FF).withOpacity(0.20)),
    _DrawerItem('Battery Saver', Icons.battery_charging_full_rounded, Color(0xFF00FF09).withOpacity(0.20)),
    _DrawerItem('CPU Cooler', Icons.thermostat_rounded, Color(0xFF1F8EFF).withOpacity(0.20)),
    _DrawerItem('Security Scan', Icons.shield_outlined, Color(0xFF69FF89).withOpacity(0.20)),
    _DrawerItem('Notification Cleaner', Icons.notifications_none_rounded, Color(0xFF891BFF).withOpacity(0.20)),
    _DrawerItem('Apps Manager', Icons.apps_rounded, Color(0xFF37C8FF).withOpacity(0.20)),
    _DrawerItem('File Manager', Icons.folder_open_rounded, Color(0xFFF3D917).withOpacity(0.20)),
    _DrawerItem('Data Usage', Icons.bar_chart_rounded, Color(0xFF27C3FE).withOpacity(0.20)),
  ];

  static final List<_DrawerItem> _bottomItems = [
    _DrawerItem('Settings', Icons.settings_outlined, Color(0xFF989CDF).withOpacity(0.20)),
    _DrawerItem('Feedback', Icons.chat_bubble_outline_rounded, Color(0xFF7075C9).withOpacity(0.20)),
    _DrawerItem('Rate Us', Icons.star_outline_rounded, Color(0xFFFFDD55).withOpacity(0.20)),
    _DrawerItem('Share App', Icons.share_rounded, Color(0xFF989CDF).withOpacity(0.20)),
    _DrawerItem('Privacy Policy', Icons.security_rounded, Color(0xFF878DF1).withOpacity(0.20)),
  ];

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 280,

      // ✔️ ONLY CHANGE: BACKGROUND GRADIENT ADDED
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF232C6D),
              Color(0xFF1B2153),
              Color(0xFF13173A),
            ],
          ),
        ),

        child: Column(
          children: [
            // ── Header ──────────────────────────────
            _buildHeader(),

            // ── Main menu ───────────────────────────
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  const SizedBox(height: 8),

                  ..._mainItems.map(
                    (item) => _DrawerTile(
                      item: item,
                      isSelected: selectedItem == item.label,
                      onTap: () => onItemSelected(item.label),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Divider(
                      color: Color(0xFF373C62),
                      thickness: 1,
                    ),
                  ),

                  ..._bottomItems.map(
                    (item) => _DrawerTile(
                      item: item,
                      isSelected: selectedItem == item.label,
                      onTap: () => onItemSelected(item.label),
                    ),
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.only(top: 52, left: 20, right: 20, bottom: 20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(1.5),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  Color(0xFF55D0FF),
                  Color(0xFF9A3CFF),
                  Color(0xFF1C2A8F),
                ],
              ),
            ),
            child: Container(
              width: getWidth(40),
              height: getHeight(40),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF232C6D),
                    Color(0xFF1B2153),
                    Color(0xFF13173A),
                  ],
                ),
              ),
              child: const Icon(
                Icons.phone_android_rounded,
                color: Color(0xFF55D0FF),
                size: 20,
              ),
            ),
          ),

          SizedBox(width: getWidth(14)),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Phone Optimizer',
                style: AppTextStyles.bodyLarge.copyWith(
                  fontSize: getFont(14),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Version 1.0.0',
                style: AppTextStyles.bodyLarge.copyWith(
                  fontSize: getFont(12),
                  fontWeight: FontWeight.w500,
                  color: Color(0xFFD9D9D9),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  DRAWER TILE
// ─────────────────────────────────────────────
class _DrawerTile extends StatelessWidget {
  final _DrawerItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const _DrawerTile({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFF1B235C),
                        Color(0xFF1B2153),
                        Color(0xFF13173A),
                      ],
                    )
                  : null,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: item.iconColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    item.icon,
                    color: item.iconColor,
                    size: 20,
                  ),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: Text(
                    item.label,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                    ),
                  ),
                ),

                Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.white.withOpacity(0.25),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  DATA MODEL
// ─────────────────────────────────────────────
class _DrawerItem {
  final String label;
  final IconData icon;
  final Color iconColor;

  const _DrawerItem(this.label, this.icon, this.iconColor);
}