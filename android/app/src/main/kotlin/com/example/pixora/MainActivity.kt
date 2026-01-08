package com.example.pixora

import com.example.pixora.flash.FlashController
import com.example.pixora.camera.CameraViewFactory
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val FLASH_CHANNEL = "pixora/flash"
    private val CAMERA_CHANNEL = "pixora/camera"

    private lateinit var flashController: FlashController

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        flashController = FlashController(this)

        registerFlashChannel(flutterEngine)
        registerCameraChannel(flutterEngine)

        flutterEngine
            .platformViewsController
            .registry
            .registerViewFactory(
                "pixora/camera_preview",
                CameraViewFactory(this)
            )
    }

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
}
