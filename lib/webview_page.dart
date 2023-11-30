import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';

import 'main.dart';

InAppWebViewController? webViewController;

class WebviewPage extends StatefulWidget {
  const WebviewPage({Key? key}) : super(key: key);

  @override
  State<WebviewPage> createState() => _WebviewState();
}

class _WebviewState extends State<WebviewPage> {
  final GlobalKey webviewKey = GlobalKey();
  String? token = "";
  String fcmToken = "";
  bool shouldShowBottomNav = false;
  bool shouldShowSearchBar = false;
  bool shouldShowFAB = false;

  TextEditingController textFieldController = TextEditingController();

  InAppWebViewGroupOptions options = InAppWebViewGroupOptions(
      crossPlatform: InAppWebViewOptions(
        useShouldOverrideUrlLoading: true,
        mediaPlaybackRequiresUserGesture: false,
      ),
      android: AndroidInAppWebViewOptions(
        useHybridComposition: true,
        mixedContentMode: AndroidMixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
      ),
      ios: IOSInAppWebViewOptions());

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    dynamic obj = ModalRoute.of(context)?.settings.arguments;
    token ??= obj?["token"];
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: WillPopScope(
          onWillPop: () async {
            if ((await webViewController?.canGoBack()) ?? false) {
              webViewController!.goBack();
              return false;
            }
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
              return false;
            }
            return true;
          },
          child: SafeArea(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                Expanded(
                  child: Stack(
                    children: [
                      InAppWebView(
                          key: webviewKey,
                          initialUrlRequest: URLRequest(
                              url: Uri.parse("https://ru.ecoplantagro.com")),
                          initialOptions: options,
                          onWebViewCreated: (controller) async {
                            fcmToken =
                                await FirebaseMessaging.instance.getToken() ??
                                    "";
                            webViewController = controller;
                          },
                          onConsoleMessage: (controller, consoleMessage) async {
                            final response = await http.post(
                              Uri.parse(
                                  "https://ru.ecoplantagro.com/pwa/current.php"),
                              body: {'token': fcmToken},
                            );
                            if (response.statusCode != 200) {
                            } else {
                              print(fcmToken);
                            }
                          },
                          androidOnPermissionRequest:
                              (InAppWebViewController controller, String origin,
                                  List<String> resources) async {
                            return PermissionRequestResponse(
                                resources: resources,
                                action: PermissionRequestResponseAction.GRANT);
                          }),
                    ],
                  ),
                ),
              ]))),
    );
  }

  void _setupJavaScriptBridge() {
    webViewController!.addJavaScriptHandler(
      handlerName: 'sendValueToFlutter',
      callback: (data) {
        // Handle the data received from JavaScript
        String value = data.toString();
        // Do something with the value from the WebView
      },
    );
  }
}
