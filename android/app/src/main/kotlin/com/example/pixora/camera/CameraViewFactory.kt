package com.example.pixora.camera

import android.content.Context
import android.util.Log
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

    private val TAG = "PixoraCameraView"

    override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
        Log.d(TAG, "Creating Camera PlatformView. viewId=$viewId args=$args")

        return object : PlatformView {

            private val previewView = PreviewView(context).apply {
                Log.d(TAG, "Initializing PreviewView")

                scaleType = PreviewView.ScaleType.FILL_CENTER
                implementationMode = PreviewView.ImplementationMode.COMPATIBLE

                Log.d(
                    TAG,
                    "PreviewView configured | scaleType=FILL_CENTER | implementation=COMPATIBLE"
                )
            }

            init {
                Log.d(TAG, "Initializing CameraController")
                cameraController = CameraController(context, previewView)

                Log.d(TAG, "Starting camera from PlatformView")
                cameraController.startCamera(lifecycleOwner)
            }

            override fun getView() = previewView

            override fun dispose() {
                Log.d(TAG, "Disposing Camera PlatformView")
            }
        }
    }
}
