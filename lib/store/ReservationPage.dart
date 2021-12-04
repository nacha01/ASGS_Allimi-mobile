import 'dart:ui';

import 'package:asgshighschool/data/product_data.dart';
import 'package:asgshighschool/data/user_data.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import 'ReservationCompletePage.dart';

class ReservationPage extends StatefulWidget {
  ReservationPage({this.product, this.user});

  final Product product;
  final User user;

  @override
  _ReservationPageState createState() => _ReservationPageState();
}

class _ReservationPageState extends State<ReservationPage> {
  TextEditingController _counterController = TextEditingController();
  int _counter = 1;
  bool _isAgreed = false;
  String _generatedOID;

  Future<bool> _registerReservation() async {
    String url =
        'http://nacha01.dothome.co.kr/sin/arlimi_registerReservation.php';
    _generatedOID = DateTime.now().millisecondsSinceEpoch.toString();
    final response = await http.post(url, body: <String, String>{
      'oid': _generatedOID,
      'uid': widget.user.uid,
      'oDate': DateTime.now().toString(),
      'price': (widget.product.price * _counter).toString(),
      'oState': '1',
      'recvMethod': '0',
      'pay': '0',
      'option': '',
      'resv': '1'
    });
    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  /// orderDetail 테이블에 oid인 값에 대하여 어떤 상품인지 등록하는 http 요청
  Future<bool> _addOrderDetailRequest() async {
    String url = 'http://nacha01.dothome.co.kr/sin/arlimi_addOrderDetail.php';
    final response = await http.post(url, body: <String, String>{
      'oid': _generatedOID,
      'pid': widget.product.prodID.toString(),
      'quantity': _counter.toString()
    });
    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  @override
  void initState() {
    _counterController.text = _counter.toString();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF9EE1E5),
        title: Text(
          '예약하기',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.arrow_back,
              color: Colors.black,
            )),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.all(size.width * 0.02),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '상품 [',
                          style: TextStyle(fontSize: 18),
                        ),
                        Text(
                          '${widget.product.prodName}',
                          style:
                              TextStyle(color: Colors.blueAccent, fontSize: 18),
                        ),
                        Text('] 예약하기', style: TextStyle(fontSize: 18)),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: size.height * 0.02,
                  ),
                  Divider(
                    thickness: 1,
                  ),
                  SizedBox(
                    height: size.height * 0.02,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                          width: size.width * 0.3,
                          alignment: Alignment.center,
                          child: Text(
                            '예약 수량',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15),
                          )),
                      Container(
                        alignment: Alignment.center,
                        width: size.width * 0.6,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: () {
                                if (_counter < 2) {
                                  return;
                                }
                                setState(() {
                                  _counter--;
                                  _counterController.text = _counter.toString();
                                });
                              },
                              icon: Icon(Icons.keyboard_arrow_left),
                              iconSize: 32,
                            ),
                            Container(
                              width: size.width * 0.2,
                              child: TextField(
                                textAlign: TextAlign.center,
                                controller: _counterController,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly
                                ],
                                keyboardType: TextInputType.number,
                                onChanged: (text) {
                                  try {
                                    setState(() {
                                      _counter = int.parse(text);
                                    });
                                  } catch (e) {}
                                },
                                onEditingComplete: () {
                                  if (_counterController.text.isEmpty) {
                                    setState(() {
                                      _counter = 1;
                                      _counterController.text =
                                          _counter.toString();
                                    });
                                  }
                                },
                              ),
                            ),
                            IconButton(
                                onPressed: () {
                                  setState(() {
                                    _counter++;
                                    _counterController.text =
                                        _counter.toString();
                                  });
                                },
                                icon: Icon(Icons.keyboard_arrow_right),
                                iconSize: 32)
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: size.height * 0.02,
                  ),
                  Divider(),
                  Padding(
                    padding: EdgeInsets.all(size.width * 0.02),
                    child: Row(
                      children: [
                        Text(
                          '안내 사항',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Text('예약 기능은 '),
                      Text(
                        '선결제',
                        style: TextStyle(
                            color: Colors.red, fontWeight: FontWeight.bold),
                      ),
                      Text('를 통해 이루어집니다.')
                    ],
                  ),
                  Column(
                    children: [
                      Text('예약 후 상품의 재고가 입고하게 되면 '),
                      Text('예약 완료 처리 기준에 따라 처리가 됩니다.'),
                      Text('완료 처리가 되면 예약자에게 입고되었다는 알람 메세지를 전송합니다.')
                    ],
                  ),
                  Text('입고한 재고의 수량에 따라 예약 알람 메세지를 전달되지 않을 수 있습니다. '),
                  Divider(),
                  Padding(
                    padding: EdgeInsets.all(size.width * 0.02),
                    child: Row(
                      children: [
                        Text(
                          '예약 처리 기준',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ],
                    ),
                  ),
                  Text('예약 완료 처리에 대한 기준은 입고한 총 수량에 따릅니다.'),
                  Text('총 수량에서 최대한 많은 사람이 완료 처리가 되도록 할당합니다. '),
                  Text(
                      '총 수량에서 각 예약자들의 예약 수량에 따라 완료 처리될 사람들을 우선적으로 구하고, 구한 사람들 중 예약한 순서대로 처리됩니다.'),
                  Row(
                    children: [
                      FlatButton(
                        onPressed: () {
                          showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                    title: Text('예시'),
                                    content: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text('A라는 사람이 상품을 5개 예약.'),
                                        Text('B라는 사람이 상품을 10개 예약.'),
                                        Text('C라는 사람이 상품을 3개 예약.\n'),
                                        Text('이 상황에서 상품이 8개 입고.\n'),
                                        Text(
                                            '총 재고(8개)에서 최대한 많은 예약자들을 수용하기 위해서\n '),
                                        Text(
                                            '8개 중에서 5개를 A에 3개를 C에 할당하는 것이 최대 효율이므로\n'),
                                        Text('A와 C를 선택\n'),
                                        Text('선택한 예약자들을 순서대로 예약 완료 처리\n'),
                                        Text(
                                          'A → C',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        )
                                      ],
                                    ),
                                    actions: [
                                      FlatButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: Text('확인'))
                                    ],
                                  ));
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.lightbulb,
                              color: Colors.lime,
                            ),
                            Text(
                              '기준 예시',
                              style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.lightBlue,
                                  decoration: TextDecoration.underline),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  FlatButton(
                    onPressed: () {
                      setState(() {
                        _isAgreed = !_isAgreed;
                      });
                    },
                    child: Row(
                      children: [
                        Icon(
                          _isAgreed
                              ? Icons.check_box
                              : Icons.check_box_outlined,
                          color: Colors.grey,
                        ),
                        Text(' 위 내용을 확인했습니다.')
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          FlatButton(
              padding: EdgeInsets.all(0),
              onPressed: () async {
                var r1 = await _registerReservation();
                if (!r1) return;
                var r2 = await _addOrderDetailRequest();
                if (!r2) return;

                /* 결제하는 과정 */

                await showDialog(
                    context: context,
                    builder: (ctx) {
                      Future.delayed(Duration(milliseconds: 500),
                          () => Navigator.pop(ctx));
                      return AlertDialog(
                        title: Text('처리 중입니다..'),
                        content: LinearProgressIndicator(),
                        shape: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide:
                                BorderSide(color: Colors.black, width: 2)),
                      );
                    });
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ReservationCompletePage()));
              },
              child: Container(
                alignment: Alignment.center,
                width: size.width * 0.98,
                padding: EdgeInsets.all(size.width * 0.025),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.blueAccent),
                child: Text(
                  '예약 및 선결제하기',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ))
        ],
      ),
    );
  }
}
