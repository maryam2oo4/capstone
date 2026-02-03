import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class LetsPlayWebViewPage extends StatefulWidget {
  final String url;
  const LetsPlayWebViewPage({super.key, required this.url});

  @override
  State<LetsPlayWebViewPage> createState() => _LetsPlayWebViewPageState();
}

class _LetsPlayWebViewPageState extends State<LetsPlayWebViewPage> {
  WebViewController? _controller;

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid || Platform.isIOS) {
      _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..loadRequest(Uri.parse(widget.url));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!(Platform.isAndroid || Platform.isIOS)) {
      return Scaffold(
        appBar: AppBar(title: const Text('LifeLink Challenge')),
        body: const Center(
          child: Text(
            'WebView is only supported on Android and iOS.\nPlease open this feature on a mobile device.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18),
          ),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('LifeLink Challenge')),
      body: WebViewWidget(controller: _controller!),
    );
  }
}
