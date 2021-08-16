import 'dart:convert';

import 'package:asgshighschool/StoreMainPage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'data/product_data.dart';

class StoreSplashPage extends StatefulWidget {
  final user;
  StoreSplashPage({this.user});
  @override
  _StoreSplashPageState createState() => _StoreSplashPageState();
}

class _StoreSplashPageState extends State<StoreSplashPage> {
  @override
  void initState() {
    super.initState();
    loading();
  }

  loading() async {
    List result = await _getProducts();
    await Future.delayed(Duration(seconds: 1));
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => StoreMainPage(
                  user: widget.user,
                  product: result,
                )));
  }

  Future<List<Product>> _getProducts() async {
    String url = 'http://nacha01.dothome.co.kr/sin/arlimi_getProduct.php';
    final response = await http.get(url);

    if (response.statusCode == 200) {
      print(response.body);
      if(response.body.contains('일일 트래픽을 모두 사용하였습니다.')){
        print('일일 트래픽 모두 사용');
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
        body: Stack(
      children: [
        Container(
          width: size.width,
          height: size.height,
          alignment: Alignment.center,
          color: Color(0xFF9EE1E5),
          child: Text('텍스트 및 로고'),
        ),
      ],
    ));
  }
}
