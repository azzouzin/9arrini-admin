import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final menuIndexProvider = StateProvider<int>((ref) => 0);
final pageControllerProvider = StateProvider<PageController>((ref) => PageController(initialPage: 0, keepPage: true));

void onMenuTap(context, WidgetRef ref, int newIndex, int listIndex, GlobalKey<ScaffoldState> scaffoldKey) {
  ref.read(menuIndexProvider.notifier).update((state) => listIndex);
  bool shouldAnimate = _shouldAnimate(listIndex, newIndex);
  if (shouldAnimate) {
    ref.read(pageControllerProvider.notifier).state.animateToPage(listIndex, duration: const Duration(milliseconds: 250), curve: Curves.ease);
  } else {
    ref.read(pageControllerProvider.notifier).state.jumpToPage(listIndex);
  }
  if (scaffoldKey.currentState!.isDrawerOpen) {
    Navigator.pop(context);
  }
}

bool _shouldAnimate(int currentIndex, int newIndex) {
  int dif = currentIndex - newIndex;
  if (dif > 1 || dif < -1) {
    return false;
  } else {
    return true;
  }
}
