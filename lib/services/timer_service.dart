import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';

class TimerService {
  static final TimerService _instance = TimerService._internal();
  factory TimerService() => _instance;
  TimerService._internal();

  static const _channel = MethodChannel('com.example.cook/timer');

  Timer? _timer;
  int remainingSeconds = 0;
  int totalSeconds = 0;
  String menuName = '';
  bool isRunning = false;
  bool _starting = false; // 🔥 중복 start 방지 플래그

  final StreamController<int> _tickController = StreamController<int>.broadcast();
  Stream<int> get tickStream => _tickController.stream;

  final StreamController<String> _finishController = StreamController<String>.broadcast();
  Stream<String> get finishStream => _finishController.stream;

  Future<void> start(String menu, int seconds) async {
    if (_starting) return; // 🔥 이미 시작 중이면 무시
    _starting = true;

    // 기존 타이머 완전 중지
    _timer?.cancel();
    _timer = null;
    isRunning = false;

    // 네이티브 알림 중지
    try {
      await _channel.invokeMethod('stopTimer');
    } catch (e) {}

    // 중지/시작 타이밍 충돌 방지
    await Future.delayed(const Duration(milliseconds: 200));

    menuName = menu;
    totalSeconds = seconds;
    remainingSeconds = seconds;
    isRunning = true;

    // 네이티브 알림 시작
    try {
      await _channel.invokeMethod('startTimer', {
        'seconds': remainingSeconds,
        'menuName': menuName,
      });
    } catch (e) {}

    _starting = false;

    // Flutter 타이머 시작
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingSeconds > 0) {
        remainingSeconds--;
        _tickController.add(remainingSeconds);
        try {
          _channel.invokeMethod('updateTimer', {'seconds': remainingSeconds});
        } catch (e) {}
      } else {
        timer.cancel();
        _timer = null;
        isRunning = false;
        _finish();
      }
    });
  }

  void pause() async {
    _timer?.cancel();
    _timer = null;
    isRunning = false;
    try {
      await _channel.invokeMethod('stopTimer');
    } catch (e) {}
  }

  void reset() async {
    _timer?.cancel();
    _timer = null;
    isRunning = false;
    remainingSeconds = totalSeconds;
    menuName = '';
    try {
      await _channel.invokeMethod('stopTimer');
    } catch (e) {}
  }

  void _finish() async {
    final finishedMenu = menuName;
    menuName = '';
    remainingSeconds = 0;
    totalSeconds = 0;

    FlutterRingtonePlayer().playAlarm();
    try {
      await _channel.invokeMethod('finishTimer');
    } catch (e) {}

    _finishController.add(finishedMenu);
  }
}