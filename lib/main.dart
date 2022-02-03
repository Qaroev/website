import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final Completer<WebViewController> _controller =
      Completer<WebViewController>();
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  int number = 1;

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) WebView.platform = AndroidWebView();
    _prefs.then((SharedPreferences prefs) {
      if (prefs.getString('counter')! != null) {
        number = int.parse(prefs.getString('counter')!);
        setState(() {});
      }
    });
  }

  initPref() async {}

  JavascriptChannel _toasterJavascriptChannel(BuildContext context) {
    return JavascriptChannel(
        name: 'Toaster',
        onMessageReceived: (JavascriptMessage message) {
          Scaffold.of(context).showSnackBar(
            SnackBar(content: Text(message.message)),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    initPref();
    return Scaffold(
      body: SafeArea(
        child: WebView(
          initialUrl: 'https://kyrgyz.space/p/ekobak/basket.php?user=$number',
          javascriptMode: JavascriptMode.unrestricted,
          onWebViewCreated: (WebViewController webViewController) {
            _prefs.then((SharedPreferences prefs) {
              if (prefs.getString('number') == null) {
                webViewController
                    .loadUrl('http://kyrgyz.space/p/ekobak/get_user_id.php')
                    .then((value2) {
                  if (kDebugMode) {
                    print('==============');
                  }
                  return;
                });
              }
            });
          },
          onProgress: (int progress) {
            print('WebView is loading (progress : $progress%)');
          },
          javascriptChannels: <JavascriptChannel>{
            _toasterJavascriptChannel(context),
          },
          navigationDelegate: (NavigationRequest request) {
            if (request.url.startsWith('https://www.youtube.com/')) {
              print('blocking navigation to $request}');
              return NavigationDecision.prevent;
            }
            print('allowing navigation to $request');
            return NavigationDecision.navigate;
          },
          onPageStarted: (String url) {
            print('Page started loading: $url');
          },
          onPageFinished: (String url) async {
            print('Page finished loading: $url');
            var index = url.indexOf('=');
            print('NUMBER ${index}');
            var number = url.substring(index, url.length);
            print('NUMBER ${number}');
            _prefs.then((SharedPreferences prefs) {
              if (prefs.getString('number') == null) {
                this.number = int.parse(number);
                prefs.setString('number', number);
                setState(() {});
              }
            });
          },
          gestureNavigationEnabled: true,
          backgroundColor: const Color(0x00000000),
        ),
      ),
    );
  }
}
