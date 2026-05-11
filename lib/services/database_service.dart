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
      version: 2, // 컬럼이 추가되었으므로 버전을 2로 올립니다.
      onCreate: (db, version) {
        return db.execute(
          // isAlarmOn 컬럼 추가 (기본값 1 = 켬)
          'CREATE TABLE foods(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, expiryDate TEXT, category TEXT, isAlarmOn INTEGER DEFAULT 1)',
        );
      },
      onUpgrade: (db, oldVersion, newVersion) {
        if (oldVersion < 2) {
          // 기존 사용자의 DB에도 컬럼을 추가해주는 안전 장치
          db.execute('ALTER TABLE foods ADD COLUMN isAlarmOn INTEGER DEFAULT 1');
        }
      },
    );
  }

  Future<void> insertFood(FoodModel food) async {
    final db = await database;
    await db.insert('foods', food.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<FoodModel>> getFoods() async {
    final db = await database;

    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);

    await db.delete(
      'foods',
      where: 'expiryDate < ?',
      whereArgs: [today.toIso8601String()],
    );

    final List<Map<String, dynamic>> maps = await db.query('foods', orderBy: 'expiryDate ASC');

    return List.generate(maps.length, (i) {
      return FoodModel(
        id: maps[i]['id'],
        name: maps[i]['name'],
        expiryDate: DateTime.parse(maps[i]['expiryDate']),
        category: maps[i]['category'] ?? '기타',
        // [수정] DB에서 가져온 0/1 값을 bool로 변환
        isAlarmOn: maps[i]['isAlarmOn'] == 1,
      );
    });
  }

  Future<void> deleteFood(int id) async {
    final db = await database;
    await db.delete('foods', where: 'id = ?', whereArgs: [id]);
  }
}