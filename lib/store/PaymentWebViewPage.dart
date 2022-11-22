import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:asgshighschool/data/product_data.dart';
import 'package:asgshighschool/data/user_data.dart';
import 'package:asgshighschool/store/PaymentCompletePage.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:hex/hex.dart';
import 'package:cp949/cp949.dart' as cp949;
import 'package:url_launcher/url_launcher.dart';

class PaymentWebViewPage extends StatefulWidget {
  final String oID; // 생성한 order ID
  final bool isCart; // 장바구니 결제인지 단일 상품 결제인지 판단하는 flag

  final List<Map> cart; // 장바구니에서 결제시 장바구니 리스트 Map 데이터
  final Product direct; // 바로 결제 시 그 단일 상품 하나
  final int productCount; // 바로 결제시 상품의 개수
  final User user;
  final List optionList; // 바로 결제 시 단일 상품에 대한 옵션 리스트
  final List selectList; // 바로 결제 시 단일 상품에 대한 옵션 리스트에 대해 선택한 인덱스 리스트
  final int additionalPrice; // 상품 옵션의 총 가격

  final String receiveMethod; // 수령 방법
  final String option; // 추가 요청
  final String location; // 배달 시 위치정보

  PaymentWebViewPage(
      {this.oID,
      this.direct,
      this.cart,
      this.productCount,
      this.user,
      this.optionList,
      this.selectList,
      this.additionalPrice,
      this.receiveMethod,
      this.option,
      this.location,
      this.isCart});

  @override
  _PaymentWebViewPageState createState() => _PaymentWebViewPageState();
}

class _PaymentWebViewPageState extends State<PaymentWebViewPage> {
  InAppWebViewController _inAppWebViewController;
  static const platform = MethodChannel('asgs');
  static const _KEY =
      '0DVRz8vSDD5HvkWRwSxpjVhhx7OlXEViTciw5lBQAvSyYya9yf0K0Is+JbwiR9yYC96rEH2XIbfzeHXgqzSAFQ==';
  static const _MID = 'asgscoop1m';
  static const _RETURN_URL = 'http://nacha01.dothome.co.kr/sin/result_test.php';
  String _ediDate = '';
  bool _isCart = true;
  String _goodsName = '';
  int _totalPrice = 0;

  String _getSignData() {
    return HEX.encode(sha256
        .convert(utf8.encode(_ediDate + _MID + _totalPrice.toString() + _KEY))
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

  void _setGoodsName() {
    if (_isCart) {
      if (widget.cart.length > 1) {
        _goodsName =
            widget.cart[0]['prodName'] + ' 외 ${widget.cart.length - 1}개';
      } else {
        _goodsName = widget.cart[0]['prodName'];
      }
    } else {
      _goodsName = widget.direct.prodName;
    }
  }

  int _obtainTotalPrice() {
    int sum = 0;
    if (_isCart) {
      for (int i = 0; i < widget.cart.length; ++i) {
        sum += (int.parse(widget.cart[i]['price']) *
                (1 -
                        (widget.cart[i]['discount'].toString() == '0.0'
                                ? 0
                                : double.parse(widget.cart[i]['discount'])) /
                            100.0)
                    .round()) *
            int.parse(widget.cart[i]['quantity']);
      }
      sum += widget.additionalPrice;
    } else {
      sum += widget.direct.price *
          (1 - (widget.direct.discount / 100.0)).round() *
          widget.productCount;
      sum += widget.additionalPrice;
    }
    return sum;
  }

  @override
  void initState() {
    if (widget.direct == null) {
      _isCart = true;
    }
    if (widget.cart == null) {
      _isCart = false;
    }
    _setGoodsName();
    _totalPrice = _obtainTotalPrice();
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
            //여기가 이용 약관이 나오는 곳이네 그렇다면 이미 nicepay 웹페이지로 간것인데...
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
          _inAppWebViewController.addJavaScriptHandler(
              handlerName: 'cancelPaymentHandler',
              callback: (args) {
                showDialog(
                    barrierDismissible: false,
                    context: context,
                    builder: (context) => AlertDialog(
                          title: Text(
                            '결제 취소',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          content: Text('${args[0][1]} (code-${args[0][0]})',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 14)),
                          actions: [
                            TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  Navigator.pop(this.context);
                                },
                                child: Text('확인'))
                          ],
                        ));
              });
          _inAppWebViewController.addJavaScriptHandler(
              handlerName: 'responseHandler',
              callback: (args) {
                print(args[0][1]);
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => PaymentCompletePage(
                              totalPrice: _totalPrice,
                              responseData: args[0],
                              // json { TID: ..., AuthToken: ...., MID: ... ....}
                              location: widget.location,
                              receiveMethod: widget.receiveMethod,
                              user: widget.user,
                              direct: widget.direct,
                              productCount: widget.productCount,
                              selectList: widget.selectList,
                              optionList: widget.optionList,
                              option: widget.option,
                              cart: widget.cart,
                              isCart: widget.isCart,
                            )));
              });
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
              postData: Uint8List.fromList(cp949.encode('GoodsName=$_goodsName&'
                  'Amt=$_totalPrice&'
                  'MID=$_MID&'
                  'ReturnURL=$_RETURN_URL&'
                  'EdiDate=$_ediDate&'
                  'Moid=${widget.oID}&'
                  'SignData=${_getSignData()}&'
                  'CharSet=euc-kr&'
                  'PayMethod=CARD&'
                  'BuyerName=${widget.user.name}')));
        },
      ),
    );
  }
}
