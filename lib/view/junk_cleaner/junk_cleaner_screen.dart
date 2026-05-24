import 'package:battery_saver_app/configs/text_style/text_style.dart';
import 'package:battery_saver_app/models/junk/junk_item.dart';
import 'package:battery_saver_app/utils/SizeConfig.dart';
import 'package:battery_saver_app/utils/app_images.dart';
import 'package:battery_saver_app/widgets/app_bar/app_bar_widget.dart';
import 'package:battery_saver_app/widgets/junk_cleaner/clean_button_widget.dart';
import 'package:battery_saver_app/widgets/junk_cleaner/junk_list_widget.dart';
import 'package:battery_saver_app/widgets/junk_cleaner/scan_status_widget.dart';
import 'package:flutter/material.dart';

class JunkCleanerScreen extends StatefulWidget {
  const JunkCleanerScreen({super.key});

  @override
  State<JunkCleanerScreen> createState() => _JunkCleanerScreenState();
}

class _JunkCleanerScreenState extends State<JunkCleanerScreen> {
  final List<JunkItem> junkItems =  [
    JunkItem(label: 'Cache Junk', size: '1.25 GB', isChecked: true),
    JunkItem(label: 'Residual Junk', size: '456 MB', isChecked: true),
    JunkItem(label: 'Ad Junk', size: '342 MB', isChecked: true),
    JunkItem(label: 'APK Junk', size: '201 MB', isChecked: true),
    JunkItem(label: 'Memory Junk', size: '82 MB', isChecked: true),
  ];

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    return Scaffold(
      backgroundColor: const Color(0xFF050D2D), 
      appBar: CustomAppBar(title: 'Junk Cleaner'),

      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF050D2D),
              Color(0xFF0A1540),
              Color(0xFF050D2D),
            ],
          ),
        ),

        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const SizedBox(height: 24),

                Image(
                  height: getHeight(226),
                  image: AssetImage(AppImages.junkcleanscreenimage),
                ),

                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '2.34 ',
                        style: AppTextStyles.displayMedium.copyWith(
                          fontSize: getFont(30),
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      TextSpan(
                        text: 'GB',
                        style: AppTextStyles.displayMedium.copyWith(
                          fontSize: getFont(24),
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFD9D9D9),
                        ),
                      ),
                    ],
                  ),
                ),

                Text(
                  "Junk Found",
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontSize: getFont(14),
                    color: const Color(0xFFD9D9D9),
                  ),
                ),

                const SizedBox(height: 32),

                const ScanStatusWidget(
                  scanningText: 'Scanning: com.whatsapp...',
                ),

                const SizedBox(height: 12),

                JunkListWidget(items: junkItems),

                const SizedBox(height: 28),

                CleanButtonWidget(
                  text: "Clean Now",
                  onPressed: () {},
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}