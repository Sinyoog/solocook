import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class TextRecognitionService {
  // 한국어 인식을 위해 글자 인식기 설정
  final TextRecognizer _textRecognizer = TextRecognizer(script: TextRecognitionScript.korean);

  Future<String?> extractExpiryDate(String imagePath) async {
    final inputImage = InputImage.fromFilePath(imagePath);
    final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);

    // 유통기한을 찾기 위한 정규식 (2026.12.31, 26/12/31, 20261231 등 대응)
    RegExp dateRegExp = RegExp(r'(\d{2,4})[./-]?(\d{1,2})[./-]?(\d{1,2})');

    for (TextBlock block in recognizedText.blocks) {
      for (TextLine line in block.lines) {
        // 읽어온 글자에서 날짜 형식만 골라냄
        final match = dateRegExp.firstMatch(line.text);
        if (match != null) {
          String year = match.group(1)!;
          // '26'으로 읽히면 '2026'으로 보정
          if (year.length == 2) year = '20$year';

          String month = match.group(2)!.padLeft(2, '0');
          String day = match.group(3)!.padLeft(2, '0');

          return "$year-$month-$day"; // 최종 날짜 반환
        }
      }
    }
    return null; // 날짜를 못 찾았을 때
  }

  void dispose() {
    _textRecognizer.close();
  }
}