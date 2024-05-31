import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:terpfit/exercise_tab.dart';
import 'app_date_provider.dart';
import 'exercise_data.dart';
import 'profile_tab.dart';
import 'goals_item.dart';
import 'home_tab.dart';
import 'food_tab.dart';
import 'map_tab.dart';
import 'food_list_model.dart';
import 'calendar_events.dart';


Future<void> main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider<GoalsState>(
            create: (context)=>GoalsState()
          ),
          ChangeNotifierProvider<AppDateProvider>(
            create: (context) => AppDateProvider(),
          ),
          ChangeNotifierProvider(create: (context) => SelectedDay()),
          ChangeNotifierProxyProvider<AppDateProvider, ExerciseData>(
              create: (_) => ExerciseData(),
              update: (context, dataProvider, exerciseData) {
                exerciseData!.updateCurrentDate(dataProvider.currentDate);
                return exerciseData;
              }
          ),
          ChangeNotifierProxyProvider<AppDateProvider, FoodItemsProvider>(
            create: (_) => FoodItemsProvider(),
            update: (context, dataProvider, foodProvider) {
              foodProvider!.updateCurrentDate(dataProvider.currentDate);
              return foodProvider;
            }
          )
        ],
        child: MaterialApp(
          title: 'TerpFit',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
            useMaterial3: true,
          ),
          home: const MyHomePage(title: 'TerpFit'),
        ));
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;

  static final List<Widget> _widgetOptions = <Widget>[
    const HomeTab(),
    const FoodTab(),
    const ExerciseLogger(),
    const MapTab(),
    const ProfileTab(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;
    final isHorizontal = orientation == Orientation.landscape;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.redAccent,
        title: Text(
          'TerpFit',
          style: TextStyle(fontSize: (isHorizontal ? 24 : 36), color: Colors.white),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.redAccent,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.black,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        iconSize: isHorizontal ? 20 : 24,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_filled),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fastfood_rounded),
            label: 'Food',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_run_rounded),
            label: 'Workout',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map_rounded),
            label: 'Map',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          )
        ],
      ),
      body: _widgetOptions.elementAt(_selectedIndex),
    );
  }
}