package com.example.pixora.flash

import android.util.Log
import com.example.pixora.camera.CameraViewFactory

/**
 * FlashController
 *
 * OEM-style flash behavior (CameraX SAFE):
 *
 * "on"   -> Torch ON immediately and stay ON
 * "auto" -> Torch OFF (CameraX handles flash during capture)
 * "off"  -> Torch OFF completely
 *
 * IMPORTANT:
 * - Uses CameraX torch control ONLY
 * - Never uses CameraManager (avoids CAMERA_IN_USE crash)
 */
class FlashController {

    private val TAG = "PixoraFlash"

    fun setFlashMode(mode: String?) {
        Log.d(TAG, "setFlashMode() called with mode=$mode")

        // CameraController created by PlatformView
        val cameraController = CameraViewFactory.cameraController

        when (mode) {

    "on" -> {
        cameraController.setTorch(true)
        cameraController.setFlashMode("on")
    }

    "auto" -> {
        cameraController.setTorch(false)
        cameraController.setFlashMode("auto")
    }

    else -> {
        cameraController.setTorch(false)
        cameraController.setFlashMode("off")
    }
}

    }
}
