import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OnboardingCubit extends Cubit<int> {
  OnboardingCubit() : super(0);

  void changePage(int index) => emit(index);

  void nextPage(PageController controller) {
    if (state < 2) {
      controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    }
  }

  void skip(PageController controller) {
    controller.animateToPage(
      2,
      duration: const Duration(milliseconds: 300),
      curve: Curves.ease,
    );
  }
}