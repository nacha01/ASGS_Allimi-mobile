import 'package:asgshighschool/component/ThemeAppBar.dart';
import 'package:asgshighschool/data/category.dart';
import 'package:asgshighschool/data/user.dart';
import 'package:asgshighschool/util/NumberFormatter.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class DetailOrderStatePage extends StatefulWidget {
  DetailOrderStatePage({this.order, this.user});

  final Map? order;
  final User? user;

  @override
  _DetailOrderStatePageState createState() => _DetailOrderStatePageState();
}

class _DetailOrderStatePageState extends State<DetailOrderStatePage> {
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
      case 4:
        return '결제취소 및 주문취소';
      default:
        return 'Error';
    }
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
      case 4:
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

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

  /// 이 주문에 포함된 상품들의 원가격에 대한 총 가격을 구하는 작업
  int _getOriginTotalPrice() {
    int sum = 0;
    for (int i = 0; i < widget.order!['detail'].length; ++i) {
      sum += int.parse(widget.order!['detail'][i]['pInfo']['price']) *
          int.parse(widget.order!['detail'][i]['quantity']);
    }
    return sum;
  }

  /// 이 주문에 포함된 상품들의 총 할인 가격을 구하는 작업
  int _getTotalDiscount() {
    int sum = 0;
    for (int i = 0; i < widget.order!['detail'].length; ++i) {
      sum += ((int.parse(widget.order!['detail'][i]['pInfo']['price']) *
                  (double.parse(widget.order!['detail'][i]['pInfo']['discount'])
                              .toString() ==
                          '0.0'
                      ? 0
                      : double.parse(
                              widget.order!['detail'][i]['pInfo']['discount']) /
                          100)) *
              int.parse(widget.order!['detail'][i]['quantity']))
          .round();
    }
    return sum;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: ThemeAppBar(barTitle: '상세 주문 내역'),
      body: Padding(
        padding: EdgeInsets.all(size.width * 0.02),
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
                '주문 번호  ${widget.order!['oID']}',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: size.height * 0.015,
              ),
              Text('주문일자  ${_formatDate(widget.order!['oDate'])}',
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
                    '[ ${_getTextAccordingToOrderState(int.parse(widget.order!['orderState']))} ]',
                    style: TextStyle(
                        color: _getColorAccordingToOrderState(
                            int.parse(widget.order!['orderState']))),
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
                        '주문 처리 중',
                        style: TextStyle(color: Colors.lightBlue, fontSize: 9),
                      ),
                      Text(': 주문이 확인되고, 상품 수령 준비 및 수령 중인 상태입니다. ',
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
                      Text(': 결제가 완료된 상태이며 상품을 수령한 상태입니다.',
                          style: TextStyle(color: Colors.grey, fontSize: 9))
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        '결제취소 및 주문취소',
                        style: TextStyle(color: Colors.grey, fontSize: 9),
                      ),
                      Text(': 결제가 취소된 상태이며, 주문도 취소한 상태입니다.',
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
              Text('주문 인증 QR코드', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(
                height: size.height * 0.015,
              ),
              int.parse(widget.order!['orderState']) == 3 ||
                      int.parse(widget.order!['orderState']) == 4
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          int.parse(widget.order!['orderState']) == 3
                              ? '이미 수령하셨기 때문에 만료되었습니다.'
                              : int.parse(widget.order!['orderState']) == 4
                                  ? '결제 취소 및 주문이 취소되었습니다.'
                                  : '',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.redAccent),
                        ),
                      ),
                    )
                  : Center(
                      child: QrImage(
                      data: widget.order!['oID'],
                      size: 250,
                    )),
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
                    '[ ${int.parse(widget.order!['receiveMethod']) == 0 ? '직접 수령' : '배달'} ]',
                    style: TextStyle(
                        color: Colors.indigo, fontWeight: FontWeight.bold),
                  )
                ],
              ),
              int.parse(widget.order!['receiveMethod']) == 1
                  ? Padding(
                      padding: EdgeInsets.all(size.width * 0.04),
                      child: Text(
                        '장소 : ${widget.order!['location'] == null ? '' : widget.order!['location']}',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                            color: Colors.red),
                      ),
                    )
                  : SizedBox(),
              SizedBox(
                height: size.height * 0.015,
              ),
              Row(
                children: [
                  Text('결제 방식 ', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(
                      ' [ ${widget.order!['payMethod'] == '0' ? '신용카드' : '간편결제'} ]')
                ],
              ),
              SizedBox(
                height: size.height * 0.015,
              ),
              Text('요청 사항', style: TextStyle(fontWeight: FontWeight.bold)),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                    '${widget.order!['options'].toString().trim() == '' ? 'X' : widget.order!['options']}'),
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
              /*
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

               */
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(size.width * 0.04),
                      child: Text(
                        '최종 결제 금액 ${NumberFormatter.formatNumber(int.parse(widget.order!['totalPrice']))}원',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ),
                ],
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
      padding: EdgeInsets.all(size.width * 0.03),
      width: size.width,
      margin: EdgeInsets.all(size.width * 0.01),
      decoration: BoxDecoration(
          border: Border.all(width: 0.8, color: Colors.grey),
          borderRadius: BorderRadius.circular(10)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: Wrap(
              children: [
                Text(
                  '${productMap['pName']}',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                Text(
                  ' [${Category.categoryIndexToStringMap[int.parse(productMap['category'])]}] ',
                  style: TextStyle(color: Colors.grey),
                ),
                Text(' $quantity개')
              ],
            ),
          ),
          SizedBox(
            height: size.height * 0.01,
          ),
          Row(
            children: [
              Text(
                '정가 ${NumberFormatter.formatNumber(int.parse(productMap['price']))}원',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(
                width: size.width * 0.03,
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
    for (int i = 0; i < widget.order!['detail'].length; ++i) {
      list.add(_productItemLayout(widget.order!['detail'][i]['pInfo'],
          int.parse(widget.order!['detail'][i]['quantity']), size));
    }
    return list;
  }
}
