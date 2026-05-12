import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 1. [기록하기] 사용자가 클릭하면 서버의 count를 1 올립니다.
  static Future<void> addRecipeClick(String recipeName) async {
    try {
      await _db.collection('recipe_clicks').doc(recipeName).set({
        'count': FieldValue.increment(1), // 기존 값에 +1 (원자적 연산)
        'lastUpdate': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      print("🔥 [Firebase] $recipeName 카운트 업!");
    } catch (e) {
      print("❌ [Firebase] 업데이트 실패: $e");
    }
  }

  // 2. [가져오기] 서버에 저장된 모든 메뉴의 클릭수를 싹 긁어옵니다.
  static Future<Map<String, int>> getClickCounts() async {
    try {
      QuerySnapshot snapshot = await _db.collection('recipe_clicks').get();

      Map<String, int> counts = {};
      for (var doc in snapshot.docs) {
        // 문서 ID가 메뉴 이름이고, 그 안의 count 필드값을 가져옵니다.
        counts[doc.id] = (doc.data() as Map<String, dynamic>)['count'] ?? 0;
      }
      return counts;
    } catch (e) {
      print("❌ [Firebase] 데이터 로드 실패: $e");
      return {};
    }
  }
}