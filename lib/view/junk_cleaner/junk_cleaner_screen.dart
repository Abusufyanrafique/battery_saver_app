import 'package:battery_saver_app/bloc/junk_cleaner/junk_bloc.dart';
import 'package:battery_saver_app/bloc/junk_cleaner/junk_event.dart';
import 'package:battery_saver_app/bloc/junk_cleaner/junk_state.dart';
import 'package:battery_saver_app/configs/colors/app_colors.dart';
import 'package:battery_saver_app/configs/text_style/text_style.dart';
import 'package:battery_saver_app/utils/SizeConfig.dart';
import 'package:battery_saver_app/utils/app_images.dart';
import 'package:battery_saver_app/utils/app_text.dart';
import 'package:battery_saver_app/widgets/app_bar/app_bar_widget.dart';
import 'package:battery_saver_app/widgets/junk_cleaner/clean_button_widget.dart';
import 'package:battery_saver_app/widgets/junk_cleaner/junk_list_widget.dart';
import 'package:battery_saver_app/widgets/junk_cleaner/scan_status_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class JunkCleanerScreen extends StatelessWidget {
  const JunkCleanerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => JunkBloc()..add(StartScanEvent()),
      child: const _JunkCleanerView(),
    );
  }
}

class _JunkCleanerView extends StatelessWidget {
  const _JunkCleanerView();

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    return Scaffold(
        extendBodyBehindAppBar: false,
      backgroundColor: AppColors.allscreenBackgroundColor,
      appBar: CustomAppBar(title: AppText.appBarTitle),
      body: Container(
        child: SafeArea(
          child: BlocBuilder<JunkBloc, JunkState>(
            builder: (context, state) {
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    SizedBox(height: getHeight(24)),

                    Image(
                      height: getHeight(226),
                      image: AssetImage(AppImages.junkcleanerglow),
                    ),

                    SizedBox(height: getHeight(51)),

                    // Dynamic total size
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: state.totalJunkDisplay.split(' ')[0],
                            style: AppTextStyles.displayMedium.copyWith(
                              fontSize: getFont(30),
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          TextSpan(
                            text: ' ${state.totalJunkDisplay.contains(' ')
                                ? state.totalJunkDisplay.split(' ')[1]
                                : ''}',
                            style: AppTextStyles.displayMedium.copyWith(
                              fontSize: getFont(24),
                              fontWeight: FontWeight.w600,
                              color: AppColors.allsmalltextcolor
                            ),
                          ),
                        ],
                      ),
                    ),

                    Text(
                      state.phase == ScanPhase.cleaned
                          ? AppText.cleanedSuccessfully
                          : AppText.junkFoundLabel,
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontSize: getFont(14),
                        color: state.phase == ScanPhase.cleaned
                            ? AppColors.cleansuccesfullytextcolor
                            : AppColors.allsmalltextcolor
                      ),
                    ),

                    SizedBox(height: getHeight(51)),

                    ScanStatusWidget(
                      phase: state.phase,
                      currentPackage: state.currentPackage,
                    ),

                    SizedBox(height: getHeight(12)),

                    // Scanning loader
                    if (state.phase == ScanPhase.scanning)
                      const Padding(
                        padding: EdgeInsets.only(bottom: 12),
                        child: LinearProgressIndicator(
                          backgroundColor: Color(0xFF1B2153),
                          color: Color(0xFF55D0FF),
                        ),
                      ),

                    JunkListWidget(
                      items: state.items,
                      onToggle: (index) => context
                          .read<JunkBloc>()
                          .add(ToggleJunkItemEvent(index)),
                    ),

                    SizedBox(height: getHeight(24)),

                    CleanButtonWidget(
                      text: state.phase == ScanPhase.cleaning
                          ? AppText.cleaning
                          : state.phase == ScanPhase.cleaned
                              ?AppText.donejunktext
                              : AppText.cleanButtonText,
                      onPressed: state.phase == ScanPhase.done
                          ? () => context
                              .read<JunkBloc>()
                              .add(CleanJunkEvent())
                          : null,
                    ),

                    SizedBox(height: getHeight(24)),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}