import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 1. [기록하기] 사용자가 클릭하면 서버의 count를 1 올립니다. (기존 유지)
  static Future<void> addRecipeClick(String recipeName) async {
    try {
      await _db.collection('recipe_clicks').doc(recipeName).set({
        'count': FieldValue.increment(1),
        'lastUpdate': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      print("🔥 [Firebase] $recipeName 카운트 업!");
    } catch (e) {
      print("❌ [Firebase] 업데이트 실패: $e");
    }
  }

  // 2. [실시간 감시] 데이터가 변할 때마다 끊임없이 소식을 받아옵니다. (방법 2의 핵심!)
  static Stream<Map<String, int>> getClickCountsStream() {
    return _db.collection('recipe_clicks').snapshots().map((snapshot) {
      Map<String, int> counts = {};
      for (var doc in snapshot.docs) {
        // 'as Map<String, dynamic>'를 지우고 아래처럼만 쓰시면 경고가 사라집니다.
        final data = doc.data();
        if (data != null) {
          counts[doc.id] = data['count'] ?? 0;
        }
      }
      return counts;
    });
  }
}