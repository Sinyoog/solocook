import 'package:flutter/material.dart';
import '../data/recipe_data.dart';
import '../widgets/timer_card.dart';
import 'timer_view.dart';
import '../services/firebase_service.dart';

class TimerScreen extends StatelessWidget {
  final String searchQuery;

  const TimerScreen({super.key, required this.searchQuery});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<String, int>>(
      stream: FirebaseService.getClickCountsStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Colors.orange));
        }

        final clickData = snapshot.data ?? {};

        final allPresets = List.from(RecipeData.timerPresets);
        allPresets.sort((a, b) {
          int countA = clickData[a['menu']] ?? 0;
          int countB = clickData[b['menu']] ?? 0;
          return countB.compareTo(countA);
        });

        final filteredPresets = allPresets.where((item) {
          final menuName = item['menu']?.toString() ?? '';
          return menuName.contains(searchQuery);
        }).toList();

        if (filteredPresets.isEmpty) {
          return const Center(child: Text("검색 결과가 없습니다."));
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: filteredPresets.length,
          itemBuilder: (context, index) {
            final item = filteredPresets[index];
            final int totalSeconds = item['time'] ?? 0;
            final int minutes = totalSeconds ~/ 60;
            final int seconds = totalSeconds % 60;
            final clickCount = clickData[item['menu']] ?? 0;

            // 인기 뱃지 표시용 메뉴명
            final String menuDisplay = clickCount > 0
                ? "${item['menu']}  🔥$clickCount"
                : item['menu'] ?? '메뉴명 없음';

            final String timeText = "${minutes}분 ${seconds}초";

            return TimerCard(
              menu: menuDisplay,
              timeText: timeText,
              onTap: () {
                FirebaseService.addRecipeClick(item['menu'] ?? 'unknown_timer');
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TimerView(
                      menuName: item['menu'] ?? '타이머',
                      totalSeconds: totalSeconds,
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}