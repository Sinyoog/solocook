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
    if (currentStepText.contains('타이머:')) {
      _remainingSeconds = _parseTimerSeconds(currentStepText);
      _startTimer();
    }
  }

  int _parseTimerSeconds(String text) {
    final regExp = RegExp(r'(\d+)분(?:\s*(\d+)초)?');
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
      builder: (context) =>
          AlertDialog(
            title: const Text("요리 완성!"),
            content: const Text("맛있는 식사 되세요!"),
            actions: [
              TextButton(onPressed: () {
                Navigator.pop(context);
                setState(() => _activeStep = null);
              }, child: const Text("확인"))
            ],
          ),
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

    return Scaffold(
      appBar: AppBar(title: Text(widget.recipe['title'])),
      // [수정 포인트 1] body 전체를 GestureDetector로 감쌉니다.
      body: GestureDetector(
        behavior: HitTestBehavior.opaque, // 빈 공간 클릭도 감지하도록 설정
        onTap: () {
          // 조리가 시작된 상태이고, 타이머가 돌아가는 중이 아닐 때만 터치로 다음 단계 이동
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
                        style: const TextStyle(
                            color: Colors.orange, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    const Text("필요 재료", style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 5),
                    Text(ingredients.join(', '), style: const TextStyle(
                        fontSize: 15, color: Colors.black87)),
                    const Divider(height: 40),
                  ],

                  const Text("조리 순서", style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),

                  ...List.generate(steps.length, (index) {
                    bool isActive = _activeStep == index;
                    bool isDimmed = _activeStep != null && _activeStep != index;

                    // [수정 포인트 2] 개별 Card에 있던 GestureDetector는 이제 필요 없으므로 제거하거나 그대로 둡니다.
                    return AnimatedOpacity(
                      duration: const Duration(milliseconds: 300),
                      opacity: isDimmed ? 0.3 : 1.0,
                      child: Card(
                        color: isActive ? Colors.orange[50] : Colors.white,
                        elevation: isActive ? 4 : 1,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Step ${index + 1}",
                                  style: TextStyle(fontWeight: FontWeight.bold,
                                      color: isActive ? Colors.orange : Colors
                                          .grey)),
                              const SizedBox(height: 8),
                              Text(steps[index],
                                  style: const TextStyle(fontSize: 16)),

                              if (isActive && _remainingSeconds > 0) ...[
                                const SizedBox(height: 15),
                                LinearProgressIndicator(
                                  value: _remainingSeconds /
                                      _parseTimerSeconds(steps[index]),
                                  backgroundColor: Colors.orange[100],
                                  color: Colors.orange,
                                ),
                                const SizedBox(height: 8),
                                Text("${_remainingSeconds ~/
                                    60}분 ${_remainingSeconds % 60}초 남음",
                                    style: const TextStyle(color: Colors.orange,
                                        fontWeight: FontWeight.bold)),
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
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30))
                    ),
                    child: const Text("조리 시작", style: TextStyle(fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}