import 'dart:convert';

import 'package:asgshighschool/StoreMainPage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
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
    await _getProducts();
    await Future.delayed(Duration(seconds: 1));
    Navigator.pushReplacement(context,MaterialPageRoute(builder: (context)
    => StoreMainPage(user: widget.user,)));
  }
  Future<void> _getProducts() async{
    String url = 'http://nacha01.dothome.co.kr/sin/arlimi_getProduct.php';
    final response = await http.get(url);

    if(response.statusCode == 200){
      print(response.body);
      String result = utf8
          .decode(response.bodyBytes)
          .replaceAll(
          '<meta http-equiv="Content-Type" content="text/html; charset=utf-8">',
          '')
          .trim();
      print(json.decode(result)[0]);
      var a = json.decode(result);
      print(json.decode(a[0])['prodID']);
      // 디코딩의 디코딩 작업 필요 (두번의 json 디코딩)
      // 가장 바깥쪽 array를 json으로 변환하고
      // 내부 데이터를 json으로 변환?..
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        Container(color: Color(0xFF9EE1E5),child: Text('텍스트 및 로고'),),
      ],)
    );
  }
}
