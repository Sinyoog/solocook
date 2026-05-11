import 'package:flutter/material.dart';

class ExpiryConfirmDialog extends StatelessWidget {
  final String detectedDate;
  final Function(String) onConfirm;

  const ExpiryConfirmDialog({super.key, required this.detectedDate, required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("유통기한 확인"),
      content: Text("인식된 날짜: $detectedDate\n이 날짜가 맞나요?"),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("취소")),
        TextButton(onPressed: () => onConfirm(detectedDate), child: const Text("확인")),
      ],
    );
  }
}