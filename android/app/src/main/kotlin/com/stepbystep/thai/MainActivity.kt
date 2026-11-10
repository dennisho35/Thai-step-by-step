package com.stepbystep.thai

import android.os.Bundle
import android.speech.tts.TextToSpeech
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.Locale

class MainActivity: FlutterActivity(), TextToSpeech.OnInitListener {
    private val CHANNEL = "com.stepbystep.thai/native_tts"
    private var tts: TextToSpeech? = null
    private var isThaiAvailable: Boolean = false

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        tts = TextToSpeech(this, this)
    }

    override fun onInit(status: Int) {
        if (status == TextToSpeech.SUCCESS) {
            val thaiLocale = Locale("th", "TH")
            val res = tts?.isLanguageAvailable(thaiLocale) ?: TextToSpeech.LANG_NOT_SUPPORTED
            if (res >= TextToSpeech.LANG_AVAILABLE) {
                tts?.language = thaiLocale
                isThaiAvailable = true
            } else {
                isThaiAvailable = false
            }
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "isThaiVoiceAvailable" -> result.success(isThaiAvailable)
                "speakThai" -> {
                    val text = call.argument<String>("text") ?: ""
                    val rate = call.argument<Double>("rate")?.toFloat() ?: 0.85f
                    if (!isThaiAvailable) {
                        result.error("NO_THAI_VOICE", "裝置尚未安裝本機泰語 (th-TH) 語音資源", null)
                    } else {
                        tts?.setSpeechRate(rate)
                        tts?.speak(text, TextToSpeech.QUEUE_FLUSH, null, "thai_utt_${System.currentTimeMillis()}")
                        result.success(true)
                    }
                }
                "stop" -> {
                    tts?.stop()
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }
    }

    override fun onDestroy() {
        tts?.stop()
        tts?.shutdown()
        super.onDestroy()
    }
}
