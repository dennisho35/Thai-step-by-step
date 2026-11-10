import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class LocalStorageService {
  static Database? _db;
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'thai_step_by_step.db');
    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE learning_status (
            item_id TEXT PRIMARY KEY,
            module TEXT,
            status TEXT,
            practice_count INTEGER DEFAULT 0,
            updated_at TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE srs_mistakes (
            question_id TEXT PRIMARY KEY,
            wrong_count INTEGER DEFAULT 1,
            consecutive_correct INTEGER DEFAULT 0,
            interval_days INTEGER DEFAULT 1,
            next_review_iso TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE personal_glossary (
            id TEXT PRIMARY KEY,
            thai TEXT,
            rtgs TEXT,
            zh TEXT,
            category TEXT,
            created_at TEXT
          )
        ''');
      },
    );
  }

  static String getUiLocale() => _prefs?.getString('ui_locale') ?? 'zh-HK';
  static Future<void> setUiLocale(String locale) async => await _prefs?.setString('ui_locale', locale);

  static double getSpeechRate() => _prefs?.getDouble('speech_rate') ?? 0.8;
  static Future<void> setSpeechRate(double rate) async => await _prefs?.setDouble('speech_rate', rate);

  static Future<void> markItemStatus(String itemId, String module, String status) async {
    await _db?.insert(
      'learning_status',
      {
        'item_id': itemId,
        'module': module,
        'status': status,
        'updated_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<void> recordSrsMistake(String questionId, bool isCorrect) async {
    final rows = await _db?.query('srs_mistakes', where: 'question_id = ?', whereArgs: [questionId]) ?? [];
    if (isCorrect) {
      if (rows.isNotEmpty) {
        final cur = rows.first;
        final consec = ((cur['consecutive_correct'] as int?) ?? 0) + 1;
        final nextInterval = consec == 1 ? 1 : consec == 2 ? 3 : consec == 3 ? 7 : 14;
        final nextDate = DateTime.now().add(Duration(days: nextInterval)).toIso8601String().substring(0, 10);
        await _db?.update(
          'srs_mistakes',
          {'consecutive_correct': consec, 'interval_days': nextInterval, 'next_review_iso': nextDate},
          where: 'question_id = ?',
          whereArgs: [questionId],
        );
      }
    } else {
      final wrongCnt = rows.isEmpty ? 1 : (((rows.first['wrong_count'] as int?) ?? 0) + 1);
      final today = DateTime.now().toIso8601String().substring(0, 10);
      await _db?.insert(
        'srs_mistakes',
        {
          'question_id': questionId,
          'wrong_count': wrongCnt,
          'consecutive_correct': 0,
          'interval_days': 1,
          'next_review_iso': today,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }
}
