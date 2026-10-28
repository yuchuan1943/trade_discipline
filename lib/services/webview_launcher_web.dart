import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// 在 Web 端（调试）用新标签页打开交易卡页面
Future<void> openTradeCardPage(BuildContext context, String url) async {
  final uri = Uri.parse(url);
  try {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (_) {
    // 打开失败则静默忽略（Web 调试环境可能被拦截）
  }
}
