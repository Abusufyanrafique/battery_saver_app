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
 
  // Main menu items
  static const List<_DrawerItem> _mainItems = [
    _DrawerItem('Home', Icons.home_rounded, Color(0xFF6C63FF)),
    _DrawerItem('Junk Cleaner', Icons.delete_outline_rounded, Color(0xFF4CAF50)),
    _DrawerItem('Phone Boost', Icons.bolt_rounded, Color(0xFFFF9800)),
    _DrawerItem('Battery Saver', Icons.battery_charging_full_rounded, Color(0xFF4CAF50)),
    _DrawerItem('CPU Cooler', Icons.thermostat_rounded, Color(0xFF29B6F6)),
    _DrawerItem('Security Scan', Icons.shield_outlined, Color(0xFF4CAF50)),
    _DrawerItem('Notification Cleaner', Icons.notifications_none_rounded, Color(0xFF7E57C2)),
    _DrawerItem('Apps Manager', Icons.apps_rounded, Color(0xFF26C6DA)),
    _DrawerItem('File Manager', Icons.folder_open_rounded, Color(0xFFFFB300)),
    _DrawerItem('Data Usage', Icons.bar_chart_rounded, Color(0xFF42A5F5)),
  ];
 
  // Bottom items
  static const List<_DrawerItem> _bottomItems = [
    _DrawerItem('Settings', Icons.settings_outlined, Color(0xFF90A4AE)),
    _DrawerItem('Feedback', Icons.chat_bubble_outline_rounded, Color(0xFF26C6DA)),
    _DrawerItem('Rate Us', Icons.star_outline_rounded, Color(0xFFFFD54F)),
    _DrawerItem('Share App', Icons.share_rounded, Color(0xFF81C784)),
    _DrawerItem('Privacy Policy', Icons.security_rounded, Color(0xFF7E57C2)),
  ];
 
  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 280,
      backgroundColor: const Color(0xFF0D1B3E),
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
 
                // Divider
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Divider(
                    color: Colors.white.withOpacity(0.1),
                    thickness: 1,
                  ),
                ),
 
                // Bottom items
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
    );
  }
 
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.only(top: 52, left: 20, right: 20, bottom: 20),
      decoration: const BoxDecoration(
        color: Color(0xFF0D1B3E),
      ),
      child: Row(
        children: [
          // Glowing app icon
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFF1A2D6D),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6C63FF).withOpacity(0.5),
                  blurRadius: 16,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(
              Icons.phone_android_rounded,
              color: Color(0xFF6C63FF),
              size: 28,
            ),
          ),
           SizedBox(width: getWidth(14)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               Text(
                'Phone Optimizer',
                style:AppTextStyles.bodyLarge.copyWith(
                  fontSize: getFont(14),
                  fontWeight: FontWeight.w600
                )
              ),
              const SizedBox(height: 2),
              Text(
                'Version 1.0.0',
                 style:AppTextStyles.bodyLarge.copyWith(
                  fontSize: getFont(12),
                  fontWeight: FontWeight.w500,
                  color: Color(0xFFD9D9D9)
                )
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
          splashColor: item.iconColor.withOpacity(0.15),
          highlightColor: item.iconColor.withOpacity(0.08),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFF1A2D6D)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: isSelected
                  ? Border.all(
                      color: item.iconColor.withOpacity(0.25),
                      width: 1,
                    )
                  : null,
            ),
            child: Row(
              children: [
                // Icon container with glow
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: item.iconColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: item.iconColor.withOpacity(0.4),
                              blurRadius: 10,
                              spreadRadius: 1,
                            ),
                          ]
                        : null,
                  ),
                  child: Icon(
                    item.icon,
                    color: item.iconColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 14),
                // Label
                Expanded(
                  child: Text(
                    item.label,
                   style: AppTextStyles.displayMedium.copyWith(
                  fontSize: getFont(12),
                  
     color: isSelected
      ? Colors.white
      : Colors.white,
  fontWeight: isSelected
      ? FontWeight.w500
      : FontWeight.w500,
),
                  ),
                ),
                // Arrow
                Icon(
                  Icons.chevron_right_rounded,
                  color: isSelected
                      ? item.iconColor.withOpacity(0.8)
                      : Colors.white.withOpacity(0.25),
                  size: 20,
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