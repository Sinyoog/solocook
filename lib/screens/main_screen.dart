import 'package:flutter/material.dart';
import 'timer_screen.dart';
import 'recipe_screen.dart';
import 'fridge_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final List<Widget> _pages = [const TimerScreen(), const RecipeScreen(), const FridgeScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.timer), label: "타이머"),
          BottomNavigationBarItem(icon: Icon(Icons.restaurant), label: "레시피"),
          BottomNavigationBarItem(icon: Icon(Icons.kitchen), label: "냉장고"),
        ],
      ),
    );
  }
}