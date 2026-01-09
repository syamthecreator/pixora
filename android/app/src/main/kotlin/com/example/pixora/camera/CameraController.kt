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

    // 🔑 REQUIRED for torch control
    private var camera: Camera? = null

    // ---------------- CAMERA START ----------------

    fun startCamera(lifecycleOwner: LifecycleOwner) {
        Log.d(TAG, "startCamera() called")
        Log.d(
            TAG,
            "Lens facing: ${if (lensFacing == CameraSelector.LENS_FACING_BACK) "BACK" else "FRONT"}"
        )

        val cameraProviderFuture = ProcessCameraProvider.getInstance(context)

        cameraProviderFuture.addListener({
            val cameraProvider = cameraProviderFuture.get()
            Log.d(TAG, "CameraProvider obtained")

            // -------- Preview --------
            val preview = Preview.Builder().build()
            preview.setSurfaceProvider(previewView.surfaceProvider)
            Log.d(TAG, "Preview use-case created")

            // -------- Photo --------
            imageCapture = ImageCapture.Builder()
                .setCaptureMode(ImageCapture.CAPTURE_MODE_MINIMIZE_LATENCY)
                .setFlashMode(ImageCapture.FLASH_MODE_OFF)
                .build()
            Log.d(TAG, "ImageCapture use-case created")

            // -------- Video --------
            val recorder = Recorder.Builder()
                .setQualitySelector(QualitySelector.from(Quality.HIGHEST))
                .build()

            videoCapture = VideoCapture.withOutput(recorder)
            Log.d(TAG, "VideoCapture use-case created")

            val selector = CameraSelector.Builder()
                .requireLensFacing(lensFacing)
                .build()

            cameraProvider.unbindAll()

            // 🔑 SAVE Camera reference (needed for torch)
            camera = cameraProvider.bindToLifecycle(
                lifecycleOwner,
                selector,
                preview,
                imageCapture,
                videoCapture
            )

            Log.d(TAG, "Camera bound to lifecycle successfully")

        }, ContextCompat.getMainExecutor(context))
    }

    // ---------------- TORCH CONTROL (CameraX ONLY) ----------------

    fun setTorch(enabled: Boolean) {
        if (lensFacing == CameraSelector.LENS_FACING_FRONT) {
            Log.d(TAG, "Torch ignored: front camera")
            return
        }

        camera?.cameraControl?.enableTorch(enabled)
        Log.d(TAG, "CameraX torch set to: $enabled")
    }

    // ---------------- SWITCH CAMERA ----------------

    fun switchCamera(lifecycleOwner: LifecycleOwner) {
        Log.d(TAG, "switchCamera() called")

        stopRecording()

        // Always turn torch OFF when switching camera
        setTorch(false)

        lensFacing =
            if (lensFacing == CameraSelector.LENS_FACING_BACK)
                CameraSelector.LENS_FACING_FRONT
            else
                CameraSelector.LENS_FACING_BACK

        Log.d(
            TAG,
            "Camera switched. New lens: ${if (lensFacing == CameraSelector.LENS_FACING_BACK) "BACK" else "FRONT"}"
        )

        startCamera(lifecycleOwner)
    }

    // ---------------- PHOTO ----------------

    fun takePhoto(
        flashMode: String,
        onResult: (String?) -> Unit
    ) {
        Log.d(TAG, "takePhoto() called with flashMode=$flashMode")

        val capture = imageCapture ?: run {
            Log.e(TAG, "ImageCapture is NULL")
            return
        }

        capture.flashMode =
            if (lensFacing == CameraSelector.LENS_FACING_FRONT) {
                Log.d(TAG, "Front camera → Flash FORCED OFF")
                ImageCapture.FLASH_MODE_OFF
            } else {
                when (flashMode) {

                    // 🔥 FLASH ON → torch already ON
                    "on" -> {
                        Log.d(TAG, "FLASH ON → Torch handles lighting, capture flash OFF")
                        ImageCapture.FLASH_MODE_OFF
                    }

                    // ⚡ AUTO → CameraX decides
                    "auto" -> {
                        Log.d(TAG, "FLASH AUTO → CameraX AUTO flash")
                        ImageCapture.FLASH_MODE_AUTO
                    }

                    // 🌑 OFF
                    else -> {
                        Log.d(TAG, "FLASH OFF")
                        ImageCapture.FLASH_MODE_OFF
                    }
                }
            }

        val fileName = "IMG_${System.currentTimeMillis()}"
        Log.d(TAG, "Preparing capture file: $fileName")

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

        Log.d(TAG, "Calling ImageCapture.takePicture()")

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
        Log.d(TAG, "startRecording() called")

        val video = videoCapture ?: run {
            Log.e(TAG, "VideoCapture is NULL")
            return
        }

        val fileName = "VID_${System.currentTimeMillis()}"
        Log.d(TAG, "Recording file: $fileName")

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
                        Log.d(TAG, "Video recording STARTED")
                    }

                    is VideoRecordEvent.Finalize -> {
                        Log.d(
                            TAG,
                            "Video recording FINALIZED: ${event.outputResults.outputUri}"
                        )
                        onResult(event.outputResults.outputUri?.toString())
                        activeRecording = null
                    }
                }
            }
    }

    fun stopRecording() {
        if (activeRecording != null) {
            Log.d(TAG, "stopRecording() → stopping active recording")
            activeRecording?.stop()
            activeRecording = null
        } else {
            Log.d(TAG, "stopRecording() → no active recording")
        }
    }
}
