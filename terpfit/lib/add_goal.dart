import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:terpfit/goals_item.dart';
import 'package:provider/provider.dart';

class AddGoalPage extends StatefulWidget {
  const AddGoalPage({super.key});

  @override
  State<AddGoalPage> createState() => _AddGoalPageState();

}

class _AddGoalPageState extends State<AddGoalPage> {
  final TextEditingController _intakeController = TextEditingController();
  final TextEditingController _burnController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<GoalsState>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Goals'),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(8.0,0.0,8.0,0.0),
        child: Column (
          children: [
            TextField(
              controller: _intakeController,
              decoration: const InputDecoration(labelText: 'Daily Calorie Intake Goals'),
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly
              ],
            ),
            TextField(
              controller: _burnController,
              decoration: const InputDecoration(labelText: 'Daily Calorie Burn Goals'),
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                child: const Text('Save Changes'),
                onPressed: () {
                  final inputGoal = int.tryParse(_intakeController.text) ?? 2000;
                  final burnGoal = int.tryParse(_burnController.text) ?? 600;

                  if (inputGoal > 0 && burnGoal > 0) {
                    provider.updateCalorieIntake(inputGoal);
                    provider.updateCalorieBurn(burnGoal);
                    Navigator.pop(context);
                  }
                },
              ),
            )
          ]
        ),
      )

    );
  }
}