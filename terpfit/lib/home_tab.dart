import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:terpfit/exercise_data.dart';
import 'add_goal.dart';
import 'goals_item.dart';
import 'food_list_model.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'calendar.dart';
import 'app_date_provider.dart';
import 'calendar_events.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({Key? key}) : super(key: key);

  @override
  HomeTabState createState() => HomeTabState();
}

class HomeTabState extends State<HomeTab> {
  @override
  Widget build(BuildContext context) {
    final date = Provider.of<AppDateProvider>(context, listen: false);
    return SafeArea(
      child: OrientationBuilder(
        builder: (context, orientation) {
          if (orientation == Orientation.portrait) {
            return MaterialApp(
              home: Scaffold(
                  appBar: AppBar(
                    title: Consumer<AppDateProvider>(
                      builder: (context, dateProvider, _) {
                        String formattedDate = DateFormat('EEEE, MMMM d')
                            .format(dateProvider.currentDate);
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(formattedDate,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.bold,
                                )),
                            const SimpleDatePickerButton(),
                          ],
                        );
                      },
                    ),
                  ),
                  body: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: ListView(children: const [
                        Card(child: GoalCard()),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Card(child: IntakeCard()),
                            Card(child: BurnCard()),
                          ],
                        ),
                        CalendarLauncher(),
                      ]))),
            );
          } else {
            return MaterialApp(
              home: Scaffold(
                appBar: AppBar(
                  title: Consumer<AppDateProvider>(
                    builder: (context, dataProvider, _) {
                      String formattedDate =
                          DateFormat('EEEE, MMMM d').format(date.currentDate);
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SimpleDatePickerButton(),
                          Text(formattedDate,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                              ))
                        ],
                      );
                    },
                  ),
                ),
                body: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.7,
                      child: ListView(
                        children: const [
                          Card(child: GoalCard()),
                          Card(child: IntakeCard()),
                          Card(child: BurnCard()),
                          CalendarLauncher(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }
}

class CalendarLauncher extends StatelessWidget {
  const CalendarLauncher({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: 300,
        height: 190,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 209, 197, 197),
            elevation: 0,
          ),
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const TableEvents()));
          },
          child: const Text('Schedule Events',
              style: TextStyle(fontSize: 20, color: Colors.black)),
        ));
  }
}

class IntakeCard extends StatelessWidget {
  const IntakeCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<FoodItemsProvider>(builder: (context, foodProvider, child) {
      final provider = Provider.of<GoalsState>(context, listen: false);
      final intakeGoal = provider.intakeGoal;
      final totalCalories = foodProvider.totalCalories;
      final caloriesRemaining = intakeGoal - totalCalories;
      final cardWidth = MediaQuery.of(context).size.width * 0.46;

      return SizedBox(
        height: 190,
        width: cardWidth,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text('Calories Intake ', style: TextStyle(fontSize: 16)),
                  Icon(Icons.fastfood_rounded),
                ],
              ),
              LinearPercentIndicator(
                barRadius: const Radius.circular(16),
                backgroundColor: Colors.grey[300]!,
                progressColor: Colors.yellow[700]!,
                percent: (totalCalories / intakeGoal).clamp(0, 1),
                animation: true,
                lineHeight: 30,
                center: Text(
                  "${(totalCalories / intakeGoal * 100).toStringAsFixed(1)}%",
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text('Remaining: $caloriesRemaining cal'),
            ],
          ),
        ),
      );
    });
  }
}

class GoalCard extends StatelessWidget {
  const GoalCard({super.key});

  @override
  Widget build(BuildContext context) {
    final goalProvider = Provider.of<GoalsState>(context);
    final intakeGoal = goalProvider.intakeGoal;
    final burnGoal = goalProvider.burnGoal;
    return SizedBox(
      width: 300,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Goals',
                  style: TextStyle(fontSize: 26),
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const AddGoalPage()),
                    );
                  },
                ),
              ],
            ),
            Text(
              'Daily Calorie Intake: $intakeGoal' 'cal',
              style: const TextStyle(fontSize: 18),
            ),
            Text(
              'Daily Calorie Burn: $burnGoal' 'cal',
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}

class BurnCard extends StatelessWidget {
  const BurnCard({super.key});

  @override
  Widget build(BuildContext context) {
    final goalProvider = Provider.of<GoalsState>(context);
    final burnGoal = goalProvider.burnGoal;
    final cardWidth = MediaQuery.of(context).size.width * 0.46;

    return Consumer<ExerciseData>(
      builder: (context, exerciseData, child) {
        final caloriesBurned = exerciseData.totalCalories;
        double percent = burnGoal > 0 ? caloriesBurned / burnGoal : 0;
        percent = percent.clamp(0.0, 1.0);

        return SizedBox(
          width: cardWidth,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text('Calories Burned', style: TextStyle(fontSize: 16)),
                      Icon(Icons.directions_run_rounded),
                    ]),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircularPercentIndicator(
                    radius: 60,
                    lineWidth: 10.0,
                    animation: true,
                    percent: percent,
                    center: Text(
                      '${caloriesBurned.toInt()} cal',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    circularStrokeCap: CircularStrokeCap.round,
                    backgroundColor: Colors.grey[300]!,
                    progressColor: Colors.yellow[700]!,
                  ),
                ),
                Text('Remaining: ${burnGoal - caloriesBurned} cal'),
              ],
            ),
          ),
        );
      },
    );
  }
}
