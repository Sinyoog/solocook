import 'dart:io'; // 추가
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart'; // 추가
import 'package:sqflite_common_ffi/sqflite_ffi.dart'; // 추가
import 'screens/main_screen.dart';

void main() {
  // --- 윈도우 환경을 위한 DB 초기화 코드 시작 ---
  if (Platform.isWindows || Platform.isLinux) {
    // FFI를 초기화하고 databaseFactory를 설정합니다.
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  // --- 코드 끝 ---

  WidgetsFlutterBinding.ensureInitialized();
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