import 'dart:ui';

import 'package:asgshighschool/data/user_data.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DetailOrderStatePage extends StatefulWidget {
  DetailOrderStatePage({this.order, this.user});
  final Map order;
  final User user;
  @override
  _DetailOrderStatePageState createState() => _DetailOrderStatePageState();
}

class _DetailOrderStatePageState extends State<DetailOrderStatePage> {
  final _categoryReverseMap = {
    0: '음식류',
    1: '간식류',
    2: '음료류',
    3: '문구류',
    4: '핸드메이드'
  };

  String _getTextAccordingToOrderState(int state) {
    switch (state) {
      case 0:
        return '미결제 및 미수령';
      case 1:
        return '결제완료 및 미수령';
      case 2:
        return '결제완료 및 수령완료';
      default:
        return 'Error';
    }
  }

  Color _getColorAccordingToOrderState(int state) {
    switch (state) {
      case 0:
        return Colors.red;
      case 1:
        return Colors.orangeAccent;
      case 2:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

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

  int _getOriginTotalPrice() {
    int sum = 0;
    for (int i = 0; i < widget.order['detail'].length; ++i) {
      sum += int.parse(widget.order['detail'][i]['pInfo']['price']) *
          int.parse(widget.order['detail'][i]['quantity']);
    }
    return sum;
  }

  int _getTotalDiscount() {
    int sum = 0;
    for (int i = 0; i < widget.order['detail'].length; ++i) {
      sum += ((int.parse(widget.order['detail'][i]['pInfo']['price']) *
                  (double.parse(widget.order['detail'][i]['pInfo']['discount'])
                              .toString() ==
                          '0.0'
                      ? 0
                      : double.parse(
                              widget.order['detail'][i]['pInfo']['discount']) /
                          100)) *
              int.parse(widget.order['detail'][i]['quantity']))
          .round();
    }
    return sum;
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
          '상세 주문 현황',
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
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
              Text(
                '주문 번호  ${widget.order['oID']}',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: size.height * 0.015,
              ),
              Text('주문일자  ${_formatDate(widget.order['oDate'])}',
                  style: TextStyle(color: Colors.grey, fontSize: 13)),
              SizedBox(
                height: size.height * 0.015,
              ),
              Row(
                children: [
                  Text(
                    '주문 상태  ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '[ ${_getTextAccordingToOrderState(int.parse(widget.order['orderState']))} ]',
                    style: TextStyle(
                        color: _getColorAccordingToOrderState(
                            int.parse(widget.order['orderState']))),
                  )
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
                        '미결제 및 미수령',
                        style: TextStyle(color: Colors.red, fontSize: 9),
                      ),
                      Text(': 결제완료된 상태가 아니며 상품을 수령하지 않은 상태입니다.',
                          style: TextStyle(color: Colors.grey, fontSize: 9))
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        '결제완료 및 미수령',
                        style:
                            TextStyle(color: Colors.orangeAccent, fontSize: 9),
                      ),
                      Text(': 결제가 완료된 상태이며 아직 상품을 수령하지 않은 상태입니다.',
                          style: TextStyle(color: Colors.grey, fontSize: 9))
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        '결제완료 및 수령완료',
                        style: TextStyle(color: Colors.green, fontSize: 9),
                      ),
                      Text(': 결제가 완료된 상태이며  상품을 수령한 상태입니다.',
                          style: TextStyle(color: Colors.grey, fontSize: 9))
                    ],
                  )
                ],
              ),
              Divider(
                thickness: 0.5,
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
                    '[ ${int.parse(widget.order['receiveMethod']) == 0 ? '직접 수령' : '배달'} ]',
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
                  Text('결제 방식 ', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(' [ ${widget.order['payMethod']} ]')
                ],
              ),
              SizedBox(
                height: size.height * 0.015,
              ),
              Text('요청 사항', style: TextStyle(fontWeight: FontWeight.bold)),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                    '${widget.order['options'] == '' ? 'X' : widget.order['options']}'),
              ),
              Divider(
                thickness: 10,
              ),
              SizedBox(
                height: size.height * 0.01,
              ),
              Text(
                '*세부 상품 목록',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              SizedBox(
                height: size.height * 0.01,
              ),
              Column(
                children: _productLayoutList(size), // 세부 상품 목록 Column
              ),
              SizedBox(
                height: size.height * 0.01,
              ),
              Divider(
                thickness: 10,
              ),
              SizedBox(
                height: size.height * 0.01,
              ),
              Card(
                child: Container(
                  height: size.height * 0.2,
                  padding: EdgeInsets.all(size.width * 0.05),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('원가 총 금액'),
                          Text('${_formatPrice(_getOriginTotalPrice())} 원')
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('총 할인 금액'),
                          Text('- ${_formatPrice(_getTotalDiscount())} 원')
                        ],
                      ),
                      Divider(
                        thickness: 2,
                        indent: 1,
                        endIndent: 1,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '최종 결제 금액',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          Text(
                              '${_formatPrice(_getOriginTotalPrice() - _getTotalDiscount())} 원',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold))
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: size.height * 0.01,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _productItemLayout(Map productMap, int quantity, Size size) {
    return Container(
      padding: EdgeInsets.all(10),
      width: size.width,
      height: size.height * 0.1,
      margin: EdgeInsets.all(6),
      decoration: BoxDecoration(
          border: Border.all(width: 0.8, color: Colors.grey),
          borderRadius: BorderRadius.circular(10)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Row(
            children: [
              Text(
                '${productMap['pName'] + ' [' + _categoryReverseMap[int.parse(productMap['category'])]}]  $quantity개',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ],
          ),
          Row(
            children: [
              Text(
                '정가 ${_formatPrice(int.parse(productMap['price']))}원',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(
                width: size.width * 0.05,
              ),
              double.parse(productMap['discount']).toString() == '0.0'
                  ? SizedBox()
                  : Text(
                      '[ ${double.parse(productMap['discount'])}% 할인 ]',
                      style: TextStyle(color: Colors.grey),
                    )
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _productLayoutList(Size size) {
    List<Widget> list = [];
    for (int i = 0; i < widget.order['detail'].length; ++i) {
      list.add(_productItemLayout(widget.order['detail'][i]['pInfo'],
          int.parse(widget.order['detail'][i]['quantity']), size));
    }
    return list;
  }
}
