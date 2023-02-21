import 'package:asgshighschool/data/order/order_detail.dart';
import 'package:asgshighschool/data/order/order_state.dart';
import 'package:asgshighschool/data/order/order_user.dart';
import 'package:asgshighschool/data/status.dart';
import 'package:asgshighschool/data/user.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../api/ApiUtil.dart';
import '../../component/DefaultButtonComp.dart';
import '../../component/ThemeAppBar.dart';
import '../../data/order/order.dart';
import '../../util/NumberFormatter.dart';
import '../../util/ToastMessage.dart';

class ScanInfoPage extends StatefulWidget {
  final Order orderData;
  final OrderUser? user;
  final User? admin;

  ScanInfoPage({required this.orderData, this.user, this.admin});

  @override
  _ScanInfoPageState createState() => _ScanInfoPageState();
}

class _ScanInfoPageState extends State<ScanInfoPage> {
  Future<bool> _orderCompleteRequest() async {
    String url = '${ApiUtil.API_HOST}arlimi_completeOrder.php';
    final response =
        await http.get(Uri.parse(url + '?oid=${widget.orderData.orderID}'));

    if (response.statusCode == 200) {
      await _updateCharger();
      return true;
    } else {
      return false;
    }
  }

  Future<bool> _updateCharger() async {
    String url = '${ApiUtil.API_HOST}arlimi_updateCharger.php';
    final response = await http.post(Uri.parse(url), body: <String, String?>{
      'charger_id': widget.admin!.uid,
      'oid': widget.orderData.orderID
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
      appBar: ThemeAppBar(barTitle: '주문 QR 코드 조회 결과'),
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
                            'ID:  ${widget.user!.userID}',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(size.width * 0.01),
                          child: Text('이름:  ${widget.user!.name}',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        Padding(
                          padding: EdgeInsets.all(size.width * 0.01),
                          child: Text(
                              '신분:  ${Status.statusList[widget.user!.identity - 1]}',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        Padding(
                          padding: EdgeInsets.all(size.width * 0.01),
                          child: Text(
                              '학번:  ${widget.user!.studentID == null || widget.user!.studentID == '' ? 'X' : widget.user!.studentID}',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        Padding(
                          padding: EdgeInsets.all(size.width * 0.01),
                          child: Text('닉네임:  ${widget.user!.nickname}',
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
                      child: Text('주문번호:  ${widget.orderData.orderID}',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Padding(
                      padding: EdgeInsets.all(size.width * 0.01),
                      child: Text('주문 일자:  ${widget.orderData.orderDate}',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Padding(
                      padding: EdgeInsets.all(size.width * 0.01),
                      child: Text(
                          '주문 완료 일자:  ${widget.orderData.editDate == '0000-00-00 00:00:00' ? '-' : widget.orderData.editDate}',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Padding(
                      padding: EdgeInsets.all(size.width * 0.01),
                      child: Text(
                          '결제 금액:  ${NumberFormatter.formatPrice(widget.orderData.totalPrice)}원',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Padding(
                      padding: EdgeInsets.all(size.width * 0.01),
                      child: Row(
                        children: [
                          Text('주문 상태:  ',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(
                            '${OrderState.orderStateList[widget.orderData.orderState]}',
                            style: TextStyle(
                                color: OrderState
                                    .colorState[widget.orderData.orderState]),
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
                                '${widget.orderData.options.trim() == '' ? 'X' : widget.orderData.options}')
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
              children: _item(widget.orderData.detail, size),
            ),
            Divider(
              thickness: 2,
            ),
            widget.orderData.orderState == 3 || widget.orderData.orderState == 4
                ? Container(
                    color: Colors.red,
                    padding: EdgeInsets.all(size.width * 0.015),
                    alignment: Alignment.center,
                    width: size.width,
                    child: Text(
                      widget.orderData.orderState == 3
                          ? '이미 수령 완료된 주문입니다.'
                          : widget.orderData.orderState == 4
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
                      DefaultButtonComp(
                          onPressed: () async {
                            await showDialog(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                      actions: [
                                        DefaultButtonComp(
                                            onPressed: () async {
                                              var res =
                                                  await _orderCompleteRequest();
                                              if (res) {
                                                ToastMessage.show(
                                                    '주문 완료 처리되었습니다.');
                                                _terminateScreen();
                                              } else {
                                                ToastMessage.show(
                                                    '주문 완료 처리에 실패했습니다.');
                                              }
                                              Navigator.pop(ctx);
                                            },
                                            child: Text('예')),
                                        DefaultButtonComp(
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

  Widget _detailItemTile(String name, String category, int price,
      double? discount, int quantity, Size size) {
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
                  '[$category] ',
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
                '정가 ${NumberFormatter.formatPrice(price)}원',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              discount == null
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

  List<Widget> _item(List<OrderDetail> list, Size size) {
    List<Widget> w = [];
    for (int i = 0; i < list.length; ++i) {
      w.add(_detailItemTile(
          list[i].product.name,
          list[i].product.category,
          list[i].product.price,
          list[i].product.discount,
          list[i].quantity,
          size));
    }
    return w;
  }
}
