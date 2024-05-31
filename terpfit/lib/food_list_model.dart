import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'food_item.dart';

class FoodItemsProvider with ChangeNotifier {
  Map<String, List<FoodItem>> _foods = {
    'Breakfast': [],
    'Lunch': [],
    'Dinner': [],
    'Snacks': [],
  };

  DateTime _currentDate = DateTime.now();

  int _totalCalories = 0;

  Map<String, List<FoodItem>> get foods => _foods;
  int get totalCalories => _totalCalories;

  FoodItemsProvider() {
    init();
  }

  Future<void> init() async {
    await loadFoodData(_currentDate);
  }

  void addFood(FoodItem foodItem) async {
    _foods[foodItem.meal]?.add(foodItem);
    _totalCalories += foodItem.calories;
    await _saveFoodData(_currentDate);
    notifyListeners();
  }
  
  Future<void> _saveFoodData(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    final dateKeyFood = _formatDateKeyFood(date);  
    final dateKeyCalories = _formatDateKeyCalories(date);  

    Map<String, dynamic> encodedFoods = _foods.map((meal, items) {
      return MapEntry(meal, items.map((item) => item.toJson()).toList());
    });

    String foodData = json.encode(encodedFoods);

    await prefs.setString(dateKeyFood, foodData);
    await prefs.setInt(dateKeyCalories, _totalCalories);

  }


  Future<void> loadFoodData(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    final dateKeyFood = _formatDateKeyFood(date);  
    final dateKeyCalories = _formatDateKeyCalories(date);  

    String? foodJson = prefs.getString(dateKeyFood);
    int? calories = prefs.getInt(dateKeyCalories);

    if (kDebugMode) {
      print("current calories $calories");
      print("current food serialized: $foodJson");
    }

    if (calories != null) {
      _totalCalories = calories;
    } else {
      _totalCalories = 0;  
    }

    _foods = {
      'Breakfast': [],
      'Lunch': [],
      'Dinner': [],
      'Snacks': [],
    };
    
    if (foodJson != null) {
      final foodMap = json.decode(foodJson) as Map<String, dynamic>;

      foodMap.forEach((meal, items) {
        final foodItems = (items as List<dynamic>)
            .map((item) => FoodItem.fromJson(item as Map<String, dynamic>))
            .toList();
        if (_foods.containsKey(meal)) {
          _foods[meal]!.addAll(foodItems);
        } else {
          _foods[meal] = foodItems;
        }
      });
      notifyListeners();  
    }
  }


  // have not implemented a button for removing foods yet
  void removeFood(String name, String meal) {
    final List<FoodItem>? mealFoods = _foods[meal];
    if (mealFoods != null) {
      final index = mealFoods.indexWhere((foodItem) => foodItem.name == name);
      if (index != -1) {
        _totalCalories -= mealFoods[index].calories;
        mealFoods.removeAt(index);
        _saveFoodData(_currentDate);
        notifyListeners();
      }
    }
  }

  void updateCurrentDate(DateTime newDate) async {
    if (_currentDate != newDate) {
      if (kDebugMode) {
        print("updating date from $_currentDate to $newDate");
      }
      await _saveFoodData(_currentDate);
      _currentDate = newDate;
      await loadFoodData(newDate);
      notifyListeners();
    }
  }

  String _formatDateKeyFood(DateTime date) {
    return "foods_${date.year}_${date.month}_${date.day}";
  }
  String _formatDateKeyCalories(DateTime date) {
    return "total_calories_${date.year}_${date.month}_${date.day}";
  }
}