# 泰語 Step by Step｜泰語一步通 (Thai Step by Step)
**專為繁體中文（香港／台灣）使用者設計的完整離線泰語學習系統（Flutter Material 3 + Web/Hybrid 雙軌架構）**

## 1. 專案架構與交付內容
- `assets/web/thai_step_by_step_app.html`：可直接在任何手機／電腦瀏覽器或 WebView 離線執行的完整互動式學習系統。
- `assets/curriculum/thai_curriculum.json`：完整驗證的泰語教學資料庫：
  - **44 個泰語輔音**（含中/高/低三類輔音、IPA、RTGS、香港粵語與國語近似音、發音方法、代表詞、筆順與記憶口訣）
  - **28 個常見母音組合**（含開音節／閉音節變形規則與互動拼讀組合器）
  - **特殊拼讀規則**（8 大尾音收音系統、活音節 vs 死音節、真假複輔音、前引字 ห นำ 與 อ นำ ย）
  - **泰語五聲調**（五度音高曲線圖、五聲調同音節比較專區、完整聲調推算矩陣、9 大發音與麥克風跟讀訓練）
  - **1,601 個分類實用詞彙**（涵蓋 20 大主題，支援泰文、羅馬拼音與中文即時搜尋）
  - **520 句日常實用句子**（含逐詞拆解、關鍵詞解釋與語法說明）
  - **15 課循序漸進泰語文法課程**（含句型公式、常見錯誤與隨堂練習）
  - **20 個真實生活情境對話**（共 120 輪雙角色對話，支援全段連播、單字點擊、角色切換、跟讀與隱藏中文測試）
  - **數字與時間學習中心**（0–100、百千萬億、泰式六段時間制、星期幸運色、12 大量詞與真實演算法泰語數字轉換器）
  - **10 大題型測驗與 SRS 間隔重複錯題本**（共 60 道精選測驗題）
- `lib/main.dart`、`lib/services/thai_tts_service.dart`、`lib/services/local_storage_service.dart`：Flutter Material 3 原生框架、Android `TextToSpeech (th-TH)` 橋接與本機 SQLite / SharedPreferences 儲存層。
- `android/app/build.gradle`：Android Native 設定（`minSdk 26` / `targetSdk 35`）。

## 2. 如何編譯安裝 Android APK
### 方法 A：本機一鍵編譯
```bash
chmod +x build_apk.sh
./build_apk.sh
```
編譯完成後，APK 位於 `build/app/outputs/flutter-apk/app-release.apk`。

### 方法 B：GitHub Actions 雲端免費自動編譯 APK
將本專案上傳至 GitHub 儲存庫，GitHub Actions (`.github/workflows/build_apk.yml`) 會自動在雲端編譯並產出 `Thai-Step-by-Step-v1.0-release-apk` 供下載安裝。
