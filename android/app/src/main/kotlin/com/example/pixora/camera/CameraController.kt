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
import androidx.camera.view.PreviewView
import androidx.core.content.ContextCompat
import androidx.lifecycle.LifecycleOwner
import jp.co.cyberagent.android.gpuimage.GPUImage
import jp.co.cyberagent.android.gpuimage.GPUImageView
import java.io.ByteArrayOutputStream
import java.io.InputStream

class CameraController(
    private val context: Context,
    private val gpuImageView: GPUImageView
)

 {

    private val TAG = "PixoraCamera"

    private var lensFacing = CameraSelector.LENS_FACING_BACK

    private var imageCapture: ImageCapture? = null
    private var videoCapture: VideoCapture<Recorder>? = null
    private var activeRecording: Recording? = null

    // 🔥 FILTER
    private lateinit var gpuImage: GPUImage
    private var currentFilter = FilterType.NONE

    // 🔑 REQUIRED for torch control
    private var camera: Camera? = null

    // ---------------- CAMERA START ----------------

   fun startCamera(lifecycleOwner: LifecycleOwner) {
    Log.d(TAG, "startCamera() called")

    gpuImage = GPUImage(context)
    gpuImage.setFilter(FilterFactory.create(currentFilter))
    gpuImageView.setFilter(FilterFactory.create(currentFilter))

    val cameraProviderFuture = ProcessCameraProvider.getInstance(context)

    cameraProviderFuture.addListener({
        val cameraProvider = cameraProviderFuture.get()

        // -------- LIVE FILTER PREVIEW --------
        val imageAnalysis = ImageAnalysis.Builder()
            .setBackpressureStrategy(ImageAnalysis.STRATEGY_KEEP_ONLY_LATEST)
            .build()

        imageAnalysis.setAnalyzer(
            ContextCompat.getMainExecutor(context)
        ) { imageProxy ->
            try {
               val bitmap = imageProxy.toBitmap()
                val rotatedBitmap = bitmap.rotate(imageProxy.imageInfo.rotationDegrees)
                gpuImageView.setImage(rotatedBitmap)

            } catch (e: Exception) {
                Log.e(TAG, "Live filter error", e)
            } finally {
                imageProxy.close()
            }
        }

        // -------- PHOTO --------
        imageCapture = ImageCapture.Builder()
            .setCaptureMode(ImageCapture.CAPTURE_MODE_MINIMIZE_LATENCY)
            .setFlashMode(ImageCapture.FLASH_MODE_OFF)
            .build()

        // -------- VIDEO --------
        val recorder = Recorder.Builder()
            .setQualitySelector(QualitySelector.from(Quality.HIGHEST))
            .build()

        videoCapture = VideoCapture.withOutput(recorder)

        val selector = CameraSelector.Builder()
            .requireLensFacing(lensFacing)
            .build()

        cameraProvider.unbindAll()

        camera = cameraProvider.bindToLifecycle(
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
        "on" -> ImageCapture.FLASH_MODE_OFF   // torch handles light
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

    // ---------------- PHOTO (UNCHANGED) ----------------

    fun takePhoto(
        flashMode: String,
        onResult: (String?) -> Unit
    ) {
        Log.d(TAG, "takePhoto() called with flashMode=$flashMode")

        val capture = imageCapture ?: return

        val fileName = "IMG_${System.currentTimeMillis()}"

        val contentValues = ContentValues().apply {
            put(MediaStore.MediaColumns.DISPLAY_NAME, fileName)
            put(MediaStore.MediaColumns.MIME_TYPE, "image/jpeg")
            put(MediaStore.Images.Media.RELATIVE_PATH, "Pictures/Pixora")
        }

        val outputOptions = ImageCapture.OutputFileOptions.Builder(
            context.contentResolver,
            MediaStore.Images.Media.EXTERNAL_CONTENT_URI,
            contentValues
        ).build()

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

    // ---------------- VIDEO (UNCHANGED) ----------------

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

    fun stopRecording() {
        activeRecording?.stop()
        activeRecording = null
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
        nv21,
        ImageFormat.NV21,
        width,
        height,
        null
    )

    val out = ByteArrayOutputStream()
    yuvImage.compressToJpeg(Rect(0, 0, width, height), 90, out)

    val bitmap = BitmapFactory.decodeByteArray(
        out.toByteArray(),
        0,
        out.size()
    )

    return bitmap.rotate(imageInfo.rotationDegrees)
}

private fun Bitmap.rotate(degrees: Int): Bitmap {
    if (degrees == 0) return this

    val matrix = Matrix().apply {
        postRotate(degrees.toFloat())
    }

    return Bitmap.createBitmap(
        this,
        0,
        0,
        width,
        height,
        matrix,
        true
    )
}
