package com.example.pixora.camera

import android.content.Context
import android.util.AttributeSet
import jp.co.cyberagent.android.gpuimage.GPUImageView

class CameraPreviewView @JvmOverloads constructor(
    context: Context,
    attrs: AttributeSet? = null
) : GPUImageView(context, attrs) {

    init {
        setRenderMode(RENDERMODE_CONTINUOUSLY)
    }
}
