import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/food_model.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'fridge_master.db');
    return await openDatabase(
      path,
      version: 2, // 개발 중 구조 변경을 위해 버전 2 유지
      onCreate: (db, version) {
        // 처음 테이블을 만들 때 모든 컬럼(isAlarmOn 포함)을 한 번에 생성
        return db.execute(
          "CREATE TABLE foods(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, expiryDate TEXT, isAlarmOn INTEGER DEFAULT 1, category TEXT)",
        );
      },
      onUpgrade: (db, oldVersion, newVersion) {
        // 버전 1 상태에서 이미 설치된 앱에 새로운 컬럼(isAlarmOn)을 추가할 때 실행
        if (oldVersion < 2) {
          db.execute('ALTER TABLE foods ADD COLUMN isAlarmOn INTEGER DEFAULT 1');
        }
      },
    );
  }

  // 데이터 추가 (식재료 등록)
  Future<void> insertFood(FoodModel food) async {
    final db = await database;
    await db.insert(
        'foods',
        food.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace
    );
  }

  // 데이터 조회 (자동 삭제 + 임박순 정렬)
  Future<List<FoodModel>> getFoods() async {
    final db = await database;

    // [D-Day 삭제 로직]
    // 오늘(2026-05-12)은 살려두고, 오늘보다 이전(어제까지) 날짜만 삭제
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);

    // expiryDate가 오늘 자정(00:00:00)보다 작으면 삭제
    await db.delete(
      'foods',
      where: 'expiryDate < ?',
      whereArgs: [today.toIso8601String()],
    );

    // [임박순 정렬]
    // expiryDate ASC: 유통기한이 가장 가까운 날짜부터 위로 나열
    final List<Map<String, dynamic>> maps = await db.query(
        'foods',
        orderBy: 'expiryDate ASC'
    );

    return List.generate(maps.length, (i) {
      return FoodModel.fromMap(maps[i]);
    });
  }

  // 데이터 삭제 (스와이프 삭제 대응)
  Future<void> deleteFood(int id) async {
    final db = await database;
    await db.delete(
        'foods',
        where: 'id = ?',
        whereArgs: [id]
    );
  }
}