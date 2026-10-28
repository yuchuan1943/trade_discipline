// 跨平台打开交易卡页面：
// - Android 用内嵌 WebView（webview_launcher_io.dart）
// - Web 调试用新标签页（webview_launcher_web.dart）
export 'webview_launcher_io.dart'
    if (dart.library.html) 'webview_launcher_web.dart';
