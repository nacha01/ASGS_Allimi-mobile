import 'dart:convert';

import 'package:asgshighschool/data/exist_cart.dart';
import 'package:asgshighschool/data/user_data.dart';
import 'package:provider/provider.dart';

import 'StoreMainPage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../data/product_data.dart';

class StoreSplashPage extends StatefulWidget {
  final User user;
  StoreSplashPage({this.user});
  @override
  _StoreSplashPageState createState() => _StoreSplashPageState();
}

class _StoreSplashPageState extends State<StoreSplashPage> {
  bool _isExist = false;
  @override
  void initState() {
    super.initState();
    loading();
  }

  /// Splash 페이지의 로딩 process
  loading() async {
    List result = await _getProducts();
    var res = await _checkExistCart();
    _isExist = res;
    await Future.delayed(Duration(seconds: 1));
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => StoreMainPage(
                  user: widget.user,
                  product: result,
                  existCart: res,
                )));
  }

  /// 장바구니에 데이터가 존재하는지 체크 요청을 하는 작업
  Future<bool> _checkExistCart() async {
    String uri = 'http://nacha01.dothome.co.kr/sin/arlimi_checkCart.php';
    final response = await http.get(uri + '?uid=${widget.user.uid}');

    if (response.statusCode == 200) {
      String result = utf8
          .decode(response.bodyBytes)
          .replaceAll(
              '<meta http-equiv="Content-Type" content="text/html; charset=utf-8">',
              '')
          .trim();
      if (int.parse(result) >= 1) {
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  /// 모든 상품 데이터를 요청하는 작업
  Future<List<Product>> _getProducts() async {
    String url = 'http://nacha01.dothome.co.kr/sin/arlimi_getProduct.php';
    final response = await http.get(url);

    if (response.statusCode == 200) {
      print(response.body);
      if (response.body.contains('일일 트래픽을 모두 사용하였습니다.')) {
        // 임시 유저로 이동
        return [];
      }
      String result = utf8
          .decode(response.bodyBytes)
          .replaceAll(
              '<meta http-equiv="Content-Type" content="text/html; charset=utf-8">',
              '')
          .trim();
      List productList = json.decode(result);
      List<Product> prodObjects = [];
      for (int i = 0; i < productList.length; ++i) {
        prodObjects.add(Product.fromJson(json.decode(productList[i])));
      }
      return prodObjects;
      // 디코딩의 디코딩 작업 필요 (두번의 json 디코딩)
      // 가장 바깥쪽 array를 json으로 변환하고
      // 내부 데이터를 json으로 변환
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
        body: SafeArea(
      child: Stack(
        children: [
          Container(
            width: size.width,
            height: size.height,
            alignment: Alignment.center,
            color: Color(0xFF9EE1E5),
            child: Column(
              children: [
                Text(
                  ''/*텍스트 및 로고*/,
                  textScaleFactor: 1.5,
                ),
                SizedBox(
                  height: size.height * 0.05,
                ),
                Text(widget.user.isAdmin ? '관리자 권한으로 접근합니다...' : ''),
              ],
            ),
          ),
        ],
      ),
    ));
  }
}
