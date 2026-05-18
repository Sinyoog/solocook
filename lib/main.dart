import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/main_screen.dart';
import 'services/notification_service.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. 알림 권한 요청
  if (Platform.isAndroid) {
    await Permission.notification.request();
    // 🔥 배터리 최적화 예외 요청 (삼성 필수)
    await Permission.ignoreBatteryOptimizations.request();
  }

  // 2. 🔥 [수정] 로컬 알림 초기화 (이 줄이 없으면 유통기한 알림이 절대 안 옵니다!)
  await NotificationService().initNotification();

  // 3. 윈도우 DB 설정
  if (Platform.isWindows || Platform.isLinux) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  // 4. Firebase 초기화
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
  ThemeMode _themeMode = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    _initTheme();
  }

  Future<void> _initTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDarkMode = prefs.getBool('isDarkMode') ?? false;
    setState(() {
      _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    });
  }

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
      themeMode: _themeMode,
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
      home: MainScreen(onThemeChanged: _updateThemeMode),
    );
  }
}