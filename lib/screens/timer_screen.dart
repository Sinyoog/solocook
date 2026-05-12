import 'package:flutter/material.dart';
import '../data/recipe_data.dart';
import 'timer_view.dart';
import '../services/firebase_service.dart';

class TimerScreen extends StatelessWidget {
  final String searchQuery;

  const TimerScreen({super.key, required this.searchQuery});

  @override
  Widget build(BuildContext context) {
    // 1. FutureBuilder 대신 StreamBuilder를 사용하여 실시간 감시 모드로 전환!
    return StreamBuilder<Map<String, int>>(
      stream: FirebaseService.getClickCountsStream(), // 🔥 실시간 전화를 연결한 상태
      builder: (context, snapshot) {
        // 처음 연결을 시도할 때 로딩 표시
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Colors.orange));
        }

        // 서버에서 온 최신 데이터 (실시간으로 계속 업데이트됨)
        final clickData = snapshot.data ?? {};

        // 2. 전체 데이터를 복사하여 최신 클릭수 기준으로 실시간 정렬
        final allPresets = List.from(RecipeData.timerPresets);
        allPresets.sort((a, b) {
          int countA = clickData[a['menu']] ?? 0;
          int countB = clickData[b['menu']] ?? 0;
          return countB.compareTo(countA); // 클릭수 많은 순
        });

        // 3. 정렬된 리스트에서 검색어 필터링
        final filteredPresets = allPresets.where((item) {
          final menuName = item['menu']?.toString() ?? '';
          return menuName.contains(searchQuery);
        }).toList();

        return Scaffold(
          body: filteredPresets.isEmpty
              ? const Center(child: Text("검색 결과가 없습니다."))
              : ListView.builder(
            itemCount: filteredPresets.length,
            itemBuilder: (context, index) {
              final item = filteredPresets[index];
              final clickCount = clickData[item['menu']] ?? 0;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: const Icon(Icons.timer_outlined, color: Colors.orange),
                  title: Row(
                    children: [
                      Text(item['menu'] ?? '메뉴명 없음',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      if (clickCount > 0) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.orange[100],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text("🔥 $clickCount",
                              style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.orange,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ]
                    ],
                  ),
                  subtitle: Text(item['category'] ?? '카테고리 없음'),
                  trailing: Text(
                      "${(item['time'] ?? 0) ~/ 60}분 ${(item['time'] ?? 0) % 60}초"),
                  onTap: () {
                    // 서버에 클릭 기록 전송
                    FirebaseService.addRecipeClick(item['menu'] ?? 'unknown_timer');

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TimerView(
                          menuName: item['menu'] ?? '타이머',
                          totalSeconds: item['time'] ?? 0,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }
}