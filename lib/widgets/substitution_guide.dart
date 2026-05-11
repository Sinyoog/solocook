import 'package:flutter/material.dart';

class SubstitutionGuide extends StatelessWidget {
  final String ingredient;

  const SubstitutionGuide({super.key, required this.ingredient});

  @override
  Widget build(BuildContext context) {
    // 기획 데이터 매핑
    final Map<String, String> guides = {
      '굴소스': '간장(1) + 설탕(0.5) + 다시다 약간',
      '맛술': '남은 소주/청주 + 설탕 조금',
      '고추장': '고춧가루(2) + 간장(1) + 설탕(1) + 물 약간',
      '전분가루': '밀가루나 튀김가루로 대체 가능',
    };

    return AlertDialog(
      title: Text('$ingredient 대체 가이드'),
      content: Text(guides[ingredient] ?? '대체 정보가 없습니다.'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('확인')),
      ],
    );
  }
}