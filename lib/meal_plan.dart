// mealplan.dart
import 'package:flutter/material.dart';
import 'database_helper.dart';

class MealPlanScreen extends StatefulWidget {
  final String selectedDate;

  const MealPlanScreen({required this.selectedDate});

  @override
  _MealPlanScreenState createState() => _MealPlanScreenState(selectedDate);
}

class _MealPlanScreenState extends State<MealPlanScreen> {
  final TextEditingController targetCaloriesController =
      TextEditingController();
  final TextEditingController dateController = TextEditingController();
  List<Map<String, dynamic>> foodItems = [];
  List<bool> checkboxStates = [];
  Color textColor = Colors.black;
  int totalCalories = 0;
  String selectedDate;

  _MealPlanScreenState(this.selectedDate);

  @override
  void initState() {
    super.initState();
    targetCaloriesController.text = '2000';
    dateController.text = _getFormattedDate(DateTime.now());
    _fetchFoodItems();
    _checkSelectedItemsForDate();
  }

  String _getFormattedDate(DateTime dateTime) {
    return '${dateTime.month.toString().padLeft(2, '0')}/${dateTime.day.toString().padLeft(2, '0')}/${dateTime.year}';
  }

  void _fetchFoodItems() async {
    List<Map<String, dynamic>> fetchedItems = await DatabaseHelper().getFoods();
    setState(() {
      foodItems = fetchedItems;
      checkboxStates = List.generate(fetchedItems.length, (index) => false);
    });
  }

  void _updateTotalCalories() {
    int total = 0;
    int targetCalories = int.tryParse(targetCaloriesController.text) ?? 0;
    for (int i = 0; i < foodItems.length; i++) {
      if (checkboxStates[i]) {
        total += foodItems[i]['calories'] as int;
      }
    }
    setState(() {
      totalCalories = total;
      textColor = (totalCalories <= targetCalories) ? Colors.black : Colors.red;
    });
  }

  Future<void> _insertMealPlan() async {
    List<int> selectedFoodIds = [];
    for (int i = 0; i < foodItems.length; i++) {
      if (checkboxStates[i]) {
        selectedFoodIds.add(foodItems[i]['id'] as int);
      }
    }
    await DatabaseHelper().deleteMealPlan(selectedDate);

    Map<String, dynamic> newMealPlan = {
      'date': dateController.text,
    };

    int insertedMealPlanId = await DatabaseHelper().insertMealPlan(newMealPlan);

    for (int foodId in selectedFoodIds) {
      await DatabaseHelper().insertMealPlanFoodItem(
          {'meal_plan_id': insertedMealPlanId, 'food_id': foodId});
    }

    print('Inserted Meal Plan ID: $insertedMealPlanId');
  }

  void _checkSelectedItemsForDate() async {
    List<String> selectedFoodItems =
        await DatabaseHelper().getFoodsByMealPlanDate(selectedDate);

    setState(() {
      for (int i = 0; i < foodItems.length; i++) {
        checkboxStates[i] = selectedFoodItems.contains(foodItems[i]['name']);
      }
      _updateTotalCalories();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meal Plans'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: targetCaloriesController,
              decoration: InputDecoration(
                labelText: 'Target Calories per Day',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: dateController,
              decoration: InputDecoration(
                labelText: 'Date',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.datetime,
            ),
            const SizedBox(height: 20),
            Text(
              'Total Calories: $totalCalories',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await _insertMealPlan();
              },
              child: const Text('Add Meal Plan'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Available Foods:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: FutureBuilder<List<Map<String, dynamic>>>(
                      future: DatabaseHelper().getFoods(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(
                              child: Text('Error: ${snapshot.error}'));
                        } else {
                          foodItems = snapshot.data ?? [];
                          checkboxStates =
                              List.generate(foodItems.length, (index) => false);

                          return ListView.builder(
                            itemCount: foodItems.length,
                            itemBuilder: (context, index) {
                              return CheckboxListTile(
                                title: Text(
                                    '${foodItems[index]['name']} - ${foodItems[index]['calories']} Calories'),
                                value: checkboxStates[index],
                                onChanged: (bool? value) {
                                  setState(() {
                                    checkboxStates[index] = value ?? false;
                                    _updateTotalCalories();
                                  });
                                },
                              );
                            },
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
