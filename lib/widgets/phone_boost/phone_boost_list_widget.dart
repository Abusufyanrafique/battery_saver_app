import 'package:battery_saver_app/configs/colors/app_colors.dart';
import 'package:battery_saver_app/configs/text_style/text_style.dart';
import 'package:battery_saver_app/utils/SizeConfig.dart';
import 'package:battery_saver_app/utils/app_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class PhoneBoostListWidget extends StatelessWidget {
  const PhoneBoostListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
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
          color: const Color(0xFF4103AC),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisSize: MainAxisSize.min, //  Content ke mutabiq shrink ho
          children:  [
            PhoneBoostTile(title: "WhatsApp",       status: "128 MB",  svgicon: AppIcons.whatsappicon,),
            Divider(color: Color(0xFF373C62), height: 1),
            PhoneBoostTile(title: "Facebook",     status: "96 MB", svgicon: AppIcons.facebookicon,),
            Divider(color: Color(0xFF373C62), height: 1),
            PhoneBoostTile(title: "Instagram",        status: "72 MB",      svgicon:AppIcons.instagramicon ,),
            Divider(color: Color(0xFF373C62), height: 1),
            PhoneBoostTile(title: "YouTube",    status: "64 MB",svgicon: AppIcons.youtubeicon,),
            Divider(color: Color(0xFF373C62), height: 1),
            PhoneBoostTile(title: "Others",  status: "256 MB", svgicon:"AppIcons.i ",),
          ],
        ),
      ),
    );
  }
}



class PhoneBoostTile extends StatelessWidget {
  final String title;
  final String status;
  final String svgicon;

  const PhoneBoostTile({
    super.key,
    required this.title,
    required this.status,
    required this.svgicon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [

          //  SINGLE IMAGE (FIXED)
          SizedBox(
  width: getWidth(26),
  height: getHeight(26),
  child: Container(
    child: SvgPicture.asset(
      svgicon,
      // fit: BoxFit.cover,
    ),
  ),
),


           SizedBox(width: getWidth(12)),

          //  TITLE + STATUS
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: getFont(14),
                      fontWeight: FontWeight.w500,
                      color: AppColors.textwhitecolor
                    )
                  ),
                ),

                 SizedBox(width: getWidth(8)),

                Text(
                  status,
                  style:AppTextStyles.bodySmall.copyWith(
                    fontSize: getFont(12),
                    fontWeight: FontWeight.w500,
                    color: AppColors.allsmalltextcolor
                  )
                ),
              ],
            ),
          ),

           SizedBox(width: getWidth(12)),

          //  CHECK BUTTON
          Container(
            width: getWidth(24),
            height: getHeight(24),
            decoration: BoxDecoration(
              color: const Color(0xFF1C2A8F),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(
              Icons.check,
              size: 14,
              color: Color(0xFF55D0FF),
            ),
          ),
        ],
      ),
    );
  }
}