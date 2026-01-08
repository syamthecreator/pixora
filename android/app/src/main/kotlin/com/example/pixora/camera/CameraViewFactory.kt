package com.example.pixora.camera

import android.content.Context
import androidx.camera.view.PreviewView
import androidx.lifecycle.LifecycleOwner
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

class CameraViewFactory(
    private val lifecycleOwner: LifecycleOwner
) : PlatformViewFactory(StandardMessageCodec.INSTANCE) {

    override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
        return object : PlatformView {

            private val previewView = PreviewView(context).apply {
                // 🔥 THIS IS THE KEY LINE
                scaleType = PreviewView.ScaleType.FIT_CENTER
                implementationMode = PreviewView.ImplementationMode.COMPATIBLE
            }

            private val controller = CameraController(context, previewView)

            init {
                controller.startCamera(lifecycleOwner)
            }

            override fun getView() = previewView
            override fun dispose() {}
        }
    }
}
