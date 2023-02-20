import 'package:asgshighschool/util/DateFormatter.dart';
import '../../api/ApiUtil.dart';
import '../../component/DefaultButtonComp.dart';
import '../../component/ThemeAppBar.dart';
import '../../data/order/order.dart';
import '../../data/order/order_detail.dart';
import '../../data/status.dart';
import '../../data/user.dart';
import '../../util/NumberFormatter.dart';
import '../../util/ToastMessage.dart';
import '../qr/QRScannerPage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AdminDetailOrder extends StatefulWidget {
  AdminDetailOrder({required this.order, this.user});

  final Order order;
  final User? user;

  @override
  _AdminDetailOrderState createState() => _AdminDetailOrderState();
}

class _AdminDetailOrderState extends State<AdminDetailOrder> {
  bool _isCharged = false;
  int _state = 1;

  /// 현재 관리자 user가 이 주문을 맡겠다는 요청 작업
  /// chargerID 필드 업데이트 및 orderState 필드 업데이트
  Future<bool> _chargeOrderRequest() async {
    String url = '${ApiUtil.API_HOST}arlimi_chargeOrder.php';
    final response = await http.post(Uri.parse(url), body: <String, String?>{
      'uid': widget.user!.uid,
      'oid': widget.order.orderID
    });

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  @override
  void initState() {
    _isCharged = (widget.order.orderState == 3 || widget.order.orderState == 2);
    if (widget.order.orderState == 4) {
      _isCharged = true;
    }
    _state = widget.order.orderState;
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
        appBar: ThemeAppBar(
            barTitle: '상세 주문 페이지 [${widget.order.orderID}]',
            leadingClick: () => Navigator.pop(context, true)),
        floatingActionButton: _isCharged
            ? _state == 3 || _state == 4
                ? null
                : FloatingActionButton(
                    child: Icon(Icons.qr_code_scanner),
                    onPressed: () async {
                      var res = await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => QRScannerPage(
                                    oID: widget.order.orderID,
                                  )));
                      if (res) Navigator.pop(context, true);
                    },
                  )
            : null,
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(size.width * 0.02),
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
                  '주문자: [${Status.statusList[widget.order.user!.identity - 1]}] ${widget.order.user!.studentID ?? ''} ${widget.order.user!.name}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
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
                Row(
                  children: [
                    Text(
                        '주문 일자: ${DateFormatter.formatDate(widget.order.orderDate)}',
                        style: TextStyle(color: Colors.grey, fontSize: 13)),
                    Text(
                      ' (${DateFormatter.formatDateTimeCmp(widget.order.orderDate)})',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: Colors.deepOrange),
                    )
                  ],
                ),
                Row(
                  children: [
                    Text(
                        '주문 완료 일자: ${widget.order.editDate == '0000-00-00 00:00:00' ? '-' : DateFormatter.formatDate(widget.order.editDate)}',
                        style: TextStyle(color: Colors.grey, fontSize: 13)),
                    Text(
                        ' (${widget.order.editDate == '0000-00-00 00:00:00' ? '-' : DateFormatter.formatDateTimeCmp(widget.order.editDate)})',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: Colors.deepOrange))
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
                      '[ ${widget.order.receiveMethod == 0 ? '직접 수령' : '배달'} ]',
                      style: TextStyle(
                          color: Colors.lightBlue, fontWeight: FontWeight.bold),
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
                    Text(
                        ' [ ${widget.order.payMethod == 0 ? '신용카드' : '간편결제'} ]')
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
                  thickness: 6,
                ),
                SizedBox(
                  height: size.height * 0.01,
                ),
                Text(
                  '주문 상품 목록',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
                SizedBox(
                  height: size.height * 0.015,
                ),
                Column(
                  children: _item(widget.order.detail, size),
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
                          '총 결제 금액  ${NumberFormatter.formatPrice(widget.order.totalPrice)}원',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
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
                          DefaultButtonComp(
                            onPressed: () async {
                              var res = await _chargeOrderRequest();
                              if (res) {
                                ToastMessage.show(
                                    '주문 번호 ${widget.order.orderID} 담당 완료 ');
                                setState(() {
                                  _isCharged = true;
                                  _state = 2;
                                });
                              } else {
                                ToastMessage.show('문제가 발생하였습니다.');
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
            Text('${widget.order.chargerID ?? widget.user!.uid}',
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
              '담당자 ID  : ${widget.order.chargerID}',
              style: TextStyle(fontWeight: FontWeight.bold),
            )
          ],
        );
      case 4:
        return Text(
          '결제 취소 및 주문이 취소되었습니다.',
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 15, color: Colors.grey),
        );
      default:
        return SizedBox();
    }
  }

  Widget _detailItemTile(OrderDetail detail, Size size) {
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
                  '[${detail.product.category}] ',
                  style: TextStyle(
                    color: Colors.black54,
                  ),
                ),
                Text(
                  detail.product.name,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                Text(
                  '  ${detail.quantity}개',
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
                '정가 ${NumberFormatter.formatPrice(detail.product.price)}원',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              detail.product.discount == null
                  ? SizedBox()
                  : Text(
                      ' [${detail.product.discount}% 할인]',
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
    for (int index = 0; index < list.length; ++index) {
      w.add(_detailItemTile(list[index], size));
    }
    return w;
  }
}
