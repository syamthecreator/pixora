package com.example.pixora.camera

import android.content.Context
import android.util.Log
import androidx.lifecycle.LifecycleOwner
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory
import jp.co.cyberagent.android.gpuimage.GPUImageView

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

            // 🔥 REPLACED PreviewView WITH GPUImageView (REQUIRED)
            private val gpuImageView = GPUImageView(context).apply {
        layoutParams = android.view.ViewGroup.LayoutParams(
            android.view.ViewGroup.LayoutParams.MATCH_PARENT,
            android.view.ViewGroup.LayoutParams.MATCH_PARENT
        )
    }


            init {
                Log.d(TAG, "Initializing CameraController")

                // 🔥 PASS GPUImageView TO CONTROLLER
                cameraController = CameraController(
                    context,
                    gpuImageView
                )

                Log.d(TAG, "Starting camera from PlatformView")
                cameraController.startCamera(lifecycleOwner)
            }

            override fun getView() = gpuImageView

            override fun dispose() {
                Log.d(TAG, "Disposing Camera PlatformView")
            }
        }
    }
}
