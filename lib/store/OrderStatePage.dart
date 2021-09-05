import 'dart:convert';

import 'package:asgshighschool/data/user_data.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class OrderStatePage extends StatefulWidget {
  OrderStatePage({this.user});
  final User user;
  @override
  _OrderStatePageState createState() => _OrderStatePageState();
}

class _OrderStatePageState extends State<OrderStatePage> {
  Future<bool> _getOrderInfoRequest() async {
    String url =
        'http://nacha01.dothome.co.kr/sin/arlimi_getAllOrderInfo.php?uid=${widget.user.uid}';
    final response = await http.get(url);

    if (response.statusCode == 200) {
      // json decode 3번 해야함 detail까지 위해서는
      String result = utf8
          .decode(response.bodyBytes)
          .replaceAll(
              '<meta http-equiv="Content-Type" content="text/html; charset=utf-8">',
              '')
          .trim();

      List map1st = json.decode(result);
      // json의 가장 바깥쪽 껍데기 파싱
      for (int i = 0; i < map1st.length; ++i) {
        map1st[i] = json.decode(map1st[i]);
      }
      // 2차 내부 json 내용 파싱
      for (int i = 0; i < map1st.length; ++i) {
        for (int j = 0; j < map1st[i]['detail'].length; ++j) {
          map1st[i]['detail'][j] = json.decode(map1st[i]['detail'][j]);
        }
      }
      // 내부 detail의 json 파싱
      print(map1st);
      return true;
    } else {
      return false;
    }
  }

  @override
  void initState() {
    super.initState();
    _getOrderInfoRequest();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          color: Colors.black,
          icon: Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
        ),
        backgroundColor: Color(0xFF9EE1E5),
        title: Text(
          '주문 현황',
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 13),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [],
      ),
    );
  }
}
