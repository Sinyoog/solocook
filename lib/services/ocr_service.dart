import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OCRService {
  final TextRecognizer _textRecognizer = TextRecognizer(script: TextRecognitionScript.korean);

  Future<String?> extractExpiryDate(String imagePath) async {
    final inputImage = InputImage.fromFilePath(imagePath);
    final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);

    // 날짜 형식 패턴 (예: 2026.04.24, 26-04-24 등)
    RegExp datePattern = RegExp(r'(\d{2,4})[.\-/] ?(\d{1,2})[.\-/] ?(\d{1,2})');

    for (TextBlock block in recognizedText.blocks) {
      for (TextLine line in block.lines) {
        if (datePattern.hasMatch(line.text)) {
          return datePattern.firstMatch(line.text)?.group(0);
        }
      }
    }
    return null; // 날짜를 못 찾은 경우
  }

  void dispose() {
    _textRecognizer.close();
  }
}