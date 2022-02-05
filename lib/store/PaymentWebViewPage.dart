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

  Future<String> getAppUrlForAndroid(String url) async {
    if (Platform.isAndroid) {
      return await platform
          .invokeMethod('getAppUrl', <String, Object>{'url': url});
    } else {
      return url;
    }
  }

  Future<String> getMarketUrlForAndroid(String url) async {
    if (Platform.isAndroid) {
      return await platform
          .invokeMethod('getMarketUrl', <String, Object>{'url': url});
    } else {
      return url;
    }
  }

  String getAppUrlForIOS(String url) {
    return url;
  }

  String getMarketUrlForIOS(String url) {
    switch (Uri.parse(url).scheme) {
      case 'kftc-bankpay': // 뱅크페이
        return 'https://itunes.apple.com/kr/app/id398456030';
      case 'ispmobile': // ISP/페이북
        return 'https://itunes.apple.com/kr/app/id369125087';
      case 'hdcardappcardansimclick': // 현대카드 앱카드
        return 'https://itunes.apple.com/kr/app/id702653088';
      case 'shinhan-sr-ansimclick': // 신한 앱카드
        return 'https://itunes.apple.com/app/id572462317';
      case 'kb-acp': // KB국민 앱카드
        return 'https://itunes.apple.com/kr/app/id695436326';
      case 'mpocket.online.ansimclick': // 삼성앱카드
        return 'https://itunes.apple.com/kr/app/id535125356';
      case 'lottesmartpay': // 롯데 모바일결제
        return 'https://itunes.apple.com/kr/app/id668497947';
      case 'lotteappcard': // 롯데 앱카드
        return 'https://itunes.apple.com/kr/app/id688047200';
      case 'cloudpay': // 하나1Q페이(앱카드)
        return 'https://itunes.apple.com/kr/app/id847268987';
      case 'citimobileapp': // 시티은행 앱카드
        return 'https://itunes.apple.com/kr/app/id1179759666';
      case 'payco': // 페이코
        return 'https://itunes.apple.com/kr/app/id924292102';
      case 'kakaotalk': // 카카오톡
        return 'https://itunes.apple.com/kr/app/id362057947';
      case 'lpayapp': // 롯데 L.pay
        return 'https://itunes.apple.com/kr/app/id1036098908';
      case 'wooripay': // 우리페이
        return 'https://itunes.apple.com/kr/app/id1201113419';
      case 'nhallonepayansimclick': // NH농협카드 올원페이(앱카드)
        return 'https://itunes.apple.com/kr/app/id1177889176';
      case 'hanawalletmembers': // 하나카드(하나멤버스 월렛)
        return 'https://itunes.apple.com/kr/app/id1038288833';
      case 'shinsegaeeasypayment': // 신세계 SSGPAY
        return 'https://itunes.apple.com/app/id666237916';
      default:
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
        onLoadStart: (controller, uri) async {
          if (Platform.isAndroid) {
            if (uri.scheme == 'about') {
              _inAppWebViewController.goBack();
            }
            if (uri.scheme == 'intent') {
              var url = uri.toString();
              _inAppWebViewController.stopLoading();
              getAppUrlForAndroid(url).then((value) async {
                if (await canLaunch(value)) {
                  await launch(value);
                } else {
                  final market = await getMarketUrlForAndroid(url);
                  await launch(market);
                }
              });
            }
          } else if (Platform.isIOS) {
            if (_isAppLink(uri.toString())) {
              if (await canLaunch(uri.toString())) {
                await launch(getAppUrlForIOS(uri.toString()),
                    forceSafariVC: false);
              } else {
                var marketUrl = getMarketUrlForIOS(uri.toString());
                await launch(marketUrl, forceSafariVC: false);
              }
            }
          }
        },
        shouldOverrideUrlLoading: (controller, request) async {
          var uri = await controller.getUrl();
          if (Platform.isAndroid) {
            if (uri != null && uri.scheme == 'intent') {
              return NavigationActionPolicy.CANCEL;
            }
            return NavigationActionPolicy.ALLOW;
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
          _inAppWebViewController.postUrl(
              url: Uri.parse('https://web.nicepay.co.kr/v3/v3Payment.jsp'),
              postData: Uint8List.fromList(
                  cp949.encode('GoodsName=${widget.productName}&'
                      'Amt=${widget.totalPrice}&'
                      'MID=$_MID&'
                      'ReturnURL=$_RETURN_URL&'
                      'EdiDate=$_ediDate&'
                      'Moid=${widget.oID}&'
                      'SignData=${_getSignData()}&'
                      'CharSet=euc-kr')));
        },
      ),
    );
  }
}
