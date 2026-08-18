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
        if (overlay != null) {
            return
        }

        val root = activity.window.decorView as ViewGroup

        // The Flutter content.
        // We blur everything behind our privacy overlay.
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            blurredView = root

            root.setRenderEffect(
                RenderEffect.createBlurEffect(
                    25f,
                    25f,
                    Shader.TileMode.CLAMP
                )
            )
        }

        // Overlay shown above the blurred Flutter content.
        val privacyOverlay = FrameLayout(activity).apply {
            setBackgroundColor(
                Color.argb(
                    180,      // alpha
                    89,       // #59
                    199,      // #C7
                    216       // #D8
                )
            )
        }

        val size = TypedValue.applyDimension(
            TypedValue.COMPLEX_UNIT_DIP,
            180f,
            activity.resources.displayMetrics
        ).toInt()

        val icon = ImageView(activity).apply {
            setImageResource(R.drawable.splash)
            scaleType = ImageView.ScaleType.FIT_CENTER
        }

        privacyOverlay.addView(
            icon,
            FrameLayout.LayoutParams(size, size).apply {
                gravity = Gravity.CENTER
            }
        )

        root.addView(
            privacyOverlay,
            ViewGroup.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.MATCH_PARENT
            )
        )

        overlay = privacyOverlay
    }

    fun hide() {
        // Remove overlay
        overlay?.let { view ->
            (view.parent as? ViewGroup)?.removeView(view)
        }

        overlay = null

        // Remove blur
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            (blurredView as? ViewGroup)?.setRenderEffect(null)
        }

        blurredView = null
    }
}