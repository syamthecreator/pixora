package com.example.pixora.camera

import androidx.camera.core.Camera
import android.content.ContentValues
import android.content.Context
import android.graphics.*
import android.provider.MediaStore
import android.util.Log
import androidx.camera.core.*
import androidx.camera.lifecycle.ProcessCameraProvider
import androidx.camera.video.*
import androidx.core.content.ContextCompat
import androidx.lifecycle.LifecycleOwner
import jp.co.cyberagent.android.gpuimage.GPUImage
import jp.co.cyberagent.android.gpuimage.GPUImageView
import java.io.ByteArrayOutputStream
import android.view.Surface


class CameraController(
    private val context: Context,
    private val gpuImageView: GPUImageView
) {

    companion object {
        private const val TAG = "PixoraCamera"
    }

    private var lensFacing = CameraSelector.LENS_FACING_BACK

    private var imageCapture: ImageCapture? = null
    private var videoCapture: VideoCapture<Recorder>? = null
    private var activeRecording: Recording? = null

    // 🔥 FILTER
    private lateinit var gpuImage: GPUImage
    private var currentFilter = FilterType.NONE

    // 🔑 REQUIRED for torch control
    private var camera: Camera? = null

    // 🔥 CRITICAL: store provider & analysis
    private var cameraProvider: ProcessCameraProvider? = null
    private var imageAnalysis: ImageAnalysis? = null

    // ---------------- CAMERA START ----------------

    fun startCamera(lifecycleOwner: LifecycleOwner) {
        Log.d(TAG, "startCamera() called")

        gpuImage = GPUImage(context)
        gpuImage.setFilter(FilterFactory.create(currentFilter))
        gpuImageView.setFilter(FilterFactory.create(currentFilter))

        val cameraProviderFuture = ProcessCameraProvider.getInstance(context)

        cameraProviderFuture.addListener({
            cameraProvider = cameraProviderFuture.get()

            Log.d(TAG, "CameraProvider obtained")

            // 🔥 CLEAR OLD ANALYZER (FIX)
            imageAnalysis?.clearAnalyzer()

            // -------- LIVE FILTER PREVIEW --------
            imageAnalysis = ImageAnalysis.Builder()
                .setBackpressureStrategy(ImageAnalysis.STRATEGY_KEEP_ONLY_LATEST)
                .build()

            imageAnalysis!!.setAnalyzer(
                ContextCompat.getMainExecutor(context)
            ) { imageProxy ->
                try {
                    val bitmap = imageProxy.toBitmap()

                    val finalBitmap = bitmap.rotateAndMirror(
                        rotationDegrees = imageProxy.imageInfo.rotationDegrees,
                        isFrontCamera = lensFacing == CameraSelector.LENS_FACING_FRONT
                    )

                    gpuImageView.setImage(finalBitmap)

                } catch (e: Exception) {
                    Log.e(TAG, "Live filter error", e)
                } finally {
                    imageProxy.close()
                }
            }

            // -------- PHOTO --------
            val rotation = gpuImageView.display?.rotation
                ?: context.display?.rotation
                ?: Surface.ROTATION_0

            imageCapture = ImageCapture.Builder()
                .setCaptureMode(ImageCapture.CAPTURE_MODE_MINIMIZE_LATENCY)
                .setFlashMode(ImageCapture.FLASH_MODE_OFF)
                .setTargetRotation(rotation)
                .build()


            // -------- VIDEO --------
            val recorder = Recorder.Builder()
                .setQualitySelector(QualitySelector.from(Quality.HIGHEST))
                .build()

            videoCapture = VideoCapture.withOutput(recorder)

            val selector = CameraSelector.Builder()
                .requireLensFacing(lensFacing)
                .build()

            // 🔥 CRITICAL FIX
            cameraProvider?.unbindAll()

            camera = cameraProvider?.bindToLifecycle(
                lifecycleOwner,
                selector,
                imageAnalysis,
                imageCapture,
                videoCapture
            )

            Log.d(TAG, "Camera bound with LIVE GPUImage filter preview")

        }, ContextCompat.getMainExecutor(context))
    }

    // ---------------- FILTER CONTROL ----------------

    fun setFilter(filterName: String) {
        val normalized = filterName
            .trim()
            .uppercase()
            .replace(" ", "_")

        currentFilter = try {
            FilterType.valueOf(normalized)
        } catch (e: Exception) {
            Log.e(TAG, "Invalid filter name: $filterName", e)
            FilterType.NONE
        }

        val filter = FilterFactory.create(currentFilter)
        gpuImage.setFilter(filter)
        gpuImageView.setFilter(filter)

        Log.d(TAG, "LIVE Filter changed to: $currentFilter")
    }

    // ---------------- TORCH CONTROL ----------------

    fun setTorch(enabled: Boolean) {
        if (lensFacing == CameraSelector.LENS_FACING_FRONT) {
            Log.d(TAG, "Torch ignored: front camera")
            return
        }

        camera?.cameraControl?.enableTorch(enabled)
        Log.d(TAG, "CameraX torch set to: $enabled")
    }

    fun setFlashMode(mode: String) {
        imageCapture?.flashMode = when (mode) {
            "on" -> ImageCapture.FLASH_MODE_OFF
            "auto" -> ImageCapture.FLASH_MODE_AUTO
            else -> ImageCapture.FLASH_MODE_OFF
        }

        Log.d(TAG, "ImageCapture flashMode set to $mode")
    }

    // ---------------- SWITCH CAMERA ----------------

    fun switchCamera(lifecycleOwner: LifecycleOwner) {
        Log.d(TAG, "switchCamera() called")

        stopRecording()
        setTorch(false)

        lensFacing =
            if (lensFacing == CameraSelector.LENS_FACING_BACK)
                CameraSelector.LENS_FACING_FRONT
            else
                CameraSelector.LENS_FACING_BACK

        Log.d(TAG, "Camera switched")

        startCamera(lifecycleOwner)
    }

    // ---------------- PHOTO ----------------

    fun takePhoto(
    flashMode: String,
    onResult: (String?) -> Unit
) {
    Log.d(TAG, "takePhoto() using GPUImage filtered frame")

    // 🔥 CAPTURE FILTERED FRAME FROM PREVIEW
    val filteredBitmap = gpuImageView.capture()

    if (filteredBitmap == null) {
        Log.e(TAG, "Failed to capture filtered bitmap")
        onResult(null)
        return
    }

    saveFilteredBitmap(filteredBitmap, onResult)
}


    // ---------------- VIDEO ----------------

    fun startRecording(onResult: (String?) -> Unit) {
        Log.d(TAG, "startRecording() called")

        val video = videoCapture ?: return

        val fileName = "VID_${System.currentTimeMillis()}"

        val contentValues = ContentValues().apply {
            put(MediaStore.MediaColumns.DISPLAY_NAME, fileName)
            put(MediaStore.MediaColumns.MIME_TYPE, "video/mp4")
            put(MediaStore.Video.Media.RELATIVE_PATH, "Movies/Pixora")
        }

        val outputOptions = MediaStoreOutputOptions.Builder(
            context.contentResolver,
            MediaStore.Video.Media.EXTERNAL_CONTENT_URI
        ).setContentValues(contentValues).build()

        activeRecording = video.output
            .prepareRecording(context, outputOptions)
            .withAudioEnabled()
            .start(ContextCompat.getMainExecutor(context)) { event ->
                when (event) {
                    is VideoRecordEvent.Start ->
                        Log.d(TAG, "Video recording STARTED")
                    is VideoRecordEvent.Finalize -> {
                        Log.d(TAG, "Video recording FINALIZED")
                        onResult(event.outputResults.outputUri?.toString())
                        activeRecording = null
                    }
                }
            }
    }

    private fun saveFilteredBitmap(
    bitmap: Bitmap,
    onResult: (String?) -> Unit
) {
    val fileName = "IMG_${System.currentTimeMillis()}"

    val contentValues = ContentValues().apply {
        put(MediaStore.MediaColumns.DISPLAY_NAME, fileName)
        put(MediaStore.MediaColumns.MIME_TYPE, "image/jpeg")
        put(MediaStore.Images.Media.RELATIVE_PATH, "Pictures/Pixora")
    }

    val uri = context.contentResolver.insert(
        MediaStore.Images.Media.EXTERNAL_CONTENT_URI,
        contentValues
    )

    if (uri == null) {
        onResult(null)
        return
    }

    context.contentResolver.openOutputStream(uri)?.use {
        bitmap.compress(Bitmap.CompressFormat.JPEG, 95, it)
    }

    onResult(uri.toString())
}


    fun stopRecording() {
        activeRecording?.stop()
        activeRecording = null
    }

    // ---------------- CLEANUP (🔥 FIXED) ----------------

    fun cleanup() {
        try {
            Log.d(TAG, "CameraController cleanup started")

            stopRecording()
            setTorch(false)

            // 🔥 MOST IMPORTANT LINE
            cameraProvider?.unbindAll()

            imageAnalysis?.clearAnalyzer()
            imageAnalysis = null

            camera = null
            imageCapture = null
            videoCapture = null
            activeRecording = null

            Log.d(TAG, "CameraController cleanup completed")
        } catch (e: Exception) {
            Log.e(TAG, "Error during CameraController cleanup", e)
        }
    }

    // ---------------- FRONT MIRROR ----------------

    private fun mirrorSavedImage(uri: android.net.Uri) {
        try {
            val inputStream = context.contentResolver.openInputStream(uri)
            val bitmap = BitmapFactory.decodeStream(inputStream)
            inputStream?.close()

            if (bitmap == null) {
                Log.e(TAG, "Bitmap decode failed")
                return
            }

            val matrix = Matrix().apply {
                postScale(-1f, 1f, bitmap.width / 2f, bitmap.height / 2f)
            }

            val mirroredBitmap = Bitmap.createBitmap(
                bitmap, 0, 0, bitmap.width, bitmap.height, matrix, true
            )

            context.contentResolver.openOutputStream(uri)?.use {
                mirroredBitmap.compress(Bitmap.CompressFormat.JPEG, 95, it)
            }

            Log.d(TAG, "Front camera image mirrored successfully")

        } catch (e: Exception) {
            Log.e(TAG, "Failed to mirror saved image", e)
        }
    }
}

// ---------------- IMAGE EXTENSION ----------------

private fun ImageProxy.toBitmap(): Bitmap {
    val yBuffer = planes[0].buffer
    val uBuffer = planes[1].buffer
    val vBuffer = planes[2].buffer

    val ySize = yBuffer.remaining()
    val uSize = uBuffer.remaining()
    val vSize = vBuffer.remaining()

    val nv21 = ByteArray(ySize + uSize + vSize)

    yBuffer.get(nv21, 0, ySize)
    vBuffer.get(nv21, ySize, vSize)
    uBuffer.get(nv21, ySize + vSize, uSize)

    val yuvImage = YuvImage(
        nv21, ImageFormat.NV21, width, height, null
    )

    val out = ByteArrayOutputStream()
    yuvImage.compressToJpeg(Rect(0, 0, width, height), 90, out)

    return BitmapFactory.decodeByteArray(out.toByteArray(), 0, out.size())
}

private fun Bitmap.rotateAndMirror(
    rotationDegrees: Int,
    isFrontCamera: Boolean
): Bitmap {
    val matrix = Matrix()
    matrix.postRotate(rotationDegrees.toFloat())

    if (isFrontCamera) {
        matrix.postScale(-1f, 1f, width / 2f, height / 2f)
    }

    return Bitmap.createBitmap(this, 0, 0, width, height, matrix, true)
}
