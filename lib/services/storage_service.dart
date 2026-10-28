import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/daily_record.dart';

/// 本地存储服务：使用 shared_preferences（web -> localStorage，Android -> SharedPreferences）
class StorageService {
  static const String _kRecords = 'records';
  static const String _kReminderEnabled = 'reminder_enabled';
  static const String _kReminderHour = 'reminder_hour';
  static const String _kReminderMinute = 'reminder_minute';

  StorageService._();

  static Future<SharedPreferences> get _prefs =>
      SharedPreferences.getInstance();

  /// 读取某天的记录，不存在返回 null
  static Future<DailyRecord?> getRecord(String date) async {
    final prefs = await _prefs;
    final map = _readAll(prefs);
    final s = map[date];
    if (s == null) return null;
    try {
      return DailyRecord.fromJsonString(s);
    } catch (_) {
      return null;
    }
  }

  /// 保存记录
  static Future<void> saveRecord(DailyRecord record) async {
    final prefs = await _prefs;
    final map = _readAll(prefs);
    map[record.date] = record.toJsonString();
    await prefs.setString(_kRecords, jsonEncode(map));
  }

  /// 读取全部记录，按日期倒序
  static Future<List<DailyRecord>> getAllRecords() async {
    final prefs = await _prefs;
    final map = _readAll(prefs);
    final list = <DailyRecord>[];
    map.forEach((date, s) {
      try {
        list.add(DailyRecord.fromJsonString(s));
      } catch (_) {
        // 忽略损坏数据
      }
    });
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  /// 删除某天记录（用于测试/误操作）
  static Future<void> deleteRecord(String date) async {
    final prefs = await _prefs;
    final map = _readAll(prefs);
    map.remove(date);
    await prefs.setString(_kRecords, jsonEncode(map));
  }

  static Map<String, String> _readAll(SharedPreferences prefs) {
    final raw = prefs.getString(_kRecords);
    if (raw == null || raw.isEmpty) return {};
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return decoded.map((k, v) => MapEntry(k, v.toString()));
    } catch (_) {
      return {};
    }
  }

  // ---------- 提醒设置 ----------

  static Future<bool> getReminderEnabled() async =>
      (await _prefs).getBool(_kReminderEnabled) ?? false;

  static Future<void> setReminderEnabled(bool v) async =>
      (await _prefs).setBool(_kReminderEnabled, v);

  static Future<int> getReminderHour() async =>
      (await _prefs).getInt(_kReminderHour) ?? 9;

  static Future<int> getReminderMinute() async =>
      (await _prefs).getInt(_kReminderMinute) ?? 0;

  static Future<void> setReminderTime(int hour, int minute) async {
    final prefs = await _prefs;
    await prefs.setInt(_kReminderHour, hour);
    await prefs.setInt(_kReminderMinute, minute);
  }
}
