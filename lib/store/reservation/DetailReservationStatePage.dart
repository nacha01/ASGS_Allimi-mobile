import 'dart:convert';

import 'package:asgshighschool/component/ThemeAppBar.dart';
import 'package:asgshighschool/data/category.dart';
import 'package:asgshighschool/data/user.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:http/http.dart' as http;

import '../../component/DefaultButtonComp.dart';

class DetailReservationStatePage extends StatefulWidget {
  final User? user;
  final Map? data;

  DetailReservationStatePage({this.user, this.data});

  @override
  _DetailReservationStatePageState createState() =>
      _DetailReservationStatePageState();
}

class _DetailReservationStatePageState
    extends State<DetailReservationStatePage> {
  /// DB에 저장된 date 필드를 사용자에게 직관적으로 보여주기 위한 날짜 formatting 작업
  /// @param : 주문 데이터의 date 필드 문자열
  String _formatDate(String date) {
    // yyyy-mm-dd hh:mm:ss
    var split = date.split(' ');

    var leftSp = split[0].split('-');
    String left = leftSp[0] + '년 ' + leftSp[1] + '월 ' + leftSp[2] + '일 ';

    var rightSp = split[1].split(':');
    String right = rightSp[0] + '시 ' + leftSp[1] + '분';

    return left + right;
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

  /// 아직 미결제된 예약 정보에 대해서 예약 취소를 요청하는 작업
  /// @return : 삭제 성공 여부
  Future<bool> _cancelReservation() async {
    String url =
        'http://nacha01.dothome.co.kr/sin/arlimi_cancelReservation.php?oid=${widget.data!['oID']}&pm=N';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      String result = utf8
          .decode(response.bodyBytes)
          .replaceAll(
              '<meta http-equiv="Content-Type" content="text/html; charset=utf-8">',
              '')
          .trim();
      if (result != '1') return false;
      return true;
    } else {
      return false;
    }
  }

  Future<bool> _updateReservationCurrentCount() async {
    String url =
        'http://nacha01.dothome.co.kr/sin/arlimi_cancelReservation.php';
    final response = await http.post(Uri.parse(url), body: <String, String?>{
      'pid': widget.data!['detail'][0]['pInfo']['pid'],
      'count': widget.data!['detail'][0]['quantity'],
      'operation': 'sub'
    });

    if (response.statusCode == 200) {
      String result = utf8
          .decode(response.bodyBytes)
          .replaceAll(
              '<meta http-equiv="Content-Type" content="text/html; charset=utf-8">',
              '')
          .trim();
      if (result != '1') return false;
      return true;
    } else {
      return false;
    }
  }

  /// 현재 페이지를 종료하는 함수
  void _terminateScreen() {
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, true);
        return false;
      },
      child: Scaffold(
        appBar: ThemeAppBar(
            barTitle: '예약 정보 [${widget.data!['oID']}]',
            leadingClick: () => Navigator.pop(context, true)),
        body: Padding(
          padding: EdgeInsets.all(size.width * 0.02),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Divider(
                        thickness: 10,
                      ),
                      SizedBox(
                        height: size.height * 0.015,
                      ),
                      Text('예약 번호 ${widget.data!['oID']}',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(
                        height: size.height * 0.015,
                      ),
                      Text('예약 일자  ${_formatDate(widget.data!['oDate'])}',
                          style: TextStyle(color: Colors.grey, fontSize: 13)),
                      SizedBox(
                        height: size.height * 0.015,
                      ),
                      Row(
                        children: [
                          Text('예약 상태  ',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(
                            '[${int.parse(widget.data!['resvState']) == 1 ? '예약 중' : (int.parse(widget.data!['orderState']) == 3 && int.parse(widget.data!['resvState']) == 2) ? '수령 완료' : '수령 준비'}]',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: int.parse(widget.data!['resvState']) == 1
                                    ? Colors.deepOrangeAccent
                                    : (int.parse(widget.data!['orderState']) ==
                                                3 &&
                                            int.parse(widget
                                                    .data!['resvState']) ==
                                                2)
                                        ? Colors.lightGreen
                                        : Colors.blueAccent),
                          )
                        ],
                      ),
                      SizedBox(
                        height: size.height * 0.015,
                      ),
                      Row(
                        children: [
                          Text('결제 상태  ',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(
                              '[${int.parse(widget.data!['orderState']) == 0 ? '미결제' : '결제 완료'}]',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color:
                                    int.parse(widget.data!['orderState']) == 0
                                        ? Colors.redAccent
                                        : Colors.teal,
                              ))
                        ],
                      ),
                      SizedBox(
                        height: size.height * 0.01,
                      ),
                      Divider(
                        thickness: 0.5,
                      ),
                      Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                '예약 중',
                                style: TextStyle(
                                    color: Colors.deepOrangeAccent,
                                    fontSize: 11),
                              ),
                              Text(': 현재 상품에 대해 예약 등록하신 상태입니다. ',
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 11))
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '수령 준비',
                                style: TextStyle(
                                    color: Colors.blueAccent, fontSize: 11),
                              ),
                              Expanded(
                                child: Text(
                                  ': 예약한 상품이 입고하여, 완료 처리 기준을 통해 예약하신 상품 수령 가능한 상태입니다.',
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 11),
                                  overflow: TextOverflow.clip,
                                ),
                              )
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                '수령 완료',
                                style: TextStyle(
                                    color: Colors.lightGreen, fontSize: 11),
                              ),
                              Text(': 예약한 상품을 수령하신 상태입니다. ',
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 11))
                            ],
                          ),
                        ],
                      ),
                      Divider(
                        thickness: 0.5,
                      ),
                      SizedBox(
                        height: size.height * 0.015,
                      ),
                      Text('예약 인증 QR 코드',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(
                        height: size.height * 0.015,
                      ),
                      (int.parse(widget.data!['orderState']) == 3 &&
                              int.parse(widget.data!['resvState']) == 2)
                          ? Center(
                              child: Padding(
                                padding: EdgeInsets.all(size.width * 0.01),
                                child: Text(
                                  '이미 상품을 수령하셨기 때문에 QR 코드가 만료되었습니다.',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.redAccent),
                                ),
                              ),
                            )
                          : (int.parse(widget.data!['orderState']) == 0)
                              ? Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(size.width * 0.01),
                                    child: Text(
                                      '아직 결제되지 않은 상태입니다. \n\n 결제하시면, 관리자가 확인 후 "결제완료" 상태로 전환됩니다. ',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.redAccent),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                )
                              : Center(
                                  child: QrImage(
                                  data: widget.data!['oID'],
                                  size: 250,
                                )),
                      Divider(
                        thickness: 0.5,
                      ),
                      SizedBox(
                        height: size.height * 0.015,
                      ),
                      Text(
                        '*예약 상품',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      SizedBox(
                        height: size.height * 0.01,
                      ),
                      Container(
                        padding: EdgeInsets.all(size.width * 0.02),
                        width: size.width,
                        height: size.height * 0.1,
                        margin: EdgeInsets.all(6),
                        decoration: BoxDecoration(
                            border: Border.all(width: 0.8, color: Colors.grey),
                            borderRadius: BorderRadius.circular(10)),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Wrap(
                              spacing: 0.05,
                              children: [
                                Text(
                                  '${widget.data!['detail'][0]['pInfo']['pName']}',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14),
                                ),
                                Text(
                                    ' [${Category.categoryIndexToStringMap[int.parse(widget.data!['detail'][0]['pInfo']['category'])]}]',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14)),
                                Text(
                                    ' ${widget.data!['detail'][0]['quantity']}개',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14))
                              ],
                            ),
                            Row(
                              children: [
                                Text(
                                  '정가 ${_formatPrice(int.parse(widget.data!['detail'][0]['pInfo']['price']))}원',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                SizedBox(
                                  width: size.width * 0.05,
                                ),
                                Text(
                                    '(총 금액 ${_formatPrice(int.parse(widget.data!['totalPrice']))}원)',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold))
                              ],
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(size.width * 0.01),
                        child: Text(
                          '* 총 금액에는 할인된 금액이 포함되어있습니다.',
                          style: TextStyle(color: Colors.grey, fontSize: 10),
                        ),
                      ),
                      SizedBox(
                        height: size.height * 0.01,
                      ),
                      Divider(
                        thickness: 1,
                      ),
                      SizedBox(
                        height: size.height * 0.01,
                      ),
                      Text(
                        '*요청사항 및 상품 옵션',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      SizedBox(
                        height: size.height * 0.01,
                      ),
                      Container(
                        padding: EdgeInsets.all(size.width * 0.03),
                        width: size.width * 0.95,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border:
                                Border.all(width: 0.5, color: Colors.black)),
                        child: Text(
                          '${widget.data!['options'] == null || widget.data!['options'] == '' ? 'X' : widget.data!['options']}',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(
                        height: size.height * 0.02,
                      ),
                      Divider(
                        thickness: 1,
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('* 상품이 입고한 뒤, ',
                              style: TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.bold)),
                          GestureDetector(
                            onTap: () {
                              showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                        title: Text('예약 완료 처리 기준'),
                                        content: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.all(
                                                  size.width * 0.02),
                                              child: Text(
                                                  '* 예약 완료 처리에 대한 기준은 입고한 총 수량에 따릅니다.'),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.all(
                                                  size.width * 0.02),
                                              child: Text(
                                                  '* 총 수량에서 최대한 많은 사람이 완료 처리가 되도록 할당합니다. '),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.all(
                                                  size.width * 0.02),
                                              child: Text(
                                                  '* 총 수량에서 각 예약자들의 예약 수량에 따라 완료 처리될 사람들을 우선적으로 선별합니다. '),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.all(
                                                  size.width * 0.02),
                                              child: Text(
                                                  '* 선별된 사람들은 선별된 사람들끼리 예약한 순서대로 처리됩니다.'),
                                            ),
                                          ],
                                        ),
                                        actions: [
                                          DefaultButtonComp(
                                              onPressed: () =>
                                                  Navigator.pop(context),
                                              child: Text('확인'))
                                        ],
                                      ));
                            },
                            child: Text(
                              '완료 처리 기준',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.lightBlue,
                                  decoration: TextDecoration.underline,
                                  fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '에 따라 본인이 해당되면 알람 메세지가 전송됩니다.',
                        style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: size.height * 0.02,
                      ),
                      Text('* 알람 메세지가 전송되는 동시에',
                          style: TextStyle(
                              fontSize: 13, fontWeight: FontWeight.bold)),
                      Row(
                        children: [
                          Text(
                            '예약 상태는 자동으로',
                            style: TextStyle(
                                fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            ' [수령 준비] ',
                            style: TextStyle(
                                color: Colors.blueAccent,
                                fontWeight: FontWeight.bold),
                          ),
                          Text('로 전환이 됩니다. ',
                              style: TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.bold))
                        ],
                      ),
                      SizedBox(
                        height: size.height * 0.01,
                      )
                    ],
                  ),
                ),
              ),
              int.parse(widget.data!['orderState']) == 0
                  ? DefaultButtonComp(
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                                  title: Text('예약 취소하기'),
                                  content: Text(
                                    '정말로 예약을 취소하시겠습니까?',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  actions: [
                                    DefaultButtonComp(
                                        onPressed: () async {
                                          var res = await _cancelReservation();
                                          if (res) {
                                            var r =
                                                await _updateReservationCurrentCount();
                                            if (r) {
                                              Fluttertoast.showToast(
                                                  msg: '성공적으로 예약 취소가 완료되었습니다.');
                                            } else {
                                              Fluttertoast.showToast(
                                                  msg: '[Error] 예약 수량 업데이트 실패');
                                            }
                                          } else {
                                            Fluttertoast.showToast(
                                                msg: '예약 취소에 실패하였습니다!');
                                          }
                                          Navigator.pop(context);
                                          _terminateScreen();
                                        },
                                        child: Text(
                                          '예',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.blueAccent),
                                        )),
                                    DefaultButtonComp(
                                        onPressed: () => Navigator.pop(context),
                                        child: Text(
                                          '아니오',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.red),
                                        ))
                                  ],
                                ));
                      },
                      child: Container(
                        padding: EdgeInsets.all(size.width * 0.01),
                        alignment: Alignment.center,
                        child: Text(
                          '예약 취소하기',
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        width: size.width * 0.9,
                        height: size.height * 0.05,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(width: 1, color: Colors.black),
                            color: Colors.redAccent),
                      ),
                    )
                  : SizedBox()
            ],
          ),
        ),
      ),
    );
  }
}
