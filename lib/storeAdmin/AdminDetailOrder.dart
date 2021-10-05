import 'dart:ui';

import 'package:asgshighschool/data/user_data.dart';
import 'package:asgshighschool/storeAdmin/QRScannerPage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

class AdminDetailOrder extends StatefulWidget {
  AdminDetailOrder({this.data, this.user});
  final Map data;
  final User user;
  @override
  _AdminDetailOrderState createState() => _AdminDetailOrderState();
}

class _AdminDetailOrderState extends State<AdminDetailOrder> {
  final _categoryReverseMap = {
    0: '음식류',
    1: '간식류',
    2: '음료류',
    3: '문구류',
    4: '핸드메이드'
  };
  bool _isCharged = false;
  int _state = 1;

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

  /// date 필드를 사용자에게 직관적으로 보여주기 위한 formatting 작업
  /// yyyy-mm-dd hh:mm:ss → yyyy년 MM월 dd일 hh시 mm분
  String _formatDate(String date) {
    var split = date.split(' ');

    var leftSp = split[0].split('-');
    String left = leftSp[0] + '년 ' + leftSp[1] + '월 ' + leftSp[2] + '일 ';

    var rightSp = split[1].split(':');
    String right = rightSp[0] + '시 ' + leftSp[1] + '분';

    return left + right;
  }

  /// 현재 관리자 user가 이 주문을 맡겠다는 요청 작업
  /// chargerID 필드 업데이트 및 orderState 필드 업데이트
  Future<bool> _chargeOrderRequest() async {
    String url = 'http://nacha01.dothome.co.kr/sin/arlimi_chargeOrder.php';
    final response = await http.post(url, body: <String, String>{
      'uid': widget.user.uid,
      'oid': widget.data['oID']
    });

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  @override
  void initState() {
    _isCharged = (int.parse(widget.data['orderState']) == 3 ||
            int.parse(widget.data['orderState']) == 2)
        ? true
        : false;
    _state = int.parse(widget.data['orderState']);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, true);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xFF9EE1E5),
          title: Text(
            '주문 [${widget.data['oID']}]',
            style: TextStyle(
                color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15),
          ),
          centerTitle: true,
          leading: IconButton(
              onPressed: () => Navigator.pop(context, true),
              icon: Icon(
                Icons.arrow_back,
                color: Colors.black,
              )),
        ),
        floatingActionButton: _isCharged
            ? _state == 3
                ? null
                : FloatingActionButton(
                    child: Icon(Icons.qr_code_scanner),
                    onPressed: () async {
                      var res = await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => QRScannerPage(
                                    oID: widget.data['oID'],
                                  )));
                      if (res) Navigator.pop(context, true);
                    },
                  )
            : null,
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: size.height * 0.015,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _aboveStateAccordingToOrderState(_state),
                  ],
                ),
                SizedBox(
                  height: size.height * 0.01,
                ),
                Divider(
                  thickness: 1,
                ),
                Text(
                  '주문자 ID  ${widget.data['uID']}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: size.height * 0.015,
                ),
                Text(
                  '주문 번호  ${widget.data['oID']}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: size.height * 0.015,
                ),
                Row(
                  children: [
                    Text('주문일자  ${_formatDate(widget.data['oDate'])}',
                        style: TextStyle(color: Colors.grey, fontSize: 13)),
                    Text(
                      ' (${_formatDateTimeForToday(widget.data['oDate'])})',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.deepOrange),
                    )
                  ],
                ),
                SizedBox(
                  height: size.height * 0.015,
                ),
                Row(
                  children: [
                    Text(
                      '수령 방식  ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '[ ${int.parse(widget.data['receiveMethod']) == 0 ? '직접 수령' : '배달'} ]',
                      style: TextStyle(
                          color: Colors.indigo, fontWeight: FontWeight.bold),
                    )
                  ],
                ),
                SizedBox(
                  height: size.height * 0.015,
                ),
                Row(
                  children: [
                    Text('결제 방식 ',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(' [ ${widget.data['payMethod']} ]')
                  ],
                ),
                SizedBox(
                  height: size.height * 0.015,
                ),
                Text('요청 사항', style: TextStyle(fontWeight: FontWeight.bold)),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                      '${widget.data['options'] == '' ? 'X' : widget.data['options']}'),
                ),
                Divider(
                  thickness: 6,
                ),
                SizedBox(
                  height: size.height * 0.01,
                ),
                Text(
                  '주문한 상품 목록들',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
                SizedBox(
                  height: size.height * 0.015,
                ),
                Column(
                  children: _item(widget.data['detail'], size),
                ),
                Divider(
                  thickness: 6,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Card(
                      child: Container(
                        alignment: Alignment.center,
                        padding: EdgeInsets.all(size.width * 0.02),
                        child: Text(
                          '총 결제 금액  ${_formatPrice(int.parse(widget.data['totalPrice']))}원',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 19),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: size.height * 0.01,
                ),
                Divider(
                  thickness: 1,
                ),
                !_isCharged
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FlatButton(
                            onPressed: () async {
                              var res = await _chargeOrderRequest();
                              if (res) {
                                Fluttertoast.showToast(
                                    msg: '주문 번호 ${widget.data['oID']} 담당 완료 ',
                                    gravity: ToastGravity.BOTTOM,
                                    toastLength: Toast.LENGTH_SHORT);
                                setState(() {
                                  _isCharged = true;
                                  _state = 2;
                                });
                              } else {
                                Fluttertoast.showToast(
                                    msg: '문제가 발생하였습니다.',
                                    gravity: ToastGravity.BOTTOM,
                                    toastLength: Toast.LENGTH_SHORT);
                              }
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: Colors.blue),
                              alignment: Alignment.center,
                              width: size.width * 0.8,
                              height: size.height * 0.04,
                              child: Text(
                                '주문 처리 담당하기',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      )
                    : SizedBox()
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _aboveStateAccordingToOrderState(int state) {
    switch (state) {
      case 0:
        return Text(
          '아직 결제 되지 않은 상태입니다. ',
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 15, color: Colors.red),
        );
      case 1:
        return Text('아직 주문 처리가 되지 않았습니다. ',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: Colors.orange));
      case 2:
        return Row(
          children: [
            Text('현재 ',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.lightBlue)),
            Text(
                '${widget.data['chargerID'] == null ? widget.user.uid : widget.data['chargerID']}',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.red)),
            Text('님께서 처리 담당 중입니다.',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.lightBlue)),
          ],
        );
      case 3:
        return Column(
          children: [
            Text('이미 주문 처리가 완료된 주문입니다. ',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.green)),
            SizedBox(
              height: 5,
            ),
            Text(
              '담당자 ID  : ${widget.data['chargerID']}',
              style: TextStyle(fontWeight: FontWeight.bold),
            )
          ],
        );
      default:
        return SizedBox();
    }
  }

  Widget _detailItemTile(String name, int category, int price, double discount,
      int quantity, Size size) {
    return Container(
      margin: EdgeInsets.all(size.width * 0.015),
      padding: EdgeInsets.all(size.width * 0.03),
      width: size.width,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(width: 2, color: Colors.grey)),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                '[${_categoryReverseMap[category]}] ',
                style: TextStyle(
                  color: Colors.black54,
                ),
              ),
              Text(
                name,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              Text(
                ' $quantity개',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.deepOrange,
                    fontSize: 15),
              )
            ],
          ),
          SizedBox(
            height: size.height * 0.01,
          ),
          Row(
            children: [
              Text(
                '정가 ${_formatPrice(price)}원',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              discount.toString() == '0.0'
                  ? SizedBox()
                  : Text(
                      ' [$discount% 할인]',
                      style: TextStyle(color: Colors.black38),
                    )
            ],
          )
        ],
      ),
    );
  }

  List<Widget> _item(List list, Size size) {
    List<Widget> w = [];
    for (int index = 0; index < list.length; ++index) {
      w.add(_detailItemTile(
          list[index]['pInfo']['pName'],
          int.parse(list[index]['pInfo']['category']),
          int.parse(list[index]['pInfo']['price']),
          double.parse(list[index]['pInfo']['discount']),
          int.parse(list[index]['quantity']),
          size));
    }
    return w;
  }
}
