import 'package:flutter/material.dart';

class GoalsItem{
  int intakeGoal;
  int burnGoal;

  GoalsItem({required this.intakeGoal, required this.burnGoal});
}

class GoalsState extends ChangeNotifier {
  final GoalsItem _goalsItem = GoalsItem(intakeGoal: 2000, burnGoal: 600);

  GoalsItem get goalsItem => _goalsItem;

  int get intakeGoal => goalsItem.intakeGoal;

  int get burnGoal => goalsItem.burnGoal;

  void updateCalorieIntake(int newIntakeGoal) {
    _goalsItem.intakeGoal = newIntakeGoal;
    notifyListeners(); // Notify listeners that the state has changed
  }

  void updateCalorieBurn(int newBurnGoal) {
    _goalsItem.burnGoal = newBurnGoal;
    notifyListeners(); // Notify listeners that the state has changed
  }

}