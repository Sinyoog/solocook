import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:permission_handler/permission_handler.dart'; // 🔥 추가: 권한 핸들러
import 'screens/main_screen.dart';

void main() async {
  // 1. Flutter 엔진 초기화
  WidgetsFlutterBinding.ensureInitialized();

  // 2. 알림 권한 요청 (안드로이드 13 이상 필수)
  // 앱 켜자마자 "알림 허용하시겠습니까?" 팝업을 띄웁니다.
  if (Platform.isAndroid) {
    await Permission.notification.request();
  }

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
    print("✅ Firebase 연결 성공!");
  } catch (e) {
    print("❌ Firebase 연결 실패: $e");
  }

  runApp(const SingleCookMasterApp());
}

class SingleCookMasterApp extends StatelessWidget {
  const SingleCookMasterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '자취요리 마스터',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.orange,
          primary: Colors.orange[800]!,
        ),
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const MainScreen(),
    );
  }
}