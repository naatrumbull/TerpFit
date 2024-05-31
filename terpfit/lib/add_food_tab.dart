import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'food_item.dart';
import 'food_list_model.dart';

class AddFoodPage extends StatefulWidget {
  const AddFoodPage({super.key});

  @override
  AddFoodPageState createState() => AddFoodPageState();
}

class AddFoodPageState extends State<AddFoodPage> {
  final TextEditingController _foodNameController = TextEditingController();
  final TextEditingController _caloriesController = TextEditingController();
  String? _selectedMeal;

  @override
  void initState() {
    super.initState();
    _selectedMeal = 'Breakfast'; // Default value
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Food'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _foodNameController,
              decoration: const InputDecoration(labelText: 'Food Name'),
            ),
            TextField(
              controller: _caloriesController,
              decoration: const InputDecoration(labelText: 'Calories'),
              keyboardType: TextInputType.number,
            ),
            DropdownButtonFormField<String>(
              value: _selectedMeal,
              items: ['Breakfast', 'Lunch', 'Dinner', 'Snacks']
                  .map((String value) => DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      ))
                  .toList(),
              onChanged: (value) {
                // Update the _selectedMeal based on the user selection
                setState(() {
                  _selectedMeal = value;
                });
              },
              decoration: const InputDecoration(labelText: 'Meal'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              child: const Text('Add Food'),
              onPressed: () {
                final name = _foodNameController.text;
                final calories = int.tryParse(_caloriesController.text) ?? 0;
                
                if (name.isNotEmpty && calories > 0 && _selectedMeal != null) {      
                  final foodItem = FoodItem(
                    name: name, 
                    calories: calories, 
                    meal: _selectedMeal!
                  );

                  final foodProvider = Provider.of<FoodItemsProvider>(context, listen: false);
                  foodProvider.addFood(foodItem);                 
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Invalid input. Please correct and try again."))
                  );
                }
              },
            )
          ],
        ),
      ),
    );
  }
}

