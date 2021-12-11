import 'dart:ui';

import 'package:asgshighschool/data/user_data.dart';
import 'package:asgshighschool/storeAdmin/ReservationListPage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AdminDetailReservation extends StatefulWidget {
  final List reservationList;
  final User user;
  final ProductCount productCount;
  AdminDetailReservation({this.reservationList, this.user, this.productCount});
  @override
  _AdminDetailReservationState createState() => _AdminDetailReservationState();
}

class _AdminDetailReservationState extends State<AdminDetailReservation> {
  List _productReservationList = [];
  void _preProcessing() {
    for (int i = 0; i < widget.reservationList.length; ++i) {
      if (widget.productCount.pid ==
              int.parse(widget.reservationList[i]['detail'][0]['oPID']) &&
          int.parse(widget.reservationList[i]['orderState']) != 0) {
        _productReservationList.add(widget.reservationList[i]);
      }
    }
    print(_productReservationList);
    _productReservationList = List.from(_productReservationList.reversed);
  }

  /// 등록된 날짜와 오늘의 날짜를 비교해서 어느 정도 차이가 있는지에 대한 문자열을 반환하는 작업
  /// n일 전, n시간 전, n분 전
  String _formatDateTimeForToday(String origin) {
    var today = DateTime.now();

    int dayDiff =
        int.parse(today.difference(DateTime.parse(origin)).inDays.toString());
    if (dayDiff < 1) {
      int hourDiff = int.parse(
          today.difference(DateTime.parse(origin)).inHours.toString());
      if (hourDiff < 1) {
        int minDiff = int.parse(
            today.difference(DateTime.parse(origin)).inMinutes.toString());
        return minDiff.toString() + '분 전';
      }
      return hourDiff.toString() + '시간 전';
    } else {
      return dayDiff.toString() + '일 전';
    }
  }

  /// 일반 숫자에 ,를 붙여서 직관적인 가격을 보이게 하는 작업
  /// @param : 직관적인 가격을 보여줄 실제 int 가격[price]
  /// @return : 직관적인 가격 문자열
  String _formatPrice(int price) {
    String p = price.toString();
    String newFormat = '';
    int count = 0;
    for (int i = p.length - 1; i >= 0; --i) {
      if ((count + 1) % 4 == 0) {
        newFormat += ',';
        ++i;
      } else
        newFormat += p[i];
      ++count;
    }
    return _reverseString(newFormat);
  }

  /// 문자열을 뒤집는 작업
  /// @param : 뒤집고 싶은 문자열[str]
  /// @return : 뒤집은 문자열
  String _reverseString(String str) {
    String newStr = '';
    for (int i = str.length - 1; i >= 0; --i) {
      newStr += str[i];
    }
    return newStr;
  }

  @override
  void initState() {
    _preProcessing();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF9EE1E5),
        title: Text(
          '[${widget.productCount.name}] 예약 정보',
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
          Text('* 상품 정보'),
          Row(
            children: [
              Text('현재 재고'),
              Text(
                  ' ${_productReservationList[0]['detail'][0]['pInfo']['stockCount']}개'),
            ],
          ),
          Row(
            children: [
              Text('가격'),
              Text(
                  ' ${_formatPrice(int.parse(_productReservationList[0]['detail'][0]['pInfo']['price']))}원')
            ],
          ),
          Expanded(
              child: ListView.builder(
            itemBuilder: (context, index) {
              return _personDataTile(_productReservationList[index], size);
            },
            itemCount: _productReservationList.length,
          )),
          Container(
            child: FlatButton(
              onPressed: int.parse(_productReservationList[0]['detail'][0]
                          ['pInfo']['stockCount']) <
                      1
                  ? null
                  : () {
                      if (int.parse(_productReservationList[0]['detail'][0]
                              ['pInfo']['stockCount']) <
                          1) {
                        print('아직 재고 없음');
                        return;
                      }
                    },
              child: Text(
                '자동 예약 알림 전송하기',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13),
              ),
            ),
            width: size.width * 0.5,
            height: size.height * 0.05,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(width: 1, color: Colors.black),
                color: int.parse(_productReservationList[0]['detail'][0]
                            ['pInfo']['stockCount']) <
                        1
                    ? Colors.grey
                    : Colors.lightBlue),
          )
        ],
      ),
    );
  }

  Widget _personDataTile(Map data, Size size) {
    return Container(
      width: size.width,
      padding: EdgeInsets.all(size.width * 0.015),
      margin: EdgeInsets.all(size.width * 0.008),
      decoration: BoxDecoration(
          border: Border.all(width: 1.5, color: Colors.black),
          borderRadius: BorderRadius.circular(6)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Icon(
            Icons.person,
            color: Colors.grey,
          ),
          Text(
            '예약 번호',
            style: TextStyle(fontSize: 10),
          ),
          Text('${data['oID']}',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
          SizedBox(
            width: size.width * 0.01,
          ),
          Text('${data['name']}',
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.green)),
          Text('${data['detail'][0]['quantity']}개',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
          Text('${_formatDateTimeForToday(data['oDate'])}',
              style: TextStyle(fontSize: 11, color: Colors.deepOrange))
        ],
      ),
    );
  }
}
