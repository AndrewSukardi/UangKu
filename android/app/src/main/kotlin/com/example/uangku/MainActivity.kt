package com.example.uangku

import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {

    private lateinit var privacyOverlay: PrivacyOverlay

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        privacyOverlay = PrivacyOverlay(this)
    }

    override fun onPause() {
        privacyOverlay.show()
        super.onPause()
    }

    override fun onResume() {
        super.onResume()

        privacyOverlay.hide()
    }
}