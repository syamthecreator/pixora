package com.example.pixora

import android.app.Activity
import android.content.Intent
import android.content.IntentSender
import android.provider.MediaStore
import com.example.pixora.flash.FlashController
import com.example.pixora.camera.CameraViewFactory
import com.example.pixora.media.MediaDeleteHandler
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val FLASH_CHANNEL = "pixora/flash"
    private val CAMERA_CHANNEL = "pixora/camera"
    private val MEDIA_CHANNEL = "pixora/media"

    private lateinit var flashController: FlashController
    private lateinit var mediaDeleteHandler: MediaDeleteHandler
    private var mediaResultChannel: MethodChannel? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        flashController = FlashController(this)
        mediaDeleteHandler = MediaDeleteHandler(this)

        registerFlashChannel(flutterEngine)
        registerCameraChannel(flutterEngine)
        registerMediaChannel(flutterEngine)

        flutterEngine
            .platformViewsController
            .registry
            .registerViewFactory(
                "pixora/camera_preview",
                CameraViewFactory(this)
            )
    }

    // ---------------- FLASH ----------------
    private fun registerFlashChannel(engine: FlutterEngine) {
        MethodChannel(
            engine.dartExecutor.binaryMessenger,
            FLASH_CHANNEL
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "setFlashMode" -> {
                    val mode = call.argument<String>("mode")
                    flashController.setFlashMode(mode)
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    // ---------------- CAMERA ----------------
    private fun registerCameraChannel(engine: FlutterEngine) {
        MethodChannel(
            engine.dartExecutor.binaryMessenger,
            CAMERA_CHANNEL
        ).setMethodCallHandler { call, result ->
            when (call.method) {

                "switchCamera" -> {
                    CameraViewFactory.cameraController.switchCamera(this)
                    result.success(null)
                }

                "takePhoto" -> {
                    val flash = call.argument<String>("flash") ?: "off"
                    CameraViewFactory.cameraController.takePhoto(flash) {
                        result.success(it)
                    }
                }

                "startRecording" -> {
                    CameraViewFactory.cameraController.startRecording {
                        result.success(it)
                    }
                }

                "stopRecording" -> {
                    CameraViewFactory.cameraController.stopRecording()
                    result.success(null)
                }

                else -> result.notImplemented()
            }
        }
    }

    // ---------------- MEDIA DELETE ----------------
    private fun registerMediaChannel(engine: FlutterEngine) {
        mediaResultChannel = MethodChannel(
            engine.dartExecutor.binaryMessenger,
            MEDIA_CHANNEL
        )

        mediaResultChannel!!.setMethodCallHandler { call, result ->
            when (call.method) {
                "deleteImage" -> {
                    val path = call.argument<String>("path")
                    if (path == null) {
                        result.error("INVALID_PATH", "Path is null", null)
                        return@setMethodCallHandler
                    }

                    // 🔥 This triggers SYSTEM delete confirmation dialog
                    mediaDeleteHandler.requestDeleteImage(path)
                    result.success(null) // result returned via onActivityResult
                }
                else -> result.notImplemented()
            }
        }
    }

    // ---------------- DELETE RESULT ----------------
    override fun onActivityResult(
        requestCode: Int,
        resultCode: Int,
        data: Intent?
    ) {
        super.onActivityResult(requestCode, resultCode, data)

        if (requestCode == MediaDeleteHandler.DELETE_REQUEST_CODE) {
            mediaResultChannel?.invokeMethod(
                "deleteResult",
                resultCode == Activity.RESULT_OK
            )
        }
    }
}
