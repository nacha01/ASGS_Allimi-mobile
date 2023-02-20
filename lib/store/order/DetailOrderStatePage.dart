import 'package:asgshighschool/component/ThemeAppBar.dart';
import 'package:asgshighschool/data/order/order.dart';
import 'package:asgshighschool/data/order/order_product.dart';
import 'package:asgshighschool/data/user.dart';
import 'package:asgshighschool/util/DateFormatter.dart';
import 'package:asgshighschool/util/NumberFormatter.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class DetailOrderStatePage extends StatefulWidget {
  DetailOrderStatePage({required this.order, this.user});

  final Order order;
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
              SizedBox(
                height: size.height * 0.015,
              ),
              Text(
                '주문 번호  ${widget.order.orderID}',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: size.height * 0.015,
              ),
              Text('주문일자  ${DateFormatter.formatDate(widget.order.orderDate)}',
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
                    '[ ${_getTextAccordingToOrderState(widget.order.orderState)} ]',
                    style: TextStyle(
                        color: _getColorAccordingToOrderState(
                            widget.order.orderState)),
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
              widget.order.orderState == 3 || widget.order.orderState == 4
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          widget.order.orderState == 3
                              ? '이미 수령하셨기 때문에 만료되었습니다.'
                              : widget.order.orderState == 4
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
                      data: widget.order.orderID,
                      size: 200,
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
                    '[ ${widget.order.receiveMethod == 0 ? '직접 수령' : '배달'} ]',
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
                  Text(' [ ${widget.order.payMethod == 0 ? '신용카드' : '간편결제'} ]')
                ],
              ),
              SizedBox(
                height: size.height * 0.015,
              ),
              Text('요청 사항', style: TextStyle(fontWeight: FontWeight.bold)),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                    '${widget.order.options.trim() == '' ? 'X' : widget.order.options}'),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(size.width * 0.04),
                      child: Text(
                        '최종 결제 금액 ${NumberFormatter.formatPrice(widget.order.totalPrice)}원',
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

  Widget _productItemLayout(OrderProduct product, int quantity, Size size) {
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
                  '${product.name}',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                Text(
                  ' [${product.category}] ',
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
                '정가 ${NumberFormatter.formatPrice(product.price)}원',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(
                width: size.width * 0.03,
              ),
              product.discount == null
                  ? SizedBox()
                  : Text(
                      '[ ${product.discount}% 할인 ]',
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
    for (int i = 0; i < widget.order.detail.length; ++i) {
      list.add(_productItemLayout(widget.order.detail[i].product,
          widget.order.detail[i].quantity, size));
    }
    return list;
  }
}
