import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// 在 Android 端用内嵌 WebView 打开交易卡页面
Future<void> openTradeCardPage(BuildContext context, String url) {
  return Navigator.of(context).push(
    MaterialPageRoute(builder: (_) => _TradeCardWebView(url: url)),
  );
}

class _TradeCardWebView extends StatefulWidget {
  final String url;
  const _TradeCardWebView({required this.url});

  @override
  State<_TradeCardWebView> createState() => _TradeCardWebViewState();
}

class _TradeCardWebViewState extends State<_TradeCardWebView> {
  late final WebViewController _controller;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) {
            if (mounted) setState(() => _loading = false);
          },
          onWebResourceError: (_) {
            if (mounted) setState(() => _loading = false);
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('交易守则原文')),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_loading) const LinearProgressIndicator(minHeight: 2),
        ],
      ),
    );
  }
}
