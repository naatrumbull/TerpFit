import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:terpfit/food_list_model.dart';  
import 'package:terpfit/food_item.dart';        

class MockSharedPreferences extends Mock implements SharedPreferences {}
class MockFoodItemsProvider extends Mock implements FoodItemsProvider {}

void main() {
  test(
    'testing sharedpreferences',
    () {
      final item = FoodItem(name: "test", calories: 100, meal: "Breakfast");
      final json = item.toJson();
      print("Serialized to JSOn, $json");

      final itemFromJson = FoodItem.fromJson(json);
      print("Deserialized from JSON: ${itemFromJson.name}, ${itemFromJson.calories}, ${itemFromJson.meal}");
    }
  );
}
