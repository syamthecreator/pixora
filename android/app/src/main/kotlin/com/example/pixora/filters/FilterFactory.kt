package com.example.pixora.camera

import jp.co.cyberagent.android.gpuimage.filter.*

object FilterFactory {

    fun create(type: FilterType): GPUImageFilter {
        return when (type) {

            FilterType.CINEMATIC -> GPUImageFilterGroup().apply {
                addFilter(GPUImageContrastFilter(1.25f))
                addFilter(GPUImageSaturationFilter(1.2f))
                addFilter(GPUImageGammaFilter(0.9f))
            }

            FilterType.WARM_GLOW -> GPUImageFilterGroup().apply {
                addFilter(GPUImageBrightnessFilter(0.06f))
                addFilter(GPUImageSaturationFilter(1.15f))
                addFilter(GPUImageWhiteBalanceFilter(5000f, 0f))
            }

            FilterType.URBAN_POP -> GPUImageFilterGroup().apply {
                addFilter(GPUImageContrastFilter(1.4f))
                addFilter(GPUImageSharpenFilter(0.6f))
                addFilter(GPUImageSaturationFilter(1.1f))
            }

            FilterType.SOFT_FILM -> GPUImageFilterGroup().apply {
                addFilter(GPUImageGammaFilter(1.1f))
                addFilter(GPUImageContrastFilter(0.95f))
                addFilter(GPUImageBrightnessFilter(0.03f))
            }

            FilterType.VIVID_POP -> GPUImageFilterGroup().apply {
                addFilter(GPUImageSaturationFilter(1.6f))
                addFilter(GPUImageContrastFilter(1.2f))
            }

            else -> GPUImageFilter()
        }
    }
}
