import 'package:flutter/material.dart';
import '../data/recipe_data.dart';
import 'timer_view.dart';

class TimerScreen extends StatelessWidget {
  const TimerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // RecipeData.timerPresets 데이터를 가져옴
    final presets = RecipeData.timerPresets;

    return Scaffold(
      appBar: AppBar(title: const Text("정밀 타이머")),
      body: ListView.builder(
        itemCount: presets.length,
        itemBuilder: (context, index) { // index 인자 추가로 에러 해결
          final item = presets[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: const Icon(Icons.timer_outlined),
              title: Text(item['menu'] ?? '메뉴명 없음'),
              subtitle: Text(item['category'] ?? '카테고리 없음'),
              trailing: Text("${(item['time'] ?? 0) ~/ 60}분 ${(item['time'] ?? 0) % 60}초"),
              onTap: () {
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