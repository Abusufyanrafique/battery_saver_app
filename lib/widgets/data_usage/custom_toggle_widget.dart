import 'package:flutter/material.dart';
import 'package:battery_saver_app/configs/text_style/text_style.dart';
import 'package:battery_saver_app/utils/SizeConfig.dart';

enum ToggleOption { today, thisMonth }

class CustomToggleWidget extends StatefulWidget {
  const CustomToggleWidget({super.key});

  @override
  State<CustomToggleWidget> createState() => _CustomToggleWidgetState();
}

class _CustomToggleWidgetState extends State<CustomToggleWidget> {
  ToggleOption _selected = ToggleOption.today;

  void _onToggle(ToggleOption option) {
    setState(() => _selected = option);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: getHeight(60),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1535),
        gradient: LinearGradient(colors: [
          Color(0xFF232C6D),
          Color(0xFF1B2153),
          Color(0xFF13173A),
        ]),
        borderRadius: BorderRadius.circular(30),
      ),
      padding: const EdgeInsets.all(2),
      child: Stack(
        children: [
          AnimatedAlign(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            alignment: _selected == ToggleOption.today
                ? Alignment.centerLeft
                : Alignment.centerRight,
            child: FractionallySizedBox(
              widthFactor: 0.5,
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF55D0FF),
                      Color(0xFF0E5AA7),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),

                  borderRadius: BorderRadius.circular(30),

                  //  Shadow from your design
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.25),
                      offset: const Offset(0, 2),
                      blurRadius: 4,
                      spreadRadius: 0,
                    ),
                    BoxShadow(
                      color: const Color(0xFF55D0FF).withOpacity(0.25),
                      offset: const Offset(0, 2),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
            ),
          ),

          //  Labels
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => _onToggle(ToggleOption.today),
                  child: Center(
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 250),
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontSize: getFont(20),
                        fontWeight: FontWeight.w600,
                        color: _selected == ToggleOption.today
                            ? Colors.white
                            : const Color(0xFF8A9BC5),
                      ),
                      child: const Text('Today'),
                    ),
                  ),
                ),
              ),

              Expanded(
                child: GestureDetector(
                  onTap: () => _onToggle(ToggleOption.thisMonth),
                  child: Center(
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 250),
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontSize: getFont(20),
                        fontWeight: FontWeight.w600,
                        color: _selected == ToggleOption.thisMonth
                            ? Colors.white
                            : const Color(0xFFD9D9D9),
                      ),
                      child: const Text('This Month'),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}