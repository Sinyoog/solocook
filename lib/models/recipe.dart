class Recipe {
  final String title;       // 메뉴 이름
  final String time;        // 표시용 시간 (03:30)
  final int totalSeconds;   // 실제 타이머 초
  final List<String> steps; // 상세 레시피 순서

  Recipe({
    required this.title,
    required this.time,
    required this.totalSeconds,
    required this.steps,
  });
}