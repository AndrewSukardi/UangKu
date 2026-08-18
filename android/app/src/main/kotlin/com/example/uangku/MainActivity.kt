package com.example.uangku

import android.graphics.Color
import android.os.Bundle
import android.view.View
import android.widget.FrameLayout
import io.flutter.embedding.android.FlutterActivity


class MainActivity : FlutterActivity() {

    private var privacyView: View? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
    }

    private fun showPrivacyScreen() {
        if (privacyView != null) return

        val root = findViewById<FrameLayout>(android.R.id.content)

        val view = View(this)
        view.setBackgroundResource(R.drawable.privacy_background)

        root.addView(
            view,
            FrameLayout.LayoutParams(
                FrameLayout.LayoutParams.MATCH_PARENT,
                FrameLayout.LayoutParams.MATCH_PARENT
            )
        )

        privacyView = view
    }

    private fun hidePrivacyScreen() {
        privacyView?.let { view ->
            val root = findViewById<FrameLayout>(android.R.id.content)
            root.removeView(view)
        }

        privacyView = null
    }

    override fun onWindowFocusChanged(hasFocus: Boolean) {
        super.onWindowFocusChanged(hasFocus)

        if (hasFocus) {
            hidePrivacyScreen()
        } else {
            showPrivacyScreen()
        }
    }
}