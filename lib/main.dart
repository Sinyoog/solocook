import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:permission_handler/permission_handler.dart';
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

// 🔥 상태 변화를 감지하기 위해 StatefulWidget으로 변경!
class SingleCookMasterApp extends StatefulWidget {
  const SingleCookMasterApp({super.key});

  @override
  State<SingleCookMasterApp> createState() => _SingleCookMasterAppState();
}

class _SingleCookMasterAppState extends State<SingleCookMasterApp> {
  // 현재 테마 모드 상태 (기본은 라이트모드)
  ThemeMode _themeMode = ThemeMode.light;

  // 🔥 설정창에서 호출할 테마 변경 함수
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

      // 🔥 테마 설정의 핵심 3요소
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

      // 🔥 MainScreen에 테마 변경 함수를 전달합니다.
      home: MainScreen(onThemeChanged: _updateThemeMode),
    );
  }
}