package com.example.pixora

import android.app.Activity
import android.content.Intent
import android.util.Log
import com.example.pixora.flash.FlashController
import com.example.pixora.camera.CameraViewFactory
import com.example.pixora.media.MediaDeleteHandler
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val TAG = "PixoraMain"

    private val FLASH_CHANNEL = "pixora/flash"
    private val CAMERA_CHANNEL = "pixora/camera"
    private val MEDIA_CHANNEL = "pixora/media"

    private lateinit var flashController: FlashController
    private lateinit var mediaDeleteHandler: MediaDeleteHandler
    private var mediaResultChannel: MethodChannel? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        Log.d(TAG, "Configuring FlutterEngine")

        flashController = FlashController()
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

        Log.d(TAG, "Camera PlatformView registered")
    }

    // ---------------- FLASH ----------------
    private fun registerFlashChannel(engine: FlutterEngine) {
        Log.d(TAG, "Registering FLASH channel")

        MethodChannel(
            engine.dartExecutor.binaryMessenger,
            FLASH_CHANNEL
        ).setMethodCallHandler { call, result ->

            Log.d(TAG, "FLASH channel call: ${call.method}")

            when (call.method) {
                "setFlashMode" -> {
                    val mode = call.argument<String>("mode")
                    Log.d(TAG, "Setting flash mode: $mode")
                    flashController.setFlashMode(mode)
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    // ---------------- CAMERA ----------------
    private fun registerCameraChannel(engine: FlutterEngine) {
        Log.d(TAG, "Registering CAMERA channel")

        MethodChannel(
            engine.dartExecutor.binaryMessenger,
            CAMERA_CHANNEL
        ).setMethodCallHandler { call, result ->

            Log.d(TAG, "CAMERA channel call: ${call.method}")

            when (call.method) {

                "switchCamera" -> {
                    Log.d(TAG, "Switch camera requested")
                    CameraViewFactory.cameraController.switchCamera(this)
                    result.success(null)
                }

                "takePhoto" -> {
                    val flash = call.argument<String>("flash") ?: "off"
                    Log.d(TAG, "Take photo requested | flash=$flash")

                    CameraViewFactory.cameraController.takePhoto(flash) {
                        Log.d(TAG, "Photo result returned to Flutter: $it")
                        result.success(it)
                    }
                }

                "startRecording" -> {
                    Log.d(TAG, "Start video recording requested")

                    CameraViewFactory.cameraController.startRecording {
                        Log.d(TAG, "Video saved: $it")
                        result.success(it)
                    }
                }

                "stopRecording" -> {
                    Log.d(TAG, "Stop video recording requested")
                    CameraViewFactory.cameraController.stopRecording()
                    result.success(null)
                }

                else -> result.notImplemented()
            }
        }
    }

    // ---------------- MEDIA DELETE ----------------
    private fun registerMediaChannel(engine: FlutterEngine) {
        Log.d(TAG, "Registering MEDIA channel")

        mediaResultChannel = MethodChannel(
            engine.dartExecutor.binaryMessenger,
            MEDIA_CHANNEL
        )

        mediaResultChannel!!.setMethodCallHandler { call, result ->

            Log.d(TAG, "MEDIA channel call: ${call.method}")

            when (call.method) {
                "deleteImage" -> {
                    val path = call.argument<String>("path")

                    if (path == null) {
                        Log.e(TAG, "Delete image failed: path is null")
                        result.error("INVALID_PATH", "Path is null", null)
                        return@setMethodCallHandler
                    }

                    Log.d(TAG, "Requesting delete for image: $path")

                    // 🔥 Triggers system delete confirmation dialog
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

        Log.d(
            TAG,
            "onActivityResult | requestCode=$requestCode resultCode=$resultCode"
        )

        if (requestCode == MediaDeleteHandler.DELETE_REQUEST_CODE) {
            val success = resultCode == Activity.RESULT_OK

            Log.d(TAG, "Media delete result: success=$success")

            mediaResultChannel?.invokeMethod(
                "deleteResult",
                success
            )
        }
    }
}
