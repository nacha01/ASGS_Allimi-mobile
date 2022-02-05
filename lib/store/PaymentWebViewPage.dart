import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:hex/hex.dart';
import 'package:cp949/cp949.dart' as cp949;
import 'package:url_launcher/url_launcher.dart';

class PaymentWebViewPage extends StatefulWidget {
  final int totalPrice;
  final String productName;
  final String oID;
  PaymentWebViewPage({this.totalPrice, this.productName, this.oID});

  @override
  _PaymentWebViewPageState createState() => _PaymentWebViewPageState();
}

class _PaymentWebViewPageState extends State<PaymentWebViewPage> {
  InAppWebViewController _inAppWebViewController;
  static const platform = MethodChannel('asgs');
  final _KEY =
      '33F49GnCMS1mFYlGXisbUDzVf2ATWCl9k3R++d5hDd3Frmuos/XLx8XhXpe+LDYAbpGKZYSwtlyyLOtS/8aD7A==';
  final _MID = 'nictest00m';
  final _RETURN_URL = 'http://nacha01.dothome.co.kr/sin/result_test.php';
  String _ediDate = '';

  String _getSignData() {
    return HEX.encode(sha256
        .convert(
            utf8.encode(_ediDate + _MID + widget.totalPrice.toString() + _KEY))
        .bytes);
  }

  bool _isAppLink(String url) {
    final appScheme = Uri.parse(url).scheme;
    return appScheme != 'http' &&
        appScheme != 'https' &&
        appScheme != 'about:blank' &&
        appScheme != 'data' &&
        appScheme != 'about';
  }

  Future<String> getAppUrl(String url) async {
    if (Platform.isAndroid) {
      return await platform
          .invokeMethod('getAppUrl', <String, Object>{'url': url});
    } else {
      return url;
    }
  }

  Future<String> getMarketUrl(String url) async {
    if (Platform.isAndroid) {
      return await platform
          .invokeMethod('getMarketUrl', <String, Object>{'url': url});
    } else {
      return url;
    }
  }

  @override
  void initState() {
    _ediDate = DateTime.now()
        .toString()
        .replaceAll('-', '')
        .replaceAll(' ', '')
        .replaceAll(':', '')
        .split('.')[0];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Color(0xFF9EE1E5),
          title: Text(
            '결제하기',
            style: TextStyle(
                color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14),
          ),
          centerTitle: true,
          leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(
                Icons.arrow_back,
                color: Colors.black,
              ))),
      body: InAppWebView(
        initialUrlRequest: URLRequest(
            url: Uri.parse('https://web.nicepay.co.kr/v3/v3Payment.jsp'),
            method: 'POST',
            body: Uint8List.fromList(
                cp949.encode('GoodsName=${widget.productName}&'
                    'Amt=${widget.totalPrice}&'
                    'MID=$_MID&'
                    'ReturnURL=$_RETURN_URL&'
                    'EdiDate=$_ediDate&'
                    'Moid=${widget.oID}&'
                    'SignData=${_getSignData()}&'
                    'CharSet=euc-kr'))),
        onLoadStart: (controller, uri) {
          if (uri.scheme == 'about') {
            _inAppWebViewController.goBack();
          }
          if (uri.scheme == 'intent') {
            var url = uri.toString();
            _inAppWebViewController.stopLoading();
            getAppUrl(url).then((value) async {
              if (await canLaunch(value)) {
                await launch(value);
              } else {
                final market = await getMarketUrl(url);
                await launch(market);
              }
            });
          }
        },
        shouldOverrideUrlLoading: (controller, request) async {
          var uri = await controller.getUrl();
          if (uri != null && uri.scheme == 'intent') {
            return NavigationActionPolicy.CANCEL;
          }
          return NavigationActionPolicy.ALLOW;
        },
        onWebViewCreated: (controller) {
          _inAppWebViewController = controller;
          _inAppWebViewController.setOptions(
              options: InAppWebViewGroupOptions(
                  crossPlatform: InAppWebViewOptions(
                    useShouldOverrideUrlLoading: true,
                    javaScriptEnabled: true,
                    cacheEnabled: true,
                  ),
                  android: AndroidInAppWebViewOptions(
                      disableDefaultErrorPage: true,
                      mixedContentMode:
                          AndroidMixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
                      thirdPartyCookiesEnabled: true,
                      cacheMode: AndroidCacheMode.LOAD_DEFAULT)));
        },
      ),
    );
  }
}
