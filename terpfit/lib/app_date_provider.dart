import 'package:flutter/material.dart';

class AppDateProvider extends ChangeNotifier {
  DateTime _currentDate = DateTime.now();

  DateTime get currentDate => _currentDate;

  void changeDate(DateTime newDate) {
    if (_currentDate != newDate) {
      _currentDate = newDate;
      notifyListeners();
    }
  }
}