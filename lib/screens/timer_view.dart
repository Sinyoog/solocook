import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import '../services/timer_service.dart';

class TimerView extends StatefulWidget {
  final String menuName;
  final int totalSeconds;

  const TimerView({super.key, required this.menuName, required this.totalSeconds});

  @override
  State<TimerView> createState() => _TimerViewState();
}

class _TimerViewState extends State<TimerView> {
  final _timerService = TimerService();
  StreamSubscription<int>? _tickSub;
  StreamSubscription<String>? _finishSub;

  // 현재 화면에 표시할 값 (서비스 상태 반영)
  late int _displaySeconds;
  late bool _isRunning;

  @override
  void initState() {
    super.initState();

    // 🔥 서비스가 이미 이 메뉴 타이머를 돌고 있으면 그 상태 이어받기
    if (_timerService.isRunning && _timerService.menuName == widget.menuName) {
      _displaySeconds = _timerService.remainingSeconds;
      _isRunning = true;
    } else {
      _displaySeconds = widget.totalSeconds;
      _isRunning = false;
    }

    // 매초 업데이트 구독
    _tickSub = _timerService.tickStream.listen((seconds) {
      if (!mounted) return;
      // 이 화면의 메뉴와 현재 실행 중인 메뉴가 같을 때만 업데이트
      if (_timerService.menuName == widget.menuName) { // 🔥 같은 메뉴일 때만 업데이트
        setState(() {
          _displaySeconds = seconds;
          _isRunning = _timerService.isRunning;
        });
      }
    });

    // 완료 이벤트 구독
    _finishSub = _timerService.finishStream.listen((finishedMenu) {
      if (!mounted) return;
      if (finishedMenu == widget.menuName) {
        setState(() {
          _displaySeconds = 0;
          _isRunning = false;
        });
        _showFinishDialog();
      }
    });
  }

  void _toggleTimer() {
    if (_isRunning) {
      _timerService.pause();
      setState(() => _isRunning = false);
    } else {
      _timerService.start(widget.menuName, _displaySeconds);
      setState(() => _isRunning = true);
    }
  }

  void _resetTimer() {
    _timerService.reset();
    setState(() {
      _displaySeconds = widget.totalSeconds;
      _isRunning = false;
    });
  }

  void _showFinishDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        Timer(const Duration(seconds: 5), () {
          if (context.mounted && Navigator.canPop(context)) {
            Navigator.pop(context);
          }
        });
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.alarm_on, color: Colors.orange, size: 60),
              const SizedBox(height: 15),
              Text(
                "${widget.menuName} 완료!",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              const Text("화면을 누르면 알람이 꺼집니다."),
            ],
          ),
        );
      },
    ).then((_) {
      FlutterRingtonePlayer().stop();
      _resetTimer();
    });
  }

  @override
  void dispose() {
    // 🔥 화면 닫혀도 타이머 서비스는 계속 실행
    // 구독만 해제 (메모리 누수 방지)
    _tickSub?.cancel();
    _finishSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double progress = widget.totalSeconds > 0
        ? (_displaySeconds / widget.totalSeconds).clamp(0.0, 1.0)
        : 0.0;

    return Scaffold(
      appBar: AppBar(title: Text(widget.menuName)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isRunning)
              Container(
                margin: const EdgeInsets.only(bottom: 20),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.notifications_active, color: Colors.orange, size: 16),
                    SizedBox(width: 6),
                    Text(
                      "앱을 닫아도 알림창에서 확인 가능합니다",
                      style: TextStyle(
                        color: Colors.orange,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 280,
                  height: 280,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 12,
                    backgroundColor: Colors.grey[200],
                    color: Colors.orange,
                  ),
                ),
                Text(
                  '${(_displaySeconds ~/ 60).toString().padLeft(2, '0')}:${(_displaySeconds % 60).toString().padLeft(2, '0')}',
                  style: const TextStyle(
                    fontSize: 60,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 60),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: _toggleTimer,
                  icon: Icon(_isRunning ? Icons.pause : Icons.play_arrow),
                  label: Text(_isRunning ? '일시정지' : '시작'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isRunning ? Colors.grey[400] : Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 20),
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