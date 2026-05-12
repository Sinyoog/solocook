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
  String _searchQuery = ""; // 검색어 상태 관리

  @override
  Widget build(BuildContext context) {
    // 현재 검색어를 각 화면에 전달
    final List<Widget> _pages = [
      TimerScreen(searchQuery: _searchQuery),
      RecipeScreen(searchQuery: _searchQuery),
      FridgeScreen(searchQuery: _searchQuery),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("정밀 타이머", style: TextStyle(fontWeight: FontWeight.bold)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value; // 타핑할 때마다 검색어 업데이트
                });
              },
              decoration: InputDecoration(
                hintText: "검색어를 입력하세요 (예: 반숙)",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ),
      ),
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