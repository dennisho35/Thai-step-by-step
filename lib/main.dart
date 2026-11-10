import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'services/local_storage_service.dart';
import 'services/thai_tts_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalStorageService.init();
  await ThaiTtsService.init();
  runApp(const ThaiStepByStepApp());
}

class ThaiStepByStepApp extends StatefulWidget {
  const ThaiStepByStepApp({super.key});

  @override
  State<ThaiStepByStepApp> createState() => _ThaiStepByStepAppState();
}

class _ThaiStepByStepAppState extends State<ThaiStepByStepApp> {
  ThemeMode _themeMode = ThemeMode.light;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '泰語 Step by Step｜泰語一步通',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFFAF8F5),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1B365D),
          primary: const Color(0xFF1B365D),
          secondary: const Color(0xFFB91C1C),
          tertiary: const Color(0xFFD97706),
          surface: Colors.white,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        colorScheme: ColorScheme.fromSeed(
          brightness: Brightness.dark,
          seedColor: const Color(0xFF3B82F6),
          primary: const Color(0xFF3B82F6),
          secondary: const Color(0xFFF87171),
          tertiary: const Color(0xFFFBBF24),
        ),
      ),
      home: const ThaiLearningHomeShell(),
    );
  }
}

class ThaiLearningHomeShell extends StatefulWidget {
  const ThaiLearningHomeShell({super.key});

  @override
  State<ThaiLearningHomeShell> createState() => _ThaiLearningHomeShellState();
}

class _ThaiLearningHomeShellState extends State<ThaiLearningHomeShell> {
  late final WebViewController _controller;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        'FlutterTtsBridge',
        onMessageReceived: (JavaScriptMessage message) async {
          try {
            final data = jsonDecode(message.message);
            if (data['action'] == 'speak') {
              final text = (data['text'] ?? '').toString();
              final rate = (data['rate'] as num?)?.toDouble() ?? 0.8;
              final ok = await ThaiTtsService.speak(text, slow: rate < 0.65, baseRate: rate);
              if (!ok && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(ThaiTtsService.statusMessage)),
                );
              }
            }
          } catch (_) {}
        },
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) {
            if (mounted) setState(() => _isLoaded = true);
          },
        ),
      )
      ..loadFlutterAsset('assets/web/thai_step_by_step_app.html');
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (await _controller.canGoBack()) {
          await _controller.goBack();
        } else {
          await _controller.runJavaScript("switchMainView('home');");
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Stack(
            children: [
              WebViewWidget(controller: _controller),
              if (!_isLoaded)
                const Center(
                  child: CircularProgressIndicator(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
