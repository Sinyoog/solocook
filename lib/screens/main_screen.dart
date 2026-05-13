import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // 🔥 패키지 임포트
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

  // 기본값 설정
  bool _isDarkMode = false;
  TimeOfDay _notificationTime = const TimeOfDay(hour: 9, minute: 0);

  @override
  void initState() {
    super.initState();
    _loadSettings(); // 🔥 앱 시작 시 저장된 설정 불러오기
  }

  // 📂 폰 저장소에서 설정 불러오기
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      // 저장된 값이 없으면 기본값(false, 9시 0분) 사용
      _isDarkMode = prefs.getBool('isDarkMode') ?? false;
      int hour = prefs.getInt('notificationHour') ?? 9;
      int minute = prefs.getInt('notificationMinute') ?? 0;
      _notificationTime = TimeOfDay(hour: hour, minute: minute);
    });
    // 불러온 다크모드 상태를 앱 전체 테마에 즉시 반영
    widget.onThemeChanged(_isDarkMode);
  }

  // 💾 다크모드 설정 저장
  Future<void> _saveDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', value);
  }

  // 💾 알림 시간 설정 저장
  Future<void> _saveNotificationTime(TimeOfDay time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('notificationHour', time.hour);
    await prefs.setInt('notificationMinute', time.minute);
  }

  @override
  Widget build(BuildContext context) {
    // 테마 상태 동기화 (현재 테마가 다크인지 확인)
    _isDarkMode = Theme.of(context).brightness == Brightness.dark;

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
                fillColor: _isDarkMode ? Colors.grey[800] : Colors.grey[100],
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
            ListTile(
              leading: const Icon(Icons.dark_mode),
              title: const FittedBox(
                alignment: Alignment.centerLeft,
                fit: BoxFit.scaleDown,
                child: Text("다크모드"),
              ),
              trailing: Switch(
                value: _isDarkMode,
                onChanged: (bool value) {
                  setState(() => _isDarkMode = value);
                  _saveDarkMode(value); // 🔥 폰에 저장
                  widget.onThemeChanged(value); // 앱 테마 변경
                },
              ),
            ),
            const Divider(),
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
                  initialEntryMode: TimePickerEntryMode.input,
                  builder: (context, child) {
                    return MediaQuery(
                      data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
                      child: child!,
                    );
                  },
                );
                if (picked != null) {
                  setState(() => _notificationTime = picked);
                  _saveNotificationTime(picked); // 🔥 폰에 저장
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