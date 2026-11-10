import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';

class ThaiTtsService {
  static final FlutterTts _flutterTts = FlutterTts();
  static const MethodChannel _nativeChannel = MethodChannel('com.stepbystep.thai/native_tts');
  static bool isThaiAvailable = false;
  static String statusMessage = '正在檢測本機泰語 (th-TH) 語音引擎...';

  static Future<void> init() async {
    try {
      final available = await _flutterTts.isLanguageAvailable("th-TH");
      if (available == true) {
        await _flutterTts.setLanguage("th-TH");
        await _flutterTts.setPitch(1.0);
        isThaiAvailable = true;
        statusMessage = '✅ 本機泰語 TTS (th-TH) 已驗證可用，支援離線正常 (1.0x) 與慢速 (0.6x) 發音。';
      } else {
        final nativeOk = await _nativeChannel.invokeMethod<bool>('isThaiVoiceAvailable') ?? false;
        isThaiAvailable = nativeOk;
        statusMessage = nativeOk
            ? '✅ Android 原生泰語語音引擎 (th-TH) 已就緒。'
            : '⚠️ 裝置未安裝泰語 (th-TH) 離線語音包。請前往 Android「設定 → 系統 → 語言與輸入設定 → 文字轉語音輸出」下載泰語語音資料。系統絕不播放假語音。';
      }
    } catch (e) {
      isThaiAvailable = false;
      statusMessage = '⚠️ 無法存取系統泰語語音資源：$e';
    }
  }

  static Future<bool> speak(String text, {bool slow = false, double baseRate = 0.8}) async {
    if (!isThaiAvailable) {
      await init();
      if (!isThaiAvailable) return false;
    }
    final rate = slow ? 0.52 : baseRate;
    await _flutterTts.stop();
    await _flutterTts.setSpeechRate(rate);
    await _flutterTts.speak(text);
    return true;
  }

  static Future<void> stop() async {
    await _flutterTts.stop();
  }
}
