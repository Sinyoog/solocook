import 'package:flutter/material.dart';
import '../data/recipe_data.dart';

class SubstitutionGuide extends StatelessWidget {
  final String ingredient;

  const SubstitutionGuide({super.key, required this.ingredient});

  @override
  Widget build(BuildContext context) {
    final String? guide = RecipeData.substitutionGuide[ingredient];

    return AlertDialog(
      title: Text('$ingredient 대체 가이드'),
      content: Text(guide ?? '대체 정보가 없습니다.'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('확인')),
      ],
    );
  }
}