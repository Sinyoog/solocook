import 'package:flutter/material.dart';
import '../data/recipe_data.dart';
import 'recipe_detail_screen.dart';
import '../services/firebase_service.dart';

class RecipeScreen extends StatelessWidget {
  final String searchQuery;

  const RecipeScreen({super.key, required this.searchQuery});

  @override
  Widget build(BuildContext context) {
    // 1. 서버에서 모든 클릭 데이터를 가져옵니다.
    return FutureBuilder<Map<String, int>>(
      future: FirebaseService.getClickCounts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Colors.orange));
        }

        final clickData = snapshot.data ?? {};

        // 2. 전체 레시피 데이터를 복사해서 클릭수 기준으로 정렬합니다.
        final allRecipes = List.from(RecipeData.specialRecipes);
        allRecipes.sort((a, b) {
          int countA = clickData[a['title']] ?? 0;
          int countB = clickData[b['title']] ?? 0;
          return countB.compareTo(countA); // 내림차순(인기순) 정렬
        });

        // 3. 정렬된 상태에서 검색어 필터링을 진행합니다.
        final filteredRecipes = allRecipes.where((recipe) {
          final title = recipe['title']?.toString() ?? '';
          return title.contains(searchQuery);
        }).toList();

        return Scaffold(
          body: filteredRecipes.isEmpty
              ? const Center(child: Text("검색 결과가 없습니다."))
              : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filteredRecipes.length,
            itemBuilder: (context, index) {
              final recipe = filteredRecipes[index];
              final clickCount = clickData[recipe['title']] ?? 0; // 이 레시피의 클릭수

              return Card(
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 16),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(
                          "[${recipe['theme']}] ${recipe['title']}",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      if (clickCount > 0) ...[
                        const SizedBox(width: 8),
                        // 🔥 인기 표시 뱃지
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.orange[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            "👍 $clickCount",
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.orange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  subtitle: const Text("\n터치하여 상세 조리법 보기"),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // 서버에 레시피 조회 기록 전송
                    FirebaseService.addRecipeClick(recipe['title'] ?? 'unknown_recipe');

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RecipeDetailScreen(recipe: recipe),
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