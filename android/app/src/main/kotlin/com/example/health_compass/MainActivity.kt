package com.example.health_compass

import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import android.view.WindowManager.LayoutParams

class MainActivity: FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // هذا الكود يسمح للتطبيق بالظهور فوق شاشة القفل
        window.addFlags(LayoutParams.FLAG_SHOW_WHEN_LOCKED)
        window.addFlags(LayoutParams.FLAG_TURN_SCREEN_ON)
        window.addFlags(LayoutParams.FLAG_KEEP_SCREEN_ON)
    }
}