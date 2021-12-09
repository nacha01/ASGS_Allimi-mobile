import 'dart:convert';
import 'dart:ui';

import 'package:asgshighschool/data/user_data.dart';
import 'package:asgshighschool/store/DetailReservationStatePage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ReservationStatePage extends StatefulWidget {
  final User user;
  ReservationStatePage({this.user});
  @override
  _ReservationStatePageState createState() => _ReservationStatePageState();
}

class _ReservationStatePageState extends State<ReservationStatePage> {
  List _reservationList = [];
  List _notCompleteList = [];
  final _categoryReverseMap = {
    0: '음식류',
    1: '간식류',
    2: '음료류',
    3: '문구류',
    4: '핸드메이드'
  };
  bool _isChecked = true;

  Future<bool> _getReservationFromUser() async {
    String url =
        'http://nacha01.dothome.co.kr/sin/arlimi_getOneResv.php?uid=${widget.user.uid}';
    final response = await http.get(url);
    if (response.statusCode == 200) {
      String result = utf8
          .decode(response.bodyBytes)
          .replaceAll(
              '<meta http-equiv="Content-Type" content="text/html; charset=utf-8">',
              '')
          .trim();
      List map1st = json.decode(result);

      _reservationList.clear();
      _notCompleteList.clear();

      for (int i = 0; i < map1st.length; ++i) {
        _reservationList.add(json.decode(map1st[i]));
        for (int j = 0; j < _reservationList[i]['detail'].length; ++j) {
          _reservationList[i]['detail'][j] =
              json.decode(_reservationList[i]['detail'][j]);
          _reservationList[i]['detail'][j]['pInfo'] =
              json.decode(_reservationList[i]['detail'][j]['pInfo']);
        }
        if (!(int.parse(_reservationList[i]['orderState']) == 3 &&
            int.parse(_reservationList[i]['resvState']) == 2)) {
          _notCompleteList.add(_reservationList[i]);
        }
      }
      print(_reservationList);
      setState(() {});
      return true;
    } else {
      return false;
    }
  }

  @override
  void initState() {
    super.initState();
    _getReservationFromUser();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF9EE1E5),
        title: Text(
          '내 예약 현황',
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14),
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
                        _isChecked ? Icons.check_box : Icons.check_box_outlined,
                        color: Colors.blue,
                      ),
                      Text(" 예약 '수령 완료' 안보기")
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
          _isChecked
              ? Expanded(
                  child: ListView.builder(
                  itemBuilder: (context, index) {
                    return _itemTile(_notCompleteList[index], size);
                  },
                  itemCount: _notCompleteList.length,
                ))
              : Expanded(
                  child: ListView.builder(
                  itemBuilder: (context, index) {
                    return _itemTile(_reservationList[index], size);
                  },
                  itemCount: _reservationList.length,
                ))
        ],
      ),
    );
  }

  Widget _itemTile(Map data, Size size) {
    return GestureDetector(
      onTap: () async {
        var res = await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => DetailReservationStatePage(
                      user: widget.user,
                      data: data,
                    )));
        if (res) {
          _getReservationFromUser();
        }
      },
      child: Container(
        width: size.width,
        padding: EdgeInsets.all(size.width * 0.04),
        margin: EdgeInsets.all(size.width * 0.01),
        decoration: BoxDecoration(
            border: Border.all(width: 0.5, color: Colors.black26),
            borderRadius: BorderRadius.circular(5)),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  alignment: Alignment.center,
                  width: size.width * 0.25,
                  padding: EdgeInsets.all(size.width * 0.01),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(width: 1, color: Colors.black),
                      color: int.parse(data['resvState']) == 1
                          ? Colors.deepOrangeAccent
                          : (int.parse(data['orderState']) == 3 &&
                                  int.parse(data['resvState']) == 2)
                              ? Colors.lightGreen
                              : Colors.blueAccent),
                  child: Text(
                    int.parse(data['resvState']) == 1
                        ? '예약 중'
                        : (int.parse(data['orderState']) == 3 &&
                                int.parse(data['resvState']) == 2)
                            ? '수령 완료'
                            : '수령 준비',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(
                  width: size.width * 0.03,
                ),
                Text(
                  '예약 번호 ${data['oID']}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                )
              ],
            ),
            SizedBox(
              height: size.height * 0.01,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      '[${_categoryReverseMap[int.parse(data['detail'][0]['pInfo']['category'])]}]',
                      style: TextStyle(color: Colors.grey[500], fontSize: 15),
                    ),
                    Text(
                      ' ${data['detail'][0]['pInfo']['pName']} ',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    Text(
                      ' ${data['detail'][0]['quantity']}개',
                      style: TextStyle(fontSize: 15),
                    ),
                  ],
                ),
                Text(
                  '${data['oDate']}',
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
