import 'package:flutter/material.dart';

/// 今天日期字符串 yyyy-MM-dd
String todayString() => dateString(DateTime.now());

String dateString(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

/// 解析 yyyy-MM-dd 为 DateTime
DateTime parseDate(String s) {
  final parts = s.split('-');
  return DateTime(
      int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
}

/// 用于展示的中文日期，如 2026年10月27日 周二
String prettyDate(String s) {
  final d = parseDate(s);
  const weeks = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
  return '${d.year}年${d.month}月${d.day}日 ${weeks[d.weekday - 1]}';
}

/// 盈亏金额格式化
String pnlText(double pnl) {
  final abs = pnl.abs();
  final sign = pnl > 0 ? '+' : (pnl < 0 ? '-' : '');
  return '$sign¥${abs.toStringAsFixed(2)}';
}

/// 盈亏显示颜色：盈利=红，亏损=绿（中国市场惯例）
Color pnlColor(double pnl) {
  if (pnl > 0) return const Color(0xFFD9404A);
  if (pnl < 0) return const Color(0xFF238A5C);
  return const Color(0xFF6B7280);
}
