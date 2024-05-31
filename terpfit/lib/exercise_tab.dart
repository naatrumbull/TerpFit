import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:terpfit/exercise_data.dart';
import 'package:terpfit/exercise_model.dart';

class ExerciseLogger extends StatefulWidget {
  const ExerciseLogger({super.key});

  @override
  ExerciseLoggerState createState() => ExerciseLoggerState();
}

class ExerciseLoggerState extends State<ExerciseLogger> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exercises'),
      ),
      body: Consumer<ExerciseData>(
        builder: (context, provider, child) {
          return provider.exercises.isEmpty
            ? const Center(child: Text("No exercises added yet."))
            : ListView.builder(
                itemCount: provider.exercises.length,
                itemBuilder: (context, i) {
                  final exercise = provider.exercises[i];
                  return Dismissible(
                    key: Key('${exercise.name}_$i'),
                    direction: DismissDirection.endToStart,
                    onDismissed: (direction) {
                      provider.deleteExercise(exercise);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Exercise deleted"))
                      );
                    },
                    background: Container(
                      color: Colors.red,
                      padding: const EdgeInsets.only(right: 20),
                      alignment: Alignment.centerRight,
                      child: const Icon(Icons.delete, color: Colors.white, size: 36),
                    ),
                    child: ListTile(
                      title: Text(exercise.name),
                      subtitle: exercise.type == "Cardio" ?
                        Text("${exercise.time} minutes, ${exercise.calories} calories") :
                        Text("${exercise.sets} sets, ${exercise.reps} reps, ${exercise.weight} lbs"),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text("Confirm Delete"),
                                content: Text("Are you sure you want to delete ${exercise.name}?"),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      provider.deleteExercise(exercise);
                                      Navigator.of(context).pop();
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text("Exercise deleted"))
                                      );
                                    },
                                    child: const Text('Delete'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    ),
                  );
                },
              );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showDialog(
          context: context,
          builder: (context) => const AddExerciseDialog(),
        ),
        tooltip: 'Add Exercise',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class AddExerciseDialog extends StatefulWidget {
  const AddExerciseDialog({super.key});

  @override
  AddExerciseDialogState createState() => AddExerciseDialogState();
}

class AddExerciseDialogState extends State<AddExerciseDialog> {
  final TextEditingController nameController = TextEditingController();
  String? selectedType;
  final TextEditingController weightController = TextEditingController();
  final TextEditingController repsController = TextEditingController();
  final TextEditingController setsController = TextEditingController();
  final TextEditingController timeController = TextEditingController();
  final TextEditingController caloriesController = TextEditingController();

  // Error messages
  String? nameError;
  String? weightError;
  String? repsError;
  String? setsError;
  String? timeError;
  String? caloriesError;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Add New Exercise"),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Exercise Name',
                errorText: nameError,
              ),
            ),
            DropdownButtonFormField<String>(
              value: selectedType,
              items: ['Cardio', 'Weight Training'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  selectedType = newValue;
                });
              },
              decoration: const InputDecoration(labelText: 'Type of Exercise'),
            ),
            if (selectedType == 'Weight Training') ...[
              TextField(
                controller: weightController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Weight (lbs)',
                  errorText: weightError,
                ),
              ),
              TextField(
                controller: repsController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Reps',
                  errorText: repsError,
                ),
              ),
              TextField(
                controller: setsController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Sets',
                  errorText: setsError,
                ),
              ),
            ] else if (selectedType == 'Cardio') ...[
              TextField(
                controller: timeController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Duration (minutes)',
                  errorText: timeError,
                ),
              ),
              TextField(
                controller: caloriesController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Calories Burned',
                  errorText: caloriesError,
                ),
              ),
            ]
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: const Text('Add'),
          onPressed: () {
            if (validateInputs()) {
              addExercise(context);
            }
          },
        ),
      ],
    );
  }

  bool validateInputs() {
    bool isValid = true;
    setState(() {
      nameError = weightError = repsError = setsError = timeError = caloriesError = null;
    });

    if (nameController.text.isEmpty) {
      nameError = 'Please enter an exercise name';
      isValid = false;
    }
    if (selectedType == 'Weight Training') {
      if (!isNumeric(weightController.text)) {
        weightError = 'Please enter a valid weight (numbers only)';
        isValid = false;
      }
      if (!isNumeric(repsController.text)) {
        repsError = 'Please enter a valid number of reps';
        isValid = false;
      }
      if (!isNumeric(setsController.text)) {
        setsError = 'Please enter a valid number of sets';
        isValid = false;
      }
    } else if (selectedType == 'Cardio') {
      if (!isNumeric(timeController.text)) {
        timeError = 'Please enter a valid duration (minutes)';
        isValid = false;
      }
      if (!isNumeric(caloriesController.text)) {
        caloriesError = 'Please enter a valid number of calories';
        isValid = false;
      }
    }

    return isValid;
  }

  bool isNumeric(String s) {
    return double.tryParse(s) != null;
  }

  void addExercise(BuildContext context) {
    Exercise newExercise;
    if (selectedType == 'Weight Training') {
      newExercise = Exercise(
        name: nameController.text,
        type: selectedType!,
        weight: weightController.text,
        reps: repsController.text,
        sets: setsController.text,
      );
    } else {
      newExercise = Exercise(
        name: nameController.text,
        type: selectedType!,
        time: timeController.text,
        calories: caloriesController.text,
      );
    }
    Provider.of<ExerciseData>(context, listen: false).addExercise(newExercise);
    Navigator.of(context).pop();
  }
}

