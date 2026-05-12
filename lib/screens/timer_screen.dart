import 'package:flutter/material.dart';
import '../data/recipe_data.dart';
import 'timer_view.dart';
import '../services/firebase_service.dart';

class TimerScreen extends StatelessWidget {
  final String searchQuery;

  const TimerScreen({super.key, required this.searchQuery});

  @override
  Widget build(BuildContext context) {
    // RecipeData.timerPresets 데이터를 가져와서 검색어로 필터링
    final allPresets = RecipeData.timerPresets;
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
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: const Icon(Icons.timer_outlined),
              title: Text(item['menu'] ?? '메뉴명 없음'),
              subtitle: Text(item['category'] ?? '카테고리 없음'),
              trailing: Text("${(item['time'] ?? 0) ~/ 60}분 ${(item['time'] ?? 0) % 60}초"),
              onTap: () {
                // 🔥 [추가] 서버에 타이머 클릭 기록 전송
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
  }
}