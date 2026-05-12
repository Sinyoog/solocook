import 'package:flutter/material.dart';
import '../data/recipe_data.dart';
import 'timer_view.dart';
import '../services/firebase_service.dart';

class TimerScreen extends StatelessWidget {
  final String searchQuery;

  const TimerScreen({super.key, required this.searchQuery});

  @override
  Widget build(BuildContext context) {
    // 1. FutureBuilder를 사용하여 서버의 클릭수 데이터를 먼저 가져옵니다.
    return FutureBuilder<Map<String, int>>(
      future: FirebaseService.getClickCounts(),
      builder: (context, snapshot) {
        // 데이터를 가져오는 동안 보여줄 로딩 화면
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Colors.orange));
        }

        // 서버에서 가져온 클릭 데이터 (데이터가 없으면 빈 지도)
        final clickData = snapshot.data ?? {};

        // 2. 전체 데이터를 복사하여 서버 클릭수 기준으로 정렬합니다.
        final allPresets = List.from(RecipeData.timerPresets);
        allPresets.sort((a, b) {
          int countA = clickData[a['menu']] ?? 0;
          int countB = clickData[b['menu']] ?? 0;
          return countB.compareTo(countA); // 클릭수 높은 순(내림차순) 정렬
        });

        // 3. 정렬된 데이터를 검색어로 필터링합니다.
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
              final clickCount = clickData[item['menu']] ?? 0; // 해당 메뉴의 실제 클릭수

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
                        // 🔥 인기 뱃지 추가 (선택 사항)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.orange[100],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text("🔥 $clickCount",
                              style: const TextStyle(fontSize: 10, color: Colors.orange, fontWeight: FontWeight.bold)),
                        ),
                      ]
                    ],
                  ),
                  subtitle: Text(item['category'] ?? '카테고리 없음'),
                  trailing: Text("${(item['time'] ?? 0) ~/ 60}분 ${(item['time'] ?? 0) % 60}초"),
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