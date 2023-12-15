import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:http/http.dart' as http;

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
  bool isLogin = false;

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
                            dynamic docu = await webViewController!
                                .evaluateJavascript(
                                    source:
                                        'javascript:window.localStorage.getItem("id")');
                            if (docu != null && isLogin == false) {
                              final response = await http.post(
                                Uri.parse(
                                    "https://ru.ecoplantagro.com/pwa/current.php"),
                                body: {
                                  'token': fcmToken,
                                  "id": docu,
                                },
                              );
                              if (response.statusCode != 200) {
                                // var snackBar = SnackBar(
                                //   content: Text(
                                //       'You Error token ${json.encode(response.body)}'),
                                // );
                                // ScaffoldMessenger.of(context)
                                //     .showSnackBar(snackBar);
                              } else {
                                isLogin = true;
                                print(fcmToken);
                                // var snackBar = SnackBar(
                                //   content: Text('You ID $docu You token $fcmToken'),
                                // );
                                // ScaffoldMessenger.of(context)
                                //     .showSnackBar(snackBar);
                              }
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
}
