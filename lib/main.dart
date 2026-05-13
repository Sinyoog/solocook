import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart'; // 🔥 패키지 추가
import 'screens/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. 알림 권한 요청
  if (Platform.isAndroid) {
    await Permission.notification.request();
  }

  // 2. 윈도우 DB 설정
  if (Platform.isWindows || Platform.isLinux) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  // 3. Firebase 초기화
  try {
    if (Platform.isWindows) {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: "AIza...",
          appId: "1:...",
          messagingSenderId: "...",
          projectId: "solocook-4174c",
        ),
      );
    } else {
      await Firebase.initializeApp();
    }
  } catch (e) {
    debugPrint("❌ Firebase 연결 실패: $e");
  }

  runApp(const SingleCookMasterApp());
}

class SingleCookMasterApp extends StatefulWidget {
  const SingleCookMasterApp({super.key});

  @override
  State<SingleCookMasterApp> createState() => _SingleCookMasterAppState();
}

class _SingleCookMasterAppState extends State<SingleCookMasterApp> {
  // 기본값을 system으로 두면 기기 설정에 맞게 시작하고, 저장된 값이 있으면 그걸 따릅니다.
  ThemeMode _themeMode = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    _initTheme(); // 🔥 앱 시작 시 저장된 테마 불러오기
  }

  // 📂 저장소에서 다크모드 설정값 읽어오기
  Future<void> _initTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDarkMode = prefs.getBool('isDarkMode') ?? false; // 기본값 false
    setState(() {
      _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    });
  }

  // 🔥 설정창에서 테마를 바꿀 때 실행될 함수
  void _updateThemeMode(bool isDarkMode) {
    setState(() {
      _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '자취요리 마스터',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode, // 🔥 현재 상태 반영
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorSchemeSeed: Colors.orange,
        scaffoldBackgroundColor: Colors.white,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: Colors.orange,
      ),
      // MainScreen에 테마 변경 함수 전달
      home: MainScreen(onThemeChanged: _updateThemeMode),
    );
  }
}