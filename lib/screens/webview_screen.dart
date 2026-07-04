import 'dart:async';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

const String SITE_URL = 'https://excellencedigital.alwaysdata.net';

class WebViewScreen extends StatefulWidget {
  const WebViewScreen({super.key});

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late final WebViewController controller;
  bool isLoading = true;
  bool isOffline = false;
  String errorMessage = '';
  double progress = 0;
  StreamSubscription? connectivitySubscription;

  @override
  void initState() {
    super.initState();
    _initWebView();
    _checkConnectivity();
  }

  void _initWebView() {
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFF0B0F1A))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            setState(() {
              isLoading = true;
              errorMessage = '';
            });
          },
          onPageFinished: (url) {
            setState(() => isLoading = false);
          },
          onProgress: (int progress) {
            setState(() => this.progress = progress / 100);
          },
          onWebResourceError: (WebResourceError error) {
            print('❌ Erreur WebView: ${error.description}');
            print('   Code: ${error.errorCode}');
            print('   URL: ${error.failingUrl}');
            setState(() {
              isOffline = true;
              errorMessage = '${error.description} (Code: ${error.errorCode})';
            });
          },
        ),
      )
      ..loadRequest(Uri.parse(SITE_URL));
  }

  void _checkConnectivity() {
    connectivitySubscription = Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> results) {
      if (results.contains(ConnectivityResult.none)) {
        setState(() => isOffline = true);
      } else {
        setState(() {
          isOffline = false;
          errorMessage = '';
        });
        controller.reload();
      }
    });
  }

  Future<bool> _onWillPop() async {
    if (await controller.canGoBack()) {
      controller.goBack();
      return false;
    }
    return true;
  }

  @override
  void dispose() {
    connectivitySubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: const Color(0xFF0B0F1A),
        body: SafeArea(
          child: Stack(
            children: [
              // WebView
              if (!isOffline) WebViewWidget(controller: controller),

              // Barre de progression
              if (isLoading && !isOffline)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.transparent,
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Color(0xFF3B82F6)),
                    minHeight: 3,
                  ),
                ),

              // Écran hors-ligne ou erreur
              if (isOffline)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.white.withOpacity(0.05),
                          ),
                          child: const Icon(Icons.wifi_off_rounded,
                              color: Color(0xFF64748B), size: 40),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Connexion impossible',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          errorMessage.isNotEmpty
                              ? errorMessage
                              : 'Vérifiez votre connexion Internet',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 13),
                        ),
                        const SizedBox(height: 32),
                        ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              isOffline = false;
                              errorMessage = '';
                            });
                            controller.reload();
                          },
                          icon: const Icon(Icons.refresh, size: 20),
                          label: const Text('Réessayer'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3B82F6),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
