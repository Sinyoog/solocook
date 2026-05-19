import 'package:flutter/material.dart';
import '../data/recipe_data.dart';
import '../models/food_model.dart';
import 'recipe_detail_screen.dart';

class RecipeRecommendScreen extends StatelessWidget {
  final List<FoodModel> foods;

  const RecipeRecommendScreen({super.key, required this.foods});

  // 🔥 냉장고 재료명과 레시피 재료 매칭 로직
  List<Map<String, dynamic>> _getRecommendedRecipes() {
    // 냉장고 재료명 리스트 (소문자, 공백 제거)
    final fridgeItems = foods.map((f) => f.name.trim()).toList();

    List<Map<String, dynamic>> result = [];

    for (final recipe in RecipeData.specialRecipes) {
      final recipeIngredients = recipe['ingredients'] as List;
      int matchCount = 0;

      for (final ingredient in recipeIngredients) {
        final ingStr = ingredient.toString();
        // 냉장고 재료 중 하나라도 레시피 재료에 포함되면 매칭
        for (final fridgeItem in fridgeItems) {
          if (ingStr.contains(fridgeItem) || fridgeItem.contains(ingStr.split(' ')[0])) {
            matchCount++;
            break;
          }
        }
      }

      if (matchCount > 0) {
        result.add({
          ...recipe,
          'matchCount': matchCount,
          'totalIngredients': recipeIngredients.length,
        });
      }
    }

    // 매칭 재료 많은 순으로 정렬
    result.sort((a, b) => (b['matchCount'] as int).compareTo(a['matchCount'] as int));
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final recommended = _getRecommendedRecipes();
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("냉장고 재료로 만들 수 있는 요리",
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: recommended.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 60, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              "매칭되는 레시피가 없습니다.\n냉장고에 재료를 추가해보세요!",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: recommended.length,
        itemBuilder: (context, index) {
          final recipe = recommended[index];
          final int matchCount = recipe['matchCount'] as int;
          final int totalCount = recipe['totalIngredients'] as int;
          final double matchRatio = matchCount / totalCount;

          // 매칭률에 따라 색상 변경
          Color matchColor = Colors.red;
          if (matchRatio >= 0.8) matchColor = Colors.green;
          else if (matchRatio >= 0.5) matchColor = Colors.orange;

          return Card(
            elevation: 3,
            margin: const EdgeInsets.only(bottom: 16),
            color: isDarkMode ? Colors.grey[850] : Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: InkWell(
              borderRadius: BorderRadius.circular(15),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RecipeDetailScreen(recipe: recipe),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            recipe['title'],
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        // 🔥 매칭률 뱃지
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: matchColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: matchColor.withValues(alpha: 0.4)),
                          ),
                          child: Text(
                            "$matchCount / $totalCount 재료",
                            style: TextStyle(
                              fontSize: 12,
                              color: matchColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      recipe['theme'],
                      style: const TextStyle(color: Colors.orange, fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                    // 🔥 매칭률 프로그레스 바
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: matchRatio,
                        backgroundColor: Colors.grey[200],
                        color: matchColor,
                        minHeight: 6,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "필요 재료: ${(recipe['ingredients'] as List).join(', ')}",
                      style: TextStyle(
                        fontSize: 12,
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}