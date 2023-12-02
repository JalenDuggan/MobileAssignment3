import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'meal_plan.dart';
import 'dialogs.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final DatabaseHelper dbHelper = DatabaseHelper();
  await dbHelper.initDatabase();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FlutterCaloriesCalc App Navigation'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          MealPlanScreen(selectedDate: 'null')),
                );
              },
              child: const Text('MEAL PLANS'),
            ),
            const SizedBox(height: 20), // Add spacing between buttons
            MealPlanSearchWidget(),
          ],
        ),
      ),
    );
  }
}

class MealPlanSearchWidget extends StatefulWidget {
  const MealPlanSearchWidget({Key? key}) : super(key: key);

  @override
  _MealPlanSearchWidgetState createState() => _MealPlanSearchWidgetState();
}

class _MealPlanSearchWidgetState extends State<MealPlanSearchWidget> {
  final TextEditingController searchDateController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: searchDateController,
          decoration: InputDecoration(
            labelText: 'Search Meal Plan by Date',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.datetime,
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: () async {
            String searchDate = searchDateController.text;
            if (searchDate.isNotEmpty) {
              List<String> mealPlan =
                  await DatabaseHelper().getFoodsByMealPlanDate(searchDate);
              if (mealPlan.isNotEmpty) {
                showMealPlanDialog(context, mealPlan, searchDate);
                print(mealPlan);
              } else {
                showNoMealPlanDialog(context);
              }
            } else {
              showDateEmptyDialog(context);
            }
          },
          child: const Text('Search Meal Plan'),
        ),
      ],
    );
  }
}
