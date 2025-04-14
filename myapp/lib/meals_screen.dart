import 'package:flutter/material.dart';
import 'custom_meals_tab.dart';

class MealsScreen extends StatelessWidget {
  const MealsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Meal Tracker'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.list), text: 'My Meals'),
              Tab(icon: Icon(Icons.add), text: 'Create New'),
            ],
          ),
        ),
        body: const SafeArea(
          child: TabBarView(
            children: [
              Center(
                child: Text('Saved meals will appear here'),
              ), // Replace with SavedMealsTab()
              CustomMealsTab(),
            ],
          ),
        ),
      ),
    );
  }
}
