import 'dart:async';
import 'package:flutter/material.dart';

class TimerView extends StatefulWidget {
  final String menuName;
  final int totalSeconds;

  const TimerView({super.key, required this.menuName, required this.totalSeconds});

  @override
  State<TimerView> createState() => _TimerViewState();
}

class _TimerViewState extends State<TimerView> {
  late int _remainingSeconds;
  Timer? _timer;
  bool _isRunning = false;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.totalSeconds;
  }

  // 타이머 작동 로직
  void _toggleTimer() {
    if (_isRunning) {
      _timer?.cancel();
    } else {
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_remainingSeconds > 0) {
          setState(() => _remainingSeconds--);
        } else {
          _timer?.cancel();
          setState(() => _isRunning = false);
          _showFinishDialog();
        }
      });
    }
    setState(() => _isRunning = !_isRunning);
  }

  // 초기화 로직 (애니메이션 수치도 초기화됨)
  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _remainingSeconds = widget.totalSeconds;
      _isRunning = false;
    });
  }

  void _showFinishDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("요리 완료!"),
        content: Text("${widget.menuName} 조리가 끝났습니다."),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("확인", style: TextStyle(color: Colors.orange))
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel(); // 화면 나갈 때 타이머 해제
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 진행률 계산 (1.0에서 0.0으로 줄어듦)
    double progress = _remainingSeconds / widget.totalSeconds;

    return Scaffold(
      appBar: AppBar(title: Text(widget.menuName)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // --- 원형 애니메이션 부분 ---
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 280,
                  height: 280,
                  child: CircularProgressIndicator(
                    value: progress, // 시간에 따라 줄어드는 값
                    strokeWidth: 12,
                    backgroundColor: Colors.grey[200],
                    color: Colors.orange,
                  ),
                ),
                // 중앙 시간 표시
                Text(
                  '${(_remainingSeconds ~/ 60).toString().padLeft(2, '0')}:${(_remainingSeconds % 60).toString().padLeft(2, '0')}',
                  style: const TextStyle(
                      fontSize: 60,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace' // 숫자가 흔들리지 않게 고정폭 폰트 권장
                  ),
                ),
              ],
            ),
            const SizedBox(height: 60),
            // --- 버튼 영역 ---
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 시작/일시정지 버튼
                ElevatedButton.icon(
                  onPressed: _toggleTimer,
                  icon: Icon(_isRunning ? Icons.pause : Icons.play_arrow),
                  label: Text(_isRunning ? '일시정지' : '시작'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isRunning ? Colors.grey[400] : Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 20),
                // 초기화 버튼
                OutlinedButton.icon(
                  onPressed: _resetTimer,
                  icon: const Icon(Icons.refresh),
                  label: const Text("초기화"),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    side: const BorderSide(color: Colors.orange),
                    foregroundColor: Colors.orange,
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}