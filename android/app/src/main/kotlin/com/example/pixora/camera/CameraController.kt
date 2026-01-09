package com.example.pixora.camera

import android.content.ContentValues
import android.content.Context
import android.provider.MediaStore
import android.util.Log
import androidx.camera.core.*
import androidx.camera.lifecycle.ProcessCameraProvider
import androidx.camera.video.*
import androidx.camera.view.PreviewView
import androidx.core.content.ContextCompat
import androidx.lifecycle.LifecycleOwner

class CameraController(
    private val context: Context,
    private val previewView: PreviewView
) {

    private val TAG = "PixoraCamera"

    private var lensFacing = CameraSelector.LENS_FACING_BACK

    private var imageCapture: ImageCapture? = null
    private var videoCapture: VideoCapture<Recorder>? = null
    private var activeRecording: Recording? = null

    fun startCamera(lifecycleOwner: LifecycleOwner) {
        Log.d(TAG, "Starting camera. Lens: ${if (lensFacing == CameraSelector.LENS_FACING_BACK) "BACK" else "FRONT"}")

        val cameraProviderFuture = ProcessCameraProvider.getInstance(context)

        cameraProviderFuture.addListener({
            val cameraProvider = cameraProviderFuture.get()

            Log.d(TAG, "Camera provider obtained")

            // -------- Preview --------
            val preview = Preview.Builder().build()
            preview.setSurfaceProvider(previewView.surfaceProvider)

            // -------- Photo --------
            imageCapture = ImageCapture.Builder()
                .setCaptureMode(ImageCapture.CAPTURE_MODE_MINIMIZE_LATENCY)
                .build()

            // -------- Video --------
            val recorder = Recorder.Builder()
                .setQualitySelector(QualitySelector.from(Quality.HIGHEST))
                .build()

            videoCapture = VideoCapture.withOutput(recorder)

            val selector = CameraSelector.Builder()
                .requireLensFacing(lensFacing)
                .build()

            cameraProvider.unbindAll()
            cameraProvider.bindToLifecycle(
                lifecycleOwner,
                selector,
                preview,
                imageCapture,
                videoCapture
            )

            Log.d(TAG, "Camera bound to lifecycle successfully")

        }, ContextCompat.getMainExecutor(context))
    }

    fun switchCamera(lifecycleOwner: LifecycleOwner) {
        Log.d(TAG, "Switching camera")

        stopRecording()

        lensFacing =
            if (lensFacing == CameraSelector.LENS_FACING_BACK)
                CameraSelector.LENS_FACING_FRONT
            else
                CameraSelector.LENS_FACING_BACK

        Log.d(TAG, "New lens facing: ${if (lensFacing == CameraSelector.LENS_FACING_BACK) "BACK" else "FRONT"}")

        startCamera(lifecycleOwner)
    }

    // ---------------- PHOTO ----------------

    fun takePhoto(
        flashMode: String,
        onResult: (String?) -> Unit
    ) {
        val capture = imageCapture ?: run {
            Log.e(TAG, "ImageCapture is null")
            return
        }

        capture.flashMode =
            if (lensFacing == CameraSelector.LENS_FACING_FRONT) {
                Log.d(TAG, "Front camera detected. Flash OFF")
                ImageCapture.FLASH_MODE_OFF
            } else {
                when (flashMode) {
                    "on" -> {
                        Log.d(TAG, "Flash mode: ON")
                        ImageCapture.FLASH_MODE_ON
                    }
                    "auto" -> {
                        Log.d(TAG, "Flash mode: AUTO")
                        ImageCapture.FLASH_MODE_AUTO
                    }
                    else -> {
                        Log.d(TAG, "Flash mode: OFF")
                        ImageCapture.FLASH_MODE_OFF
                    }
                }
            }

        val fileName = "IMG_${System.currentTimeMillis()}"
        Log.d(TAG, "Capturing photo: $fileName")

        val contentValues = ContentValues().apply {
            put(MediaStore.MediaColumns.DISPLAY_NAME, fileName)
            put(MediaStore.MediaColumns.MIME_TYPE, "image/jpeg")
            put(MediaStore.Images.Media.RELATIVE_PATH, "Pictures/Pixora")
        }

        val outputOptions = ImageCapture.OutputFileOptions
            .Builder(
                context.contentResolver,
                MediaStore.Images.Media.EXTERNAL_CONTENT_URI,
                contentValues
            )
            .build()

        capture.takePicture(
            outputOptions,
            ContextCompat.getMainExecutor(context),
            object : ImageCapture.OnImageSavedCallback {
                override fun onImageSaved(result: ImageCapture.OutputFileResults) {
                    Log.d(TAG, "Photo saved successfully: ${result.savedUri}")
                    onResult(result.savedUri?.toString())
                }

                override fun onError(exception: ImageCaptureException) {
                    Log.e(TAG, "Photo capture failed", exception)
                    onResult(null)
                }
            }
        )
    }

    // ---------------- VIDEO ----------------

    fun startRecording(onResult: (String?) -> Unit) {
        val video = videoCapture ?: run {
            Log.e(TAG, "VideoCapture is null")
            return
        }

        val fileName = "VID_${System.currentTimeMillis()}"
        Log.d(TAG, "Starting video recording: $fileName")

        val contentValues = ContentValues().apply {
            put(MediaStore.MediaColumns.DISPLAY_NAME, fileName)
            put(MediaStore.MediaColumns.MIME_TYPE, "video/mp4")
            put(MediaStore.Video.Media.RELATIVE_PATH, "Movies/Pixora")
        }

        val outputOptions = MediaStoreOutputOptions
            .Builder(
                context.contentResolver,
                MediaStore.Video.Media.EXTERNAL_CONTENT_URI
            )
            .setContentValues(contentValues)
            .build()

        activeRecording = video.output
            .prepareRecording(context, outputOptions)
            .withAudioEnabled()
            .start(ContextCompat.getMainExecutor(context)) { event ->

                when (event) {
                    is VideoRecordEvent.Start -> {
                        Log.d(TAG, "Video recording started")
                    }

                    is VideoRecordEvent.Finalize -> {
                        Log.d(
                            TAG,
                            "Video recording finalized. Saved URI: ${event.outputResults.outputUri}"
                        )
                        onResult(event.outputResults.outputUri?.toString())
                        activeRecording = null
                    }
                }
            }
    }

    fun stopRecording() {
        if (activeRecording != null) {
            Log.d(TAG, "Stopping video recording")
            activeRecording?.stop()
        } else {
            Log.d(TAG, "No active recording to stop")
        }
    }
}
