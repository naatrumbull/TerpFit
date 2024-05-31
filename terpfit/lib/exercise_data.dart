import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'exercise_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ExerciseData extends ChangeNotifier {
  List<Exercise> _exerciseList = [];

  DateTime _currentDate = DateTime.now();

  int _totalCalories = 0;

  ExerciseData() {
    init();
  }

  Future<void> init() async {
    await loadExercises(_currentDate);
  }

  List<Exercise> get exercises => List.unmodifiable(_exerciseList);
  int get totalCalories => _totalCalories;

  void addExercise(Exercise exercise) {
    _exerciseList.insert(0, exercise);
    _updateCalories();
    notifyListeners();
    _saveExercises(_currentDate);
  }

  Future<bool> _saveExercises(DateTime date) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final exerciseData = jsonEncode(_exerciseList.map((exercise) => exercise.toJson()).toList());
      final dateKey = _formatDateKey(date);
      final caloriesKey = _formatCaloriesKey(date);
      if (kDebugMode) {
        print("saving at key $dateKey");
      }
      bool savedExercises = await prefs.setString(dateKey, exerciseData);
      bool savedCalories = await prefs.setInt(caloriesKey, _totalCalories);

      return savedCalories && savedExercises;
    
    } catch (e) {
      if (kDebugMode) {
        print('Failed to save exercises: $e');
      }
      return false;
    }
  }

  Future<void> loadExercises(DateTime date) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final key = _formatDateKey(date);
      final storedData = prefs.getString(key);
      final caloriesKey = _formatCaloriesKey(date);
      final calories = prefs.getInt(caloriesKey);
      if (calories != null) {
        _totalCalories = calories;
      } else {
        _totalCalories = 0;
      }
      if (kDebugMode) {
        print("loading at $key, $storedData");
      }
      if (storedData != null) {
        final List<dynamic> jsonData = jsonDecode(storedData);
        _exerciseList = jsonData.map((data) => Exercise.fromJson(data)).toList();
      } else {
        _exerciseList = [];
      }

    } catch (e) {
      if (kDebugMode) {
        print('Failed to load exercises: $e');
      }
    }
  }

  void deleteExercise(Exercise targetExercise) {
    _exerciseList.remove(targetExercise);
    _saveExercises(_currentDate);
    _updateCalories();
    notifyListeners();
  }

  String _formatDateKey(DateTime date) {
    return 'exercises_${date.year}_${date.month}_${date.day}';
  }

  Future<void> updateCurrentDate(DateTime newDate) async {
    if (_currentDate != newDate) {
      if (kDebugMode) {
        print("updating date from $_currentDate to $newDate");
      }
      await _saveExercises(_currentDate);  
      _currentDate = newDate; 
      await loadExercises(_currentDate);
      notifyListeners();
    }
  }

  void _updateCalories() {
    _totalCalories = 0;
    for (Exercise e in _exerciseList) {
      if (e.calories != null) {
        _totalCalories += int.parse(e.calories!);
      }
    }
  }
  String _formatCaloriesKey(DateTime date) {
    return 'exercise_calories_${date.year}_${date.month}_${date.day}';
  }
}
