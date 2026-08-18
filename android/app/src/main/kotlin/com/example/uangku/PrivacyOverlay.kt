package com.example.uangku

import android.app.Activity
import android.graphics.Color
import android.view.ViewGroup
import android.widget.ImageView

class PrivacyOverlay(
    private val activity: Activity
) {

    private var view: ImageView? = null

    fun show() {
        if (view != null) {
            return
        }

        val root = activity.window.decorView as ViewGroup

        view = ImageView(activity).apply {
            setImageResource(R.drawable.splash)

            // Background
            setBackgroundColor(0xFF59C7D8.toInt())

            // Keep icon centered
            scaleType = ImageView.ScaleType.CENTER

            isClickable = false
            isFocusable = false
        }

        root.addView(
            view,
            ViewGroup.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.MATCH_PARENT
            )
        )
    }

    fun hide() {
        val privacyView = view ?: return

        (privacyView.parent as? ViewGroup)?.removeView(privacyView)

        view = null
    }
}