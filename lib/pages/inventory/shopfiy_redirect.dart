import 'dart:io';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class SimpleWebView extends StatefulWidget {
  final String initialUrl;

  const SimpleWebView({required this.initialUrl, super.key});

  @override
  State<SimpleWebView> createState() => _SimpleWebViewState();
}

class _SimpleWebViewState extends State<SimpleWebView> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();

    final creationParams = PlatformWebViewControllerCreationParams();
    _controller = WebViewController.fromPlatformCreationParams(creationParams)
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) => debugPrint('Started: $url'),
          onPageFinished: (url) => debugPrint('Finished: $url'),
          onNavigationRequest: (request) {
            // Optionally detect redirect/callback URLs here
            return NavigationDecision.navigate;
          },
          onWebResourceError: (error) {
            debugPrint('Error loading: ${error.description}');
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.initialUrl));

    if (!Platform.isMacOS) {
      _controller.setBackgroundColor(const Color(0xFFFFFFFF));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('WebView')),
      body: WebViewWidget(controller: _controller),
    );
  }
}
