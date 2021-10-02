import 'dart:convert';

import 'package:asgshighschool/data/user_data.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class OrderListPage extends StatefulWidget {
  OrderListPage({this.user});
  final User user;
  @override
  _OrderListPageState createState() => _OrderListPageState();
}

class _OrderListPageState extends State<OrderListPage> {
  List _orderList = [];
  List _noneList = [];
  bool _isChecked = true;

  Future<bool> _getAllOrderData() async {
    String url = 'http://nacha01.dothome.co.kr/sin/arlimi_getAllOrder.php';
    final response = await http.get(url);

    if (response.statusCode == 200) {
      String result = utf8
          .decode(response.bodyBytes)
          .replaceAll(
              '<meta http-equiv="Content-Type" content="text/html; charset=utf-8">',
              '')
          .trim();
      List map1st = json.decode(result);

      for (int i = 0; i < map1st.length; ++i) {
        _orderList.add(json.decode(map1st[i]));
        for (int j = 0; j < _orderList[i]['detail'].length; ++j) {
          _orderList[i]['detail'][j] = json.decode(_orderList[i]['detail'][j]);
          _orderList[i]['detail'][j]['pInfo'] =
              json.decode(_orderList[i]['detail'][j]['pInfo']);
        }
        if (int.parse(_orderList[i]['orderState']) == 0 ||
            int.parse(_orderList[i]['orderState']) == 1) {
          _noneList.add(_orderList[i]);
        }
      }
      setState(() {

      });
      return true;
    } else {
      return false;
    }
  }

  @override
  void initState() {
    _getAllOrderData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF9EE1E5),
        title: Text(
          '실시간 주문 목록',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.arrow_back,
              color: Colors.black,
            )),
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                child: FlatButton(
                  child: Row(
                    children: [
                      Icon(
                        _isChecked
                            ? Icons.check_box
                            : Icons.check_box_outlined,
                        color: Colors.blue,
                      ),
                      Text('주문 처리 완료 안보기')
                    ],
                  ),
                  onPressed: () {
                    setState(() {
                      _isChecked = !_isChecked;
                    });
                  },
                ),
              )
            ],
          ),
          Divider(),

        ],
      ),
    );
  }
}
