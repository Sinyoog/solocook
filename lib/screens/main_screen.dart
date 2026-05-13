import 'package:flutter/material.dart';
import 'timer_screen.dart';
import 'recipe_screen.dart';
import 'fridge_screen.dart';

class MainScreen extends StatefulWidget {
  final Function(bool) onThemeChanged;
  const MainScreen({super.key, required this.onThemeChanged});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  String _searchQuery = "";
  TimeOfDay _notificationTime = const TimeOfDay(hour: 9, minute: 0);

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final List<Widget> _pages = [
      TimerScreen(searchQuery: _searchQuery),
      RecipeScreen(searchQuery: _searchQuery),
      FridgeScreen(searchQuery: _searchQuery),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
            _currentIndex == 0 ? "정밀 타이머" :
            _currentIndex == 1 ? "자취 특화 레시피" : "나의 냉장고",
            style: const TextStyle(fontWeight: FontWeight.bold)
        ),
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () => Scaffold.of(context).openEndDrawer(),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              onChanged: (value) {
                setState(() => _searchQuery = value);
              },
              decoration: InputDecoration(
                hintText: "검색어를 입력하세요",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[100],
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

      // 🔥 우측 설정 드로어 수정
      endDrawer: Drawer(
        width: MediaQuery.of(context).size.width * 0.6,
        child: Column(
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.orange),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text("설정", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            // 1. 다크모드 (FittedBox로 글자 잘림 방지)
            ListTile(
              leading: const Icon(Icons.dark_mode),
              title: const FittedBox(
                alignment: Alignment.centerLeft,
                fit: BoxFit.scaleDown,
                child: Text("다크모드"),
              ),
              trailing: Switch(
                value: isDarkMode,
                onChanged: (bool value) {
                  widget.onThemeChanged(value);
                },
              ),
            ),
            const Divider(),
            // 2. 알림 시간 (키보드 입력 기본 모드)
            ListTile(
              leading: const Icon(Icons.notifications_active),
              title: const FittedBox(
                alignment: Alignment.centerLeft,
                fit: BoxFit.scaleDown,
                child: Text("알림 시간"),
              ),
              subtitle: FittedBox(
                alignment: Alignment.centerLeft,
                fit: BoxFit.scaleDown,
                child: Text("${_notificationTime.hour.toString().padLeft(2, '0')}:${_notificationTime.minute.toString().padLeft(2, '0')} 에 알림"),
              ),
              onTap: () async {
                final TimeOfDay? picked = await showTimePicker(
                  context: context,
                  initialTime: _notificationTime,
                  initialEntryMode: TimePickerEntryMode.input, // 🔥 키보드 입력이 기본으로 뜨게 설정
                  builder: (context, child) {
                    return MediaQuery(
                      data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
                      child: child!,
                    );
                  },
                );
                if (picked != null) {
                  setState(() => _notificationTime = picked);
                }
              },
            ),
            const Divider(),
          ],
        ),
      ),

      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: Colors.orange,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.timer), label: "타이머"),
          BottomNavigationBarItem(icon: Icon(Icons.restaurant), label: "레시피"),
          BottomNavigationBarItem(icon: Icon(Icons.kitchen), label: "냉장고"),
        ],
      ),
    );
  }
}