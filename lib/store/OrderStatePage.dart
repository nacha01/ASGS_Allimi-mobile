import 'dart:convert';
import 'dart:ui';

import 'package:asgshighschool/data/user_data.dart';
import 'package:asgshighschool/store/DetailOrderStatePage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class OrderStatePage extends StatefulWidget {
  OrderStatePage({this.user});
  final User user;
  @override
  _OrderStatePageState createState() => _OrderStatePageState();
}

class _OrderStatePageState extends State<OrderStatePage> {
  List _orderMap = [];
  final _categoryReverseMap = {
    0: '음식류',
    1: '간식류',
    2: '음료류',
    3: '문구류',
    4: '핸드메이드'
  };

  /// 나(uid)의 모든 주문한 내역(현황)들을 요청하는 작업
  Future<bool> _getOrderInfoRequest() async {
    String url =
        'http://nacha01.dothome.co.kr/sin/arlimi_getAllOrderInfo.php?uid=${widget.user.uid}';
    final response = await http.get(url);
    if (response.statusCode == 200) {
      /// json decode 를 3번 해야한다. detail 까지 위해서는
      String result = utf8
          .decode(response.bodyBytes)
          .replaceAll(
              '<meta http-equiv="Content-Type" content="text/html; charset=utf-8">',
              '')
          .trim();
      List map1st = json.decode(result);

      /// json 의 가장 바깥쪽 껍데기 파싱

      for (int i = 0; i < map1st.length; ++i) {
        map1st[i] = json.decode(map1st[i]);

        /// 2차 내부 json 내용 파싱
        for (int j = 0; j < map1st[i]['detail'].length; ++j) {
          map1st[i]['detail'][j] = json.decode(map1st[i]['detail'][j]);
          map1st[i]['detail'][j]['pInfo'] =
              json.decode(map1st[i]['detail'][j]['pInfo']);

          /// 내부 detail 의 json 파싱
        }
      }
      setState(() {
        _orderMap = map1st;
      });
      return true;
    } else {
      return false;
    }
  }

  /// 주문의 date 필드를 사용자에게 직관적으로 보이게 하는 날짜 formatting 작업
  /// yyyy-mm-dd hh:mm:ss  ->  mm/dd hh:mm
  String _formatForItemDate(String date) {
    return date.substring(5, 16).replaceAll('-', '/');
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
    super.initState();
    _getOrderInfoRequest();
  }

  /// 주문 상태 field 값에 따른 사용자에게 보여줄 mapping 색상을 반환
  /// @param : DB에 저장된 '주문 상태 필드'의 정수 값
  Color _getColorAccordingToOrderState(int state) {
    switch (state) {
      case 0:
        return Colors.red;
      case 1:
        return Colors.orangeAccent;
      case 2:
        return Colors.lightBlue;
      case 3:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  /// 주문 상태 field 값에 따른 사용자에게 보여줄 mapping 문자열을 반환
  /// @param : DB에 저장된 '주문 상태 필드'의 정수 값
  String _getTextAccordingToOrderState(int state) {
    switch (state) {
      case 0:
        return '미결제 및 미수령';
      case 1:
        return '결제완료 및 미수령';
      case 2:
        return '주문 처리 중';
      case 3:
        return '결제완료 및 수령완료';
      default:
        return 'Error';
    }
  }

  /// 목록에서 어떤 상품을 구매했는지에 대한 간략 소개를 위한 텍스트 작업
  /// @param : 특정 주문 데이터에 대한 상품 목록 List
  /// format : 상품이 한 종류 시, xxx n개 | 두 종류 이상 시, xxx n개 외 y개
  String _extractDetailProductText(List detail) {
    if (detail.length == 1) {
      return detail[0]['pInfo']['pName'] + ' ' + detail[0]['quantity'] + '개';
    } else {
      return detail[0]['pInfo']['pName'] +
          ' ' +
          detail[0]['quantity'] +
          '개 외 ${detail.length - 1}개';
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
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
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            width: size.width,
            height: size.height * 0.05,
            child: Column(
              children: [],
            ),
          ),
          _orderMap.length == 0
              ? Expanded(
                  child: Center(
                  child: Text(
                    '주문 내역이 없습니다!',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ))
              : Expanded(
                  child: ListView.builder(
                  itemBuilder: (context, index) {
                    return orderListItemLayout(_orderMap[index], size);
                  },
                  itemCount: _orderMap.length,
                ))
        ],
      ),
    );
  }

  Widget orderListItemLayout(Map orderJson, Size size) {
    return GestureDetector(
      onTap: () {
        // 상세 주문 현황 페이지로 이동
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => DetailOrderStatePage(
                      order: orderJson,
                      user: widget.user,
                    )));
      },
      child: Container(
        padding: EdgeInsets.all(size.width * 0.02),
        width: size.width,
        height: size.height * 0.15,
        decoration: BoxDecoration(
          border: Border.all(width: 0.5, color: Colors.black26),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '주문번호 : ${orderJson['oID']}',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
                Text(
                  '${_formatForItemDate(orderJson['oDate'])}',
                  style: TextStyle(color: Colors.black45),
                )
              ],
            ),
            SizedBox(
              height: size.height * 0.01,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '[${_categoryReverseMap[int.parse(orderJson['detail'][0]['pInfo']['category'])]}] ',
                  style: TextStyle(color: Colors.grey),
                ),
                Text(
                  ' ${_extractDetailProductText(orderJson['detail'])} ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    '${_getTextAccordingToOrderState(int.parse(orderJson['orderState']))}',
                    style: TextStyle(
                        color: _getColorAccordingToOrderState(
                            int.parse(orderJson['orderState']))),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    '${_formatPrice(int.parse(orderJson['totalPrice']))}원',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
