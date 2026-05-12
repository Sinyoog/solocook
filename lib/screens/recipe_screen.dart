import 'package:flutter/material.dart';
import '../data/recipe_data.dart';
import 'recipe_detail_screen.dart';
import '../services/firebase_service.dart';

class RecipeScreen extends StatelessWidget {
  final String searchQuery;

  const RecipeScreen({super.key, required this.searchQuery});

  @override
  Widget build(BuildContext context) {
    final allRecipes = RecipeData.specialRecipes;
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
          return Card(
            elevation: 3,
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              title: Text("[${recipe['theme']}] ${recipe['title']}",
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text("\n터치하여 상세 조리법 보기"),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // 🔥 [추가] 서버에 레시피 조회 기록 전송
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
  }
}