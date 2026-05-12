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
  String _searchQuery = "";

  @override
  Widget build(BuildContext context) {
    final List<Widget> _pages = [
      TimerScreen(searchQuery: _searchQuery),
      RecipeScreen(searchQuery: _searchQuery),
      FridgeScreen(searchQuery: _searchQuery),
    ];

    return Scaffold(
      appBar: AppBar(
        // [수정 포인트] 현재 탭 번호에 따라 제목을 다르게 표시합니다.
        title: Text(
            _currentIndex == 0 ? "정밀 타이머" :
            _currentIndex == 1 ? "자취 특화 레시피" : "나의 냉장고",
            style: const TextStyle(fontWeight: FontWeight.bold)
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: "검색어를 입력하세요",
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
        selectedItemColor: Colors.orange, // 선택된 탭 강조 색상
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.timer), label: "타이머"),
          BottomNavigationBarItem(icon: Icon(Icons.restaurant), label: "레시피"),
          BottomNavigationBarItem(icon: Icon(Icons.kitchen), label: "냉장고"),
        ],
      ),
    );
  }
}