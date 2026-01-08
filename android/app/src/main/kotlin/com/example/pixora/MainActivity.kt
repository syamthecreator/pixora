package com.example.pixora

import com.example.pixora.flash.FlashController
import com.example.pixora.camera.CameraViewFactory
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    // ---------- Channels ----------
    private val FLASH_CHANNEL = "pixora/flash"

    // ---------- Controllers ----------
    private lateinit var flashController: FlashController

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // ---------------- Flash ----------------
        flashController = FlashController(this)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
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

        // ---------------- Camera Preview ----------------
        flutterEngine
            .platformViewsController
            .registry
            .registerViewFactory(
                "pixora/camera_preview",
                CameraViewFactory(this)
            )
    }
}
