import 'package:battery_saver_app/configs/colors/app_colors.dart';
import 'package:battery_saver_app/configs/text_style/text_style.dart';
import 'package:battery_saver_app/utils/SizeConfig.dart';
import 'package:battery_saver_app/utils/app_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class AppItem {
  final String name;
  final String size;
  final Color iconBgColor;
  final String imagepath;

  AppItem({
    required this.name,
    required this.size,
    required this.iconBgColor,
    required this.imagepath,
  });
}

class AppsRunningInBackgroundWidget extends StatefulWidget {
  const AppsRunningInBackgroundWidget({super.key});

  @override
  State<AppsRunningInBackgroundWidget> createState() =>
      _AppsRunningInBackgroundWidgetState();
}

class _AppsRunningInBackgroundWidgetState
    extends State<AppsRunningInBackgroundWidget> {
  final List<AppItem> _apps = [
    AppItem(
      name: 'Instagram',
      size: '135 MB',
      iconBgColor: const Color(0xFFE1306C),
      imagepath: AppIcons.instagramicon,
    ),
    AppItem(
      name: 'YouTube',
      size: '98 MB',
      iconBgColor: const Color(0xFFFF0000),
      imagepath: AppIcons.youtubeicon,
    ),
    AppItem(
      name: 'WhatsApp',
      size: '78 MB',
      iconBgColor: const Color(0xFF25D366),
      imagepath: AppIcons.whatsappicon,
    ),
    AppItem(
      name: 'Facebook',
      size: '64 MB',
      iconBgColor: const Color(0xFF1877F2),
      imagepath: AppIcons.facebookicon,
    ),
  ];

  late List<bool> _selected;

  @override
  void initState() {
    super.initState();
    _selected = List.generate(_apps.length, (_) => true);
  }

  bool get _allSelected => _selected.every((s) => s);

  void _toggleAll() {
    setState(() {
      final newValue = !_allSelected;
      _selected = List.generate(_apps.length, (_) => newValue);
    });
  }

  void _toggleItem(int index) {
    setState(() {
      _selected[index] = !_selected[index];
    });
  }

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
        border: Border.all(
          color: Color(0xFF6C63FF).withOpacity(0.3),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min, 
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Apps Running in Background',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontSize: getFont(16),
                  fontWeight: FontWeight.w600,
                  color: AppColors.textwhitecolor,
                ),
              ),
              GestureDetector(
                onTap: _toggleAll,
                child: Text(
                  'Select All',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: getFont(12),
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF9A3CFF),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: getHeight(4)),

          // App List
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _apps.length,
            itemBuilder: (context, index) {
              final app = _apps[index];
              final isLast = index == _apps.length - 1;
              return Column(
                children: [
                  _AppTile(
                    app: app,
                    isSelected: _selected[index],
                    onTap: () => _toggleItem(index),
                  ),
                  // ✅ Divider sirf icon size ke baad start ho
                  if (!isLast)
                    Padding(
                      padding: EdgeInsets.only(
                        left: getWidth(22) + getWidth(12), // icon width + gap
                      ),
                      child: const Divider(
                        color: Color(0xFF838283),
                        height: 1,
                        thickness: 0.5,
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _AppTile extends StatelessWidget {
  final AppItem app;
  final bool isSelected;
  final VoidCallback onTap;

  const _AppTile({
    required this.app,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            // App Icon
            Container(
              decoration: BoxDecoration(
                color: app.iconBgColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: SvgPicture.asset(
                app.imagepath,
                width: getWidth(22),
                height: getHeight(22),
              ),
            ),

            SizedBox(width: getWidth(12)),

            // App Name & Size
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    app.name,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: getFont(10),
                      fontWeight: FontWeight.w600,
                      color: AppColors.textwhitecolor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    app.size,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: getFont(10),
                      fontWeight: FontWeight.w500,
                      color: AppColors.allsmalltextcolor,
                    ),
                  ),
                ],
              ),
            ),

            // Check Icon
            Icon(
              isSelected
                  ? Icons.check_circle_outline_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: isSelected
                  ? const Color(0xFF4CAF50)
                  : Colors.white.withOpacity(0.3),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}