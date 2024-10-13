package com.audiorecordingapp

import android.media.MediaRecorder
import android.os.Handler
import android.os.Looper
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactContextBaseJavaModule
import com.facebook.react.bridge.ReactMethod
import com.facebook.react.modules.core.DeviceEventManagerModule
import java.io.IOException

class AudioChunkModule(reactContext: ReactApplicationContext) : ReactContextBaseJavaModule(reactContext) {

    private var mediaRecorder: MediaRecorder? = null
    private var filePath: String? = null
    private val chunkInterval: Long = 30000 // 30 seconds
    private val handler = Handler(Looper.getMainLooper())

    override fun getName(): String {
        return "AudioChunkModule"
    }

    @ReactMethod
    fun startRecording(fileName: String) {
        filePath = fileName
        mediaRecorder = MediaRecorder().apply {
            setAudioSource(MediaRecorder.AudioSource.MIC)
            setOutputFormat(MediaRecorder.OutputFormat.THREE_GPP)
            setAudioEncoder(MediaRecorder.AudioEncoder.AMR_NB)
            setOutputFile(filePath)

            try {
                prepare()
                start()
            } catch (e: IOException) {
                e.printStackTrace()
            }
        }

        handler.postDelayed(captureChunkRunnable, chunkInterval)
    }

    private val captureChunkRunnable = Runnable {
        sendAudioChunkToJS()
        handler.postDelayed(captureChunkRunnable, chunkInterval)
    }

    private fun sendAudioChunkToJS() {
        mediaRecorder?.stop()
        mediaRecorder?.release()
        mediaRecorder = null

        // Notify JS side about the audio chunk
        reactApplicationContext.getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter::class.java)
                .emit("AudioChunkCaptured", filePath)

        // Start recording for the next chunk
        startRecording(filePath + System.currentTimeMillis() + ".3gp")
    }

    @ReactMethod
    fun stopRecording() {
        mediaRecorder?.stop()
        mediaRecorder?.release()
        mediaRecorder = null

        handler.removeCallbacks(captureChunkRunnable)
    }
}
