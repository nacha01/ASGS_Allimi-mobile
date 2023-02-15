import 'package:asgshighschool/data/category.dart';
import 'package:asgshighschool/data/user.dart';
import 'package:asgshighschool/util/DateFormatter.dart';
import '../../api/ApiUtil.dart';
import '../../component/DefaultButtonComp.dart';
import '../../component/ThemeAppBar.dart';
import '../../util/NumberFormatter.dart';
import '../qr/QRScannerPage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

class AdminDetailOrder extends StatefulWidget {
  AdminDetailOrder({this.data, this.user});

  final Map? data;
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
      'oid': widget.data!['oID']
    });

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  @override
  void initState() {
    _isCharged = (int.parse(widget.data!['orderState']) == 3 ||
            int.parse(widget.data!['orderState']) == 2)
        ? true
        : false;
    if (int.parse(widget.data!['orderState']) == 4) {
      _isCharged = true;
    }
    _state = int.parse(widget.data!['orderState']);
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
            barTitle: '주문 [${widget.data!['oID']}]',
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
                                    oID: widget.data!['oID'],
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
                  '주문자 ID  ${widget.data!['uID']}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: size.height * 0.015,
                ),
                Text(
                  '주문 번호  ${widget.data!['oID']}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: size.height * 0.015,
                ),
                Row(
                  children: [
                    Text(
                        '주문 일자: ${DateFormatter.formatDate(widget.data!['oDate'])}',
                        style: TextStyle(color: Colors.grey, fontSize: 13)),
                    Text(
                      ' (${DateFormatter.formatDateTimeCmp(widget.data!['oDate'])})',
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
                        '주문 완료 일자: ${widget.data!['eDate'] == null || widget.data!['eDate'] == '0000-00-00 00:00:00' ? '-' : DateFormatter.formatDate(widget.data!['eDate'])}',
                        style: TextStyle(color: Colors.grey, fontSize: 13)),
                    Text(
                        ' (${widget.data!['eDate'] == null || widget.data!['eDate'] == '0000-00-00 00:00:00' ? '-' : DateFormatter.formatDateTimeCmp(widget.data!['eDate'])})',
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
                      '[ ${int.parse(widget.data!['receiveMethod']) == 0 ? '직접 수령' : '배달'} ]',
                      style: TextStyle(
                          color: Colors.lightBlue, fontWeight: FontWeight.bold),
                    )
                  ],
                ),
                int.parse(widget.data!['receiveMethod']) == 1
                    ? Padding(
                        padding: EdgeInsets.all(size.width * 0.04),
                        child: Text(
                          '장소 : ${widget.data!['location'] == null ? '' : widget.data!['location']}',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 19,
                              color: Colors.teal),
                        ),
                      )
                    : SizedBox(),
                SizedBox(
                  height: size.height * 0.015,
                ),
                Row(
                  children: [
                    Text('결제 방식 ',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(
                        ' [ ${widget.data!['payMethod'] == '0' ? '신용카드' : '간편결제'} ]')
                  ],
                ),
                SizedBox(
                  height: size.height * 0.015,
                ),
                Text('요청 사항', style: TextStyle(fontWeight: FontWeight.bold)),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                      '${widget.data!['options'].toString().trim() == '' ? 'X' : widget.data!['options']}'),
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
                  children: _item(widget.data!['detail'], size),
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
                          '총 결제 금액  ${NumberFormatter.formatPrice(int.parse(widget.data!['totalPrice']))}원',
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
                          DefaultButtonComp(
                            onPressed: () async {
                              var res = await _chargeOrderRequest();
                              if (res) {
                                Fluttertoast.showToast(
                                    msg: '주문 번호 ${widget.data!['oID']} 담당 완료 ',
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
                '${widget.data!['chargerID'] == null ? widget.user!.uid : widget.data!['chargerID']}',
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
              '담당자 ID  : ${widget.data!['chargerID']}',
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
                '정가 ${NumberFormatter.formatPrice(price)}원',
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
