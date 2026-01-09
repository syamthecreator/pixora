package com.example.pixora.media

import android.app.Activity
import android.content.ContentUris
import android.content.Context
import android.content.IntentSender
import android.provider.MediaStore

class MediaDeleteHandler(
    private val activity: Activity
) {

    companion object {
        const val DELETE_REQUEST_CODE = 1001
    }

    fun requestDeleteImage(path: String) {
        val resolver = activity.contentResolver

        val projection = arrayOf(MediaStore.Images.Media._ID)
        val selection = MediaStore.Images.Media.DATA + "=?"
        val selectionArgs = arrayOf(path)

        val cursor = resolver.query(
            MediaStore.Images.Media.EXTERNAL_CONTENT_URI,
            projection,
            selection,
            selectionArgs,
            null
        ) ?: return

        cursor.use {
            if (it.moveToFirst()) {
                val id =
                    it.getLong(it.getColumnIndexOrThrow(MediaStore.Images.Media._ID))

                val uri = ContentUris.withAppendedId(
                    MediaStore.Images.Media.EXTERNAL_CONTENT_URI,
                    id
                )

                val intentSender: IntentSender =
                    MediaStore.createDeleteRequest(
                        resolver,
                        listOf(uri)
                    ).intentSender

                activity.startIntentSenderForResult(
                    intentSender,
                    DELETE_REQUEST_CODE,
                    null,
                    0,
                    0,
                    0
                )
            }
        }
    }
}
