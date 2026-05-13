import 'dart:async';
import 'package:flutter/material.dart';

class RecipeDetailScreen extends StatefulWidget {
  final Map<String, dynamic> recipe;

  const RecipeDetailScreen({super.key, required this.recipe});

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  int? _activeStep;
  int _remainingSeconds = 0;
  Timer? _timer;
  bool _isTimerRunning = false;

  // 🔥 전자레인지 요리인지 확인
  bool get _isMicrowaveRecipe => widget.recipe['isMicrowave'] ?? false;

  void _startCooking() {
    setState(() {
      _activeStep = 0;
      _checkAndStartStepTimer();
    });
  }

  void _nextStep() {
    final steps = widget.recipe['steps'] as List;
    if (_activeStep! < steps.length - 1) {
      setState(() {
        _timer?.cancel();
        _isTimerRunning = false;
        _activeStep = _activeStep! + 1;
        _checkAndStartStepTimer();
      });
    } else {
      _showFinishDialog();
    }
  }

  void _checkAndStartStepTimer() {
    final steps = widget.recipe['steps'] as List;
    final currentStepText = steps[_activeStep!];

    // 🔥 전자레인지 요리가 아닐 때만 '타이머:' 문구를 찾아 자동 타이머 실행
    if (!_isMicrowaveRecipe && currentStepText.contains('타이머:')) {
      _remainingSeconds = _parseTimerSeconds(currentStepText);
      _startTimer();
    }
  }

  int _parseTimerSeconds(String text) {
    // '타이머:' 또는 '권장:' 뒤의 시간을 파싱하도록 정규식 확장
    final regExp = RegExp(r'(?:타이머|권장):\s*(\d+)분(?:\s*(\d+)초)?');
    final match = regExp.firstMatch(text);
    if (match != null) {
      int minutes = int.parse(match.group(1)!);
      int seconds = match.group(2) != null ? int.parse(match.group(2)!) : 0;
      return (minutes * 60) + seconds;
    }
    return 0;
  }

  void _startTimer() {
    _isTimerRunning = true;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
      } else {
        _timer?.cancel();
        setState(() => _isTimerRunning = false);
        _nextStep();
      }
    });
  }

  void _showFinishDialog() {
    showDialog(
      context: context,
      // 🔥 외부 터치로도 안 꺼지게 하려면 false (자동으로만 꺼지게)
      barrierDismissible: false,
      builder: (context) {
        // 1초 후에 자동으로 다이얼로그 닫기
        Future.delayed(const Duration(seconds: 1), () {
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
            setState(() => _activeStep = null); // 조리 상태 초기화
          }
        });

        return AlertDialog(
          // 🔥 버튼(actions)을 아예 삭제했습니다.
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Center(
            child: Text("요리 완성!", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle, color: Colors.orange, size: 60),
              SizedBox(height: 15),
              Text("맛있는 식사 되세요!"),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final steps = widget.recipe['steps'] as List;
    final ingredients = widget.recipe['ingredients'] as List;
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: Text(widget.recipe['title'])),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          // 조리 시작 후, 타이머가 돌아가는 중이 아닐 때만 터치로 다음 단계 이동
          if (_activeStep != null && !_isTimerRunning) {
            _nextStep();
          }
        },
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  if (_activeStep == null) ...[
                    Text(widget.recipe['theme'],
                        style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    const Text("필요 재료", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 5),
                    Text(ingredients.join(', '),
                        style: TextStyle(fontSize: 15, color: isDarkMode ? Colors.white70 : Colors.black87)),
                    const Divider(height: 40),
                  ],
                  const Text("조리 순서", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  ...List.generate(steps.length, (index) {
                    bool isActive = _activeStep == index;
                    bool isDimmed = _activeStep != null && _activeStep != index;

                    return AnimatedOpacity(
                      duration: const Duration(milliseconds: 300),
                      opacity: isDimmed ? 0.3 : 1.0,
                      child: Card(
                        color: isActive
                            ? (isDarkMode ? Colors.orange.withValues(alpha: 0.1) : Colors.orange[50])
                            : (isDarkMode ? Colors.grey[850] : Colors.white),
                        elevation: isActive ? 4 : 1,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Step ${index + 1}",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: isActive ? Colors.orange : Colors.grey)),
                              const SizedBox(height: 8),
                              Text(steps[index], style: const TextStyle(fontSize: 16)),

                              // 🔥 전자레인지 요리인 경우: 시간 정보만 강조해서 표시
                              if (isActive && _isMicrowaveRecipe && steps[index].contains('권장:')) ...[
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.microwave, color: Colors.blue, size: 18),
                                      const SizedBox(width: 8),
                                      Text(
                                        "조리 후 다음 단계로 넘어가려면 화면을 터치하세요",
                                        style: TextStyle(color: isDarkMode ? Colors.blue[200] : Colors.blue[700], fontSize: 12, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                              ],

                              // 냄비 요리인 경우: 기존 진행 바 표시
                              if (isActive && !_isMicrowaveRecipe && _remainingSeconds > 0) ...[
                                const SizedBox(height: 15),
                                LinearProgressIndicator(
                                  value: _remainingSeconds / _parseTimerSeconds(steps[index]),
                                  backgroundColor: Colors.orange[100],
                                  color: Colors.orange,
                                ),
                                const SizedBox(height: 8),
                                Text("${_remainingSeconds ~/ 60}분 ${_remainingSeconds % 60}초 남음",
                                    style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
                              ]
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
            if (_activeStep == null)
              Padding(
                padding: const EdgeInsets.all(20),
                child: SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: _startCooking,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                    child: const Text("조리 시작",
                        style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}