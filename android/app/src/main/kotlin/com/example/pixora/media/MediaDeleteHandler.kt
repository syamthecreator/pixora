package com.example.pixora.media

import android.app.Activity
import android.content.ContentUris
import android.content.IntentSender
import android.provider.MediaStore
import android.util.Log

class MediaDeleteHandler(
    private val activity: Activity
) {

    companion object {
        const val DELETE_REQUEST_CODE = 1001
    }

    private val TAG = "PixoraMediaDelete"

    fun requestDeleteImage(path: String) {
        Log.d(TAG, "Request delete image. Path=$path")

        val resolver = activity.contentResolver

        val projection = arrayOf(MediaStore.Images.Media._ID)
        val selection = MediaStore.Images.Media.DATA + "=?"
        val selectionArgs = arrayOf(path)

        Log.d(TAG, "Querying MediaStore for image ID")

        val cursor = resolver.query(
            MediaStore.Images.Media.EXTERNAL_CONTENT_URI,
            projection,
            selection,
            selectionArgs,
            null
        ) ?: run {
            Log.e(TAG, "MediaStore query returned null cursor")
            return
        }

        cursor.use {
            if (it.moveToFirst()) {
                val id =
                    it.getLong(it.getColumnIndexOrThrow(MediaStore.Images.Media._ID))

                Log.d(TAG, "Image found. MediaStore ID=$id")

                val uri = ContentUris.withAppendedId(
                    MediaStore.Images.Media.EXTERNAL_CONTENT_URI,
                    id
                )

                Log.d(TAG, "Delete URI resolved: $uri")

                val intentSender: IntentSender =
                    MediaStore.createDeleteRequest(
                        resolver,
                        listOf(uri)
                    ).intentSender

                Log.d(TAG, "Launching delete confirmation dialog")

                activity.startIntentSenderForResult(
                    intentSender,
                    DELETE_REQUEST_CODE,
                    null,
                    0,
                    0,
                    0
                )
            } else {
                Log.e(TAG, "No image found for given path")
            }
        }
    }
}
