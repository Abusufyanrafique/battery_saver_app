import 'package:battery_saver_app/utils/app_images.dart';
import 'package:flutter/material.dart';

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
          children: const [
            PhoneBoostTile(title: "WhatsApp",       status: "128 MB",   image:AppImages.whatsapp),
            Divider(color: Color(0xFF373C62), height: 1),
            PhoneBoostTile(title: "Facebook",     status: "96 MB", image: AppImages.facebook),
            Divider(color: Color(0xFF373C62), height: 1),
            PhoneBoostTile(title: "Instagram",        status: "72 MB",      image:AppImages.instagram),
            Divider(color: Color(0xFF373C62), height: 1),
            PhoneBoostTile(title: "YouTube",    status: "64 MB",     image: AppImages.youtube),
            Divider(color: Color(0xFF373C62), height: 1),
            PhoneBoostTile(title: "Others",  status: "256 MB",    image: AppImages.others),
          ],
        ),
      ),
    );
  }
}



class PhoneBoostTile extends StatelessWidget {
  final String title;
  final String status;
  final String image;

  const PhoneBoostTile({
    super.key,
    required this.title,
    required this.status,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [

          // 👉 SINGLE IMAGE (FIXED)
          SizedBox(
            width: 26,
            height: 26,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 1,
                ),
                image: DecorationImage(
                  image: AssetImage(image),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // 👉 TITLE + STATUS
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                Text(
                  status,
                  style: const TextStyle(
                    color: Color(0xFFD9D9D9),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // 👉 CHECK BUTTON
          Container(
            width: 24,
            height: 24,
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