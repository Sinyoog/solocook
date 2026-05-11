import 'package:flutter/material.dart';
import '../data/recipe_data.dart';
import 'recipe_detail_screen.dart'; // 상세 화면 이동을 위해 필요

class RecipeScreen extends StatelessWidget {
  const RecipeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final recipes = RecipeData.specialRecipes;

    return Scaffold(
      appBar: AppBar(title: const Text("자취 특화 레시피")),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: recipes.length,
        itemBuilder: (context, index) {
          final recipe = recipes[index];
          return Card(
            elevation: 3,
            margin: const EdgeInsets.only(bottom: 16), // .bottom에서 .only(bottom: 16)으로 수정
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              title: Text("[${recipe['theme']}] ${recipe['title']}",
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text("\n터치하여 상세 조리법 보기"),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // 상세 화면으로 이동하며 레시피 데이터 전달
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