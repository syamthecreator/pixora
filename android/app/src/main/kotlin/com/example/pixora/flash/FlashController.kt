package com.example.pixora.flash

import android.content.Context
import android.hardware.camera2.CameraCharacteristics
import android.hardware.camera2.CameraManager

class FlashController(context: Context) {

    private val cameraManager =
        context.getSystemService(Context.CAMERA_SERVICE) as CameraManager

    private val cameraId: String? = cameraManager.cameraIdList.firstOrNull { id ->
        val characteristics = cameraManager.getCameraCharacteristics(id)
        characteristics.get(CameraCharacteristics.FLASH_INFO_AVAILABLE) == true
    }

    fun setFlashMode(mode: String?) {
        val id = cameraId ?: return

        when (mode) {
            "on" -> cameraManager.setTorchMode(id, true)
            "off", "auto" -> cameraManager.setTorchMode(id, false)
        }
    }
}
