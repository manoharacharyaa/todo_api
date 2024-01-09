// ignore_for_file: avoid_print

import 'package:flutter/material.dart';

class AppLogic extends ChangeNotifier {
  bool isLoading = false;
  bool isCompleted = false;

  bool loading() {
    isLoading = !isLoading;
    notifyListeners();
    print(isLoading);
    return isLoading;
  }
}
