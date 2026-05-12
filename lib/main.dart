import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. 윈도우 DB 설정
  if (Platform.isWindows || Platform.isLinux) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  // 2. Firebase 초기화
  try {
    if (Platform.isWindows) {
      // 윈도우에서는 수동으로 옵션을 넣어줘야 할 때가 있습니다.
      // 만약 'firebase_options.dart'가 있다면 해당 파일을 import해서 쓰면 되지만,
      // 현재 없다면 일단 아래처럼 호출해보고 에러나면 옵션을 수동으로 넣어야 합니다.
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: "AIza...", // 여기에 콘솔에서 확인한 API 키
          appId: "1:...",    // 여기에 앱 ID
          messagingSenderId: "...",
          projectId: "solocook-4174c",
        ),
      );
    } else {
      // 안드로이드/iOS는 google-services.json만 있으면 이걸로 충분합니다.
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