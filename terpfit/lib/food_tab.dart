import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:terpfit/app_date_provider.dart';
import 'add_food_tab.dart';
import 'food_list_model.dart';
import 'food_item.dart';
import 'package:intl/intl.dart';

class FoodTab extends StatelessWidget {
  const FoodTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Consumer<AppDateProvider>(
          builder: (context, dateProvider, _) {
            String formattedDate = DateFormat('EEEE, MMMM d').format(dateProvider.currentDate);
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  formattedDate,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Consumer<FoodItemsProvider>(
                  builder: (context, foodProvider, _) {
                    final totalCalories = foodProvider.totalCalories;
                    return Text(
                      'Total Calories: $totalCalories',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    );
                  },
                ),
              ],
            );
          },
        )
        
      ),
      body: _buildFoodList(context),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AddFoodPage()),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
  
 

  Widget _buildFoodList(BuildContext context) {
  final foodProvider = Provider.of<FoodItemsProvider>(context);
  final foods = foodProvider.foods;

  return ListView.builder(
    itemCount: foods.length,
    itemBuilder: (context, index) {
      String meal = foods.keys.elementAt(index);
      List<FoodItem> mealFoods = foods[meal]!;
      return ExpansionTile(
        title: Text(meal, style: const TextStyle(fontWeight: FontWeight.bold)),
        children: mealFoods.map((food) {
          return Dismissible(
            key: Key(food.name),
            background: Container(
              color: Colors.red,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              alignment: Alignment.centerRight,
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            secondaryBackground: Container(
              color: Colors.red,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              alignment: Alignment.centerLeft,
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            direction: DismissDirection.horizontal, // Enables swiping in both directions
            onDismissed: (direction) {
              foodProvider.removeFood(food.name, meal);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("${food.name} removed"))
              );
            },
            child: ListTile(
              title: Text(food.name),
              trailing: Text('${food.calories} cal'),
            ),
          );
        }).toList(),
      );
    },
  );
}


  
}
