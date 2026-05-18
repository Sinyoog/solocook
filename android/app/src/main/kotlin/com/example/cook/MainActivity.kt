package com.example.cook

import android.content.Intent
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.cook/timer"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        val channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)

        channel.setMethodCallHandler { call, result ->
            when (call.method) {
                // 🔥 타이머 시작 - 포그라운드 서비스 시작
                "startTimer" -> {
                    val seconds = call.argument<Int>("seconds") ?: 0
                    val menuName = call.argument<String>("menuName") ?: "타이머"
                    val intent = Intent(this, TimerForegroundService::class.java).apply {
                        action = TimerForegroundService.ACTION_START
                        putExtra(TimerForegroundService.EXTRA_SECONDS, seconds)
                        putExtra(TimerForegroundService.EXTRA_MENU_NAME, menuName)
                    }
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                        startForegroundService(intent)
                    } else {
                        startService(intent)
                    }
                    result.success(null)
                }

                // 🔥 매초 Flutter 타이머가 알림창 숫자 업데이트 요청
                "updateTimer" -> {
                    val seconds = call.argument<Int>("seconds") ?: 0
                    val intent = Intent(this, TimerForegroundService::class.java).apply {
                        action = TimerForegroundService.ACTION_UPDATE
                        putExtra(TimerForegroundService.EXTRA_SECONDS, seconds)
                    }
                    startService(intent)
                    result.success(null)
                }

                // 🔥 타이머 완료 - 완료 알림 표시
                "finishTimer" -> {
                    val intent = Intent(this, TimerForegroundService::class.java).apply {
                        action = TimerForegroundService.ACTION_FINISH
                    }
                    startService(intent)
                    result.success(null)
                }

                // 🔥 타이머 중지
                "stopTimer" -> {
                    val intent = Intent(this, TimerForegroundService::class.java).apply {
                        action = TimerForegroundService.ACTION_STOP
                    }
                    startService(intent)
                    result.success(null)
                }

                else -> result.notImplemented()
            }
        }
    }
}