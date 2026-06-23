import 'package:battery_saver_app/bloc/app_manager/app_manager_bloc.dart'; // ← sirf yeh
import 'package:battery_saver_app/configs/colors/app_colors.dart';
import 'package:battery_saver_app/configs/text_style/text_style.dart';
import 'package:battery_saver_app/utils/SizeConfig.dart';
import 'package:battery_saver_app/utils/app_text.dart';
import 'package:flutter/material.dart';

class AppListTile extends StatelessWidget {
  final dynamic app;
  final VoidCallback onToggle;
  final bool showDivider;
  final bool isApkMode;

  const AppListTile({
    super.key,
    required this.app,
    required this.onToggle,
    this.showDivider = true,
    this.isApkMode = false,
  });

  String get _name => app.name as String;
  String get _size => app.formattedSize as String;
  bool get _isSelected => app.isSelected as bool;

  String get _version {
    if (isApkMode) return (app as ApkFileModel).version;
    return (app as RealAppModel).versionName ?? '';
  }

  Widget _buildIcon() {
    if (!isApkMode) {
      final model = app as RealAppModel;
      if (model.icon != null) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.memory(
            model.icon!,
            width: getWidth(36),
            height: getHeight(36),
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => _fallbackIcon(),
          ),
        );
      }
    }
    return _fallbackIcon();
  }

  Widget _fallbackIcon() {
    return Container(
      width: getWidth(36),
      height: getHeight(36),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white.withOpacity(0.05),
      ),
      child: const Icon(Icons.android, color: Colors.white54, size: 20),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              _buildIcon(),
              SizedBox(width: getWidth(12)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _name,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: getFont(14),
                        color: AppColors.textwhitecolor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: getHeight(2)),
                    if (isApkMode)
                      Row(
                        children: [
                          Text(
                            'Version $_version',
                            style: AppTextStyles.bodySmall.copyWith(
                              fontSize: getFont(11),
                              color: AppColors.allsmalltextcolor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(width: getWidth(6)),
                          Text(
                            _size,
                            style: AppTextStyles.bodySmall.copyWith(
                              fontSize: getFont(11),
                              color: AppColors.allsmalltextcolor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      )
                    else
                      Text(
                        _size,
                        style: AppTextStyles.bodySmall.copyWith(
                          fontSize: getFont(11),
                          color: AppColors.allsmalltextcolor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
              ),
              SizedBox(width: getWidth(8)),
              if (isApkMode) ...[
                GestureDetector(
                  onTap: onToggle,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.checkiconcolor, width: 1.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      AppText.install,
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: getFont(12),
                        color: AppColors.checkiconcolor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: getWidth(4)),
                const Icon(Icons.more_vert, 
                color: AppColors.allsmalltextcolor, 
                size: 20
                ),
              ] else ...[
                GestureDetector(
                  onTap: onToggle,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: getWidth(20),
                    height: getHeight(20),
                    decoration: BoxDecoration(
                      color: _isSelected ? AppColors.animatedboxcoloractive : Colors.transparent,
                      border: Border.all(color: AppColors.checkboxbodercolor, width: 1.5),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: _isSelected
                        ?  Icon(Icons.check, color: AppColors.white, size: 14)
                        : null,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (showDivider)
          Padding(
            padding: EdgeInsets.only(left: getWidth(60)),
            child: Divider(
              color: AppColors.divider,
              height: 1,
              thickness: 1,
            ),
          ),
      ],
    );
  }
}