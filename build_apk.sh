#!/usr/bin/env bash
set -e
echo "===================================================="
echo " 泰語 Step by Step｜泰語一步通 (Thai Step by Step)"
echo " Android APK 自動化編譯腳本 (MinSDK 26 / TargetSDK 35)"
echo "===================================================="

if ! command -v flutter &> /dev/null; then
  echo "❌ 尚未偵測到 Flutter SDK，請先安裝 Flutter 3.19+ 並設定 PATH。"
  exit 1
fi

flutter pub get
flutter build apk --release

echo "✅ APK 編譯成功！"
echo "📦 可安裝 APK 路徑：build/app/outputs/flutter-apk/app-release.apk"
