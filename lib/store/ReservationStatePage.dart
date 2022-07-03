import 'dart:convert';
import 'dart:ui';

import 'package:asgshighschool/data/category_data.dart';
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
  List _reservationList = []; // 모든 예약 정보를 담은 json 리스트 (수령 완료 포함)
  List _notCompleteList = []; // 아직 완료처리가 되지 않은 예약 정보를 담은 json 리스트
  bool _isChecked = true;

  /// 해당 사용자에 대한 모든 예약 정보를 가져오는 요청
  /// 중간 과정으로 예약 완료 처리된 데이터를 구분하고 파싱하는 작업
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
                        _isChecked
                            ? Icons.check_box
                            : Icons.check_box_outline_blank,
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
              ? _notCompleteList.length != 0
                  ? Expanded(
                      child: ListView.builder(
                      itemBuilder: (context, index) {
                        return _itemTile(_notCompleteList[index], size);
                      },
                      itemCount: _notCompleteList.length,
                    ))
                  : Expanded(
                      child: Center(
                      child: Text('예약한 내역이 없습니다.',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15)),
                    ))
              : _reservationList.length != 0
                  ? Expanded(
                      child: ListView.builder(
                      itemBuilder: (context, index) {
                        return _itemTile(_reservationList[index], size);
                      },
                      itemCount: _reservationList.length,
                    ))
                  : Expanded(
                      child: Center(
                      child: Text(
                        '예약한 내역이 없습니다.',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15),
                      ),
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
                  width: size.width * 0.2,
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
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12),
                  ),
                ),
                Container(
                  alignment: Alignment.center,
                  width: size.width * 0.18,
                  padding: EdgeInsets.all(size.width * 0.01),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(width: 1, color: Colors.black),
                      color: int.parse(data['orderState']) == 0
                          ? Colors.redAccent
                          : Colors.teal),
                  child: Text(
                    int.parse(data['orderState']) == 0 ? '미결제' : '결제완료',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12),
                  ),
                ),
                Text(
                  '예약 번호 ${data['oID']}',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                )
              ],
            ),
            SizedBox(
              height: size.height * 0.01,
            ),
            Align(
              alignment: Alignment.topLeft,
              child: Wrap(
                spacing: size.width * 0.09,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '[${Category.categoryIndexToStringMap[int.parse(data['detail'][0]['pInfo']['category'])]}]',
                        style: TextStyle(color: Colors.grey[500], fontSize: 15),
                      ),
                      Text(
                        ' ${data['detail'][0]['pInfo']['pName']} ',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15),
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}
