// dialogs.dart
import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'meal_plan.dart';

void showMealPlanDialog(
    BuildContext context, List<String> mealPlanItems, String date) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Meal Plan for $date'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Selected Food Items:'),
              for (String item in mealPlanItems) Text('- $item'),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              _handleDeleteAction(context, date);
            },
            child: Text('Delete'),
          ),
          ElevatedButton(
            onPressed: () {
              _handleUpdateAction(context, date);
            },
            child: Text('Update'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
            child: Text('OK'),
          ),
        ],
      );
    },
  );
}

void _handleDeleteAction(BuildContext context, String date) async {
  await DatabaseHelper().deleteMealPlan(date);
  Navigator.of(context).pop();
  print('Delete action for $date');
}

void _handleUpdateAction(BuildContext context, String date) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => MealPlanScreen(selectedDate: date)),
  );
  print('Update action for $date');
}

void showNoMealPlanDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('No Meal Plan Found'),
        content: Text('No meal plan found for the specified date.'),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
            child: Text('OK'),
          ),
        ],
      );
    },
  );
}

void showDateEmptyDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Date Field is Empty'),
        content: Text('Please enter a date to search for a meal plan.'),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
            child: Text('OK'),
          ),
        ],
      );
    },
  );
}
