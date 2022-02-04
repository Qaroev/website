import 'dart:async';
import 'dart:io';

import 'package:connectivity/connectivity.dart';
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
  int number = 0;
  bool hasInternet = true;

  @override
  void initState() {
    InternetAddress.lookup('example.com').then((result) {
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        print('connected');
        setState(() {
          hasInternet = true;
        });
      } else {
        print('disconnected');
        setState(() {
          hasInternet = false;
        });
      }
    }).catchError((err) {
      setState(() {
        hasInternet = false;
      });
    });
    super.initState();
    if (Platform.isAndroid) WebView.platform = AndroidWebView();
    _prefs.then((SharedPreferences prefs) {
      if (prefs.getString('number')! != null) {
        number = int.parse(prefs.getString('number')!);
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
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
    return Scaffold(
      body: hasInternet
          ? SafeArea(
              child: WebView(
                initialUrl:
                    'https://kyrgyz.space/p/ekobak/basket.php?user=$number',
                javascriptMode: JavascriptMode.unrestricted,
                onWebViewCreated: (WebViewController webViewController) {
                  _prefs.then((SharedPreferences prefs) {
                    if (prefs.getString('number') == null) {
                      webViewController
                          .loadUrl(
                              'http://kyrgyz.space/p/ekobak/get_user_id.php')
                          .then((value2) {
                        if (kDebugMode) {
                          print('==============');
                        }
                        return;
                      });
                    } else {
                      number = int.parse(prefs.getString('number')!);
                      webViewController
                          .loadUrl(
                              'https://kyrgyz.space/p/ekobak/basket.php?user=$number')
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
                  if (url != '' && url != null) {
                    var index = url.indexOf('=');
                    print('NUMBER ${index}');
                    if (index != -1) {
                      var number = url.substring(index + 1, url.length);
                      print('NUMBER ${number}');
                      _prefs.then((SharedPreferences prefs) {
                        if (prefs.getString('number') == null &&
                            number != '0') {
                          this.number = int.parse(number);
                          prefs.setString('number', number);
                          setState(() {});
                        }
                      });
                    }
                  }
                },
                backgroundColor: const Color(0x00000000),
              ),
            )
          : const Center(
              child: Text('You internet no connection'),
            ),
    );
  }
}
