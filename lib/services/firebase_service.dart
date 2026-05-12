import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// 레시피 이름을 받아서 해당 레시피의 클릭수를 1 증가시킵니다.
  static Future<void> addRecipeClick(String recipeName) async {
    try {
      // 'recipe_clicks' 컬렉션(폴더) 내에 레시피 이름의 문서(파일)를 지정
      DocumentReference docRef = _db.collection('recipe_clicks').doc(recipeName);

      await docRef.set({
        'count': FieldValue.increment(1), // 서버에서 기존 값에 +1 연산
        'lastUpdate': FieldValue.serverTimestamp(), // 서버 기준 현재 시간 저장
      }, SetOptions(merge: true)); // 기존 데이터가 있으면 유지하며 합침

      print("🔥 [Firebase] $recipeName 클릭수 업데이트 성공!");
    } catch (e) {
      print("❌ [Firebase] 업데이트 실패: $e");
    }
  }
}