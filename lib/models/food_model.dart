class FoodModel {
  final int? id;
  final String name;
  final DateTime expiryDate;
  final String category;
  final bool isAlarmOn;

  FoodModel({
    this.id,
    required this.name,
    required this.expiryDate,
    this.category = '기타',
    this.isAlarmOn = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'expiryDate': expiryDate.toIso8601String(),
      'category': category,
      'isAlarmOn': isAlarmOn ? 1 : 0,
    };
  }

  // [수정 핵심] 여기서 category가 빠져있어서 다른 파일들이 다 에러가 난 겁니다!
  factory FoodModel.fromMap(Map<String, dynamic> map) {
    return FoodModel(
      id: map['id'],
      name: map['name'],
      expiryDate: DateTime.parse(map['expiryDate']),
      category: map['category'] ?? '기타', // 이 줄이 반드시 있어야 합니다.
      isAlarmOn: map['isAlarmOn'] == 1,
    );
  }

  int get dDay {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final expiry = DateTime(expiryDate.year, expiryDate.month, expiryDate.day);
    return expiry.difference(today).inDays;
  }
}