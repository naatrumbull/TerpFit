class FoodItem {
  String name;
  int calories;
  String meal;

  FoodItem({required this.name, required this.calories, required this.meal});

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'calories': calories,
      'meal': meal,
    };
  }

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      name: json['name'],
      calories: json['calories'],
      meal: json['meal'],
    );
  }
}