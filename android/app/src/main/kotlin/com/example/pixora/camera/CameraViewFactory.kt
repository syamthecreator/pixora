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

    companion object {
        lateinit var cameraController: CameraController
    }

    override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
        return object : PlatformView {

            private val previewView = PreviewView(context).apply {
                scaleType = PreviewView.ScaleType.FILL_CENTER
                implementationMode = PreviewView.ImplementationMode.COMPATIBLE
            }

            init {
                cameraController = CameraController(context, previewView)
                cameraController.startCamera(lifecycleOwner)
            }

            override fun getView() = previewView
            override fun dispose() {}
        }
    }
}
