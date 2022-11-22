import 'dart:ui';

import 'package:asgshighschool/data/category_data.dart';
import 'package:asgshighschool/data/orderState_data.dart';
import 'package:asgshighschool/data/status_data.dart';
import 'package:asgshighschool/data/user_data.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

class ScanInfoPage extends StatefulWidget {
  final Map orderData;
  final User user;
  final User admin;

  ScanInfoPage({this.orderData, this.user, this.admin});

  @override
  _ScanInfoPageState createState() => _ScanInfoPageState();
}

class _ScanInfoPageState extends State<ScanInfoPage> {
  @override
  void initState() {
    super.initState();
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

  Future<bool> _orderCompleteRequest() async {
    String url = 'http://nacha01.dothome.co.kr/sin/arlimi_completeOrder.php';
    final response = await http.get(url + '?oid=${widget.orderData['oID']}');

    if (response.statusCode == 200) {
      print(response.body);
      await _updateCharger();
      return true;
    } else {
      return false;
    }
  }

  Future<bool> _updateCharger() async {
    String url = 'http://nacha01.dothome.co.kr/sin/arlimi_updateCharger.php';
    final response = await http.post(url, body: <String, String>{
      'charger_id': widget.admin.uid,
      'oid': widget.orderData['oID']
    });
    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  void _terminateScreen() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF9EE1E5),
        title: Text(
          '주문 QR 코드 조회 결과',
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15),
        ),
        centerTitle: true,
        leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.arrow_back,
              color: Colors.black,
            )),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(size.width * 0.015),
              child: Text(
                '주문자 정보',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.grey),
              ),
            ),
            Card(
              child: Container(
                padding: EdgeInsets.all(size.width * 0.03),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.all(size.width * 0.01),
                          child: Text(
                            'ID:  ${widget.user.uid}',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(size.width * 0.01),
                          child: Text('이름:  ${widget.user.name}',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        Padding(
                          padding: EdgeInsets.all(size.width * 0.01),
                          child: Text(
                              '신분:  ${Status.statusList[widget.user.identity - 1]}',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        Padding(
                          padding: EdgeInsets.all(size.width * 0.01),
                          child: Text(
                              '학번:  ${widget.user.studentId == null || widget.user.studentId == '' ? 'X' : widget.user.studentId}',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        Padding(
                          padding: EdgeInsets.all(size.width * 0.01),
                          child: Text('닉네임:  ${widget.user.nickName}',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        Padding(
                          padding: EdgeInsets.all(size.width * 0.01),
                          child: Text('이메일:  ${widget.user.email}',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(size.width * 0.015),
              child: Text(
                '주문 정보',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.grey),
              ),
            ),
            Card(
              child: Container(
                padding: EdgeInsets.all(size.width * 0.03),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(size.width * 0.01),
                      child: Text('주문번호:  ${widget.orderData['oID']}',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Padding(
                      padding: EdgeInsets.all(size.width * 0.01),
                      child: Text('주문 일자:  ${widget.orderData['oDate']}',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Padding(
                      padding: EdgeInsets.all(size.width * 0.01),
                      child: Text(
                          '주문 완료 일자:  ${widget.orderData['eDate'] == '0000-00-00 00:00:00' ? '-' : widget.orderData['eDate']}',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Padding(
                      padding: EdgeInsets.all(size.width * 0.01),
                      child: Text(
                          '결제 금액:  ${_formatPrice(int.parse(widget.orderData['totalPrice']))}원',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Padding(
                      padding: EdgeInsets.all(size.width * 0.01),
                      child: Row(
                        children: [
                          Text('주문 상태:  ',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(
                            '${OrderState.orderStateList[int.parse(widget.orderData['orderState'])]}',
                            style: TextStyle(
                                color: OrderState.colorState[
                                    int.parse(widget.orderData['orderState'])]),
                          )
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(size.width * 0.01),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Wrap(
                          runSpacing: 5,
                          children: [
                            Text('요청 사항:  ',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            Text(
                                '${widget.orderData['options'] == null || widget.orderData['options'].toString().trim() == '' ? 'X' : widget.orderData['options']}')
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(size.width * 0.015),
              child: Text(
                '상품 목록',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.grey),
              ),
            ),
            Column(
              children: _item(widget.orderData['detail'], size),
            ),
            Divider(
              thickness: 2,
            ),
            int.parse(widget.orderData['orderState']) == 3 ||
                    int.parse(widget.orderData['orderState']) == 4
                ? Container(
                    color: Colors.red,
                    padding: EdgeInsets.all(size.width * 0.015),
                    alignment: Alignment.center,
                    width: size.width,
                    child: Text(
                      int.parse(widget.orderData['orderState']) == 3
                          ? '이미 수령 완료된 주문입니다.'
                          : int.parse(widget.orderData['orderState']) == 4
                              ? '결제가 취소된 주문입니다.'
                              : '',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 12),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                          onPressed: () async {
                            await showDialog(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                      actions: [
                                        TextButton(
                                            onPressed: () async {
                                              var res =
                                                  await _orderCompleteRequest();
                                              if (res) {
                                                Fluttertoast.showToast(
                                                    msg:
                                                        '성공적으로 주문 완료 처리 되었습니다.',
                                                    gravity:
                                                        ToastGravity.BOTTOM,
                                                    toastLength:
                                                        Toast.LENGTH_SHORT);
                                                _terminateScreen();
                                              } else {
                                                Fluttertoast.showToast(
                                                    msg: '주문 완료 처리에 실패하였습니다.',
                                                    gravity:
                                                        ToastGravity.BOTTOM,
                                                    toastLength:
                                                        Toast.LENGTH_SHORT);
                                              }
                                              Navigator.pop(ctx);
                                            },
                                            child: Text('예')),
                                        TextButton(
                                            onPressed: () => Navigator.pop(ctx),
                                            child: Text('아니오'))
                                      ],
                                      title: Icon(
                                        Icons.warning,
                                        size: 60,
                                        color: Colors.red,
                                      ),
                                      content: Text(
                                        '※ 정말 상품 수령이 완료되었고, 주문 완료 처리될 상태가 맞습니까?',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13),
                                      ),
                                    ));
                          },
                          child: Container(
                            width: size.width * 0.9,
                            padding: EdgeInsets.all(size.width * 0.015),
                            alignment: Alignment.center,
                            child: Text(
                              '주문 완료 처리하기',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12),
                            ),
                            decoration: BoxDecoration(
                                color: Colors.blue,
                                border: Border.all(width: 1),
                                borderRadius: BorderRadius.circular(8)),
                          )),
                    ],
                  )
          ],
        ),
      ),
    );
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
          Align(
            alignment: Alignment.topLeft,
            child: Wrap(
              children: [
                Text(
                  '[${Category.categoryIndexToStringMap[category]}] ',
                  style: TextStyle(
                    color: Colors.black54,
                  ),
                ),
                Text(
                  name,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                Text(
                  '  $quantity개',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.deepOrange,
                      fontSize: 15),
                )
              ],
            ),
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
