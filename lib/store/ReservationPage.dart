import 'dart:convert';
import 'dart:ui';

import 'package:asgshighschool/data/product.dart';
import 'package:asgshighschool/data/user.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

import 'ReservationCompletePage.dart';

class ReservationPage extends StatefulWidget {
  ReservationPage({this.product, this.user, this.optionList, this.selectList});

  final Product product;
  final User user;
  final List optionList;
  final List selectList;

  @override
  _ReservationPageState createState() => _ReservationPageState();
}

class _ReservationPageState extends State<ReservationPage> {
  TextEditingController _counterController = TextEditingController();
  TextEditingController _requestOptionController = TextEditingController();
  int _counter = 1;
  bool _isAgreed = false;
  String _generatedOID;
  TextEditingController _countController = TextEditingController();
  Map _initResvCount;
  int _additionalPrice = 0;
  String _optionString = '';
  bool _isSelected = false;

  /// 최종적으로 예약을 등록하는 요청
  /// @return : 등록 성공 여부
  Future<bool> _registerReservation() async {
    String url =
        'http://nacha01.dothome.co.kr/sin/arlimi_registerReservation.php';
    _generatedOID = DateTime.now().millisecondsSinceEpoch.toString();
    final response = await http.post(url, body: <String, String>{
      'oid': _generatedOID,
      'uid': widget.user.uid,
      'oDate': DateTime.now().toString(),
      'price':
          ((widget.product.price * (1 - (widget.product.discount / 100.0)) +
                      _additionalPrice) *
                  _counter)
              .toString(),
      'oState': '0',
      'recvMethod': '0',
      'pay': '0',
      'option': _optionString +
          (_requestOptionController.text.isEmpty
              ? ''
              : '\n${_requestOptionController.text}'),
      'resv': '1'
    });
    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  void _preProcessForOptions() {
    if (widget.selectList == null) {
      return;
    }
    for (int i = 0; i < widget.selectList.length; ++i) {
      if (widget.selectList[i] != -1) {
        _isSelected = true;
        break;
      }
    }
    if (!_isSelected) {
      return;
    }
    _optionString += '[ 상품 옵션 : ';
    for (int i = 0; i < widget.optionList.length; ++i) {
      if (widget.selectList[i] != -1) {
        _additionalPrice += int.parse(widget.optionList[i]['detail']
            [widget.selectList[i]]['optionPrice']);
        _optionString += widget.optionList[i]['optionCategory'] +
            ' ' +
            widget.optionList[i]['detail'][widget.selectList[i]]['optionName'] +
            ' , ';
      }
    }
    _optionString += ']';
  }

  Future<bool> _setReservationCountLimit() async {
    String url = 'http://nacha01.dothome.co.kr/sin/arlimi_resvLimit.php';
    int value = int.parse(_countController.text) < 0 &&
            int.parse(_countController.text) != -1
        ? -1
        : int.parse(_countController.text);
    final response = await http.post(url, body: <String, String>{
      'pid': widget.product.prodID.toString(),
      'max_count': value.toString()
    });

    if (response.statusCode == 200) {
      String result = utf8
          .decode(response.bodyBytes)
          .replaceAll(
              '<meta http-equiv="Content-Type" content="text/html; charset=utf-8">',
              '')
          .trim();

      if (result == 'UPDATE1' || result == 'INSERT1') {
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  Future<bool> _getReservationCurrent() async {
    String url =
        'http://nacha01.dothome.co.kr/sin/arlimi_getResvCount.php?pid=${widget.product.prodID.toString()}';
    final response = await http.get(url);

    if (response.statusCode == 200) {
      String result = utf8
          .decode(response.bodyBytes)
          .replaceAll(
              '<meta http-equiv="Content-Type" content="text/html; charset=utf-8">',
              '')
          .trim();
      _initResvCount = json.decode(result);
      _countController.text = _initResvCount['max_count'];
      return true;
    } else {
      return false;
    }
  }

  Future<bool> _updateReservationCurrent() async {
    String url =
        'http://nacha01.dothome.co.kr/sin/arlimi_updateResvCurrent.php';
    final response = await http.post(url, body: <String, String>{
      'pid': widget.product.prodID.toString(),
      'count': _counterController.text,
      'operation': 'add'
    });

    if (response.statusCode == 200) {
      String result = utf8
          .decode(response.bodyBytes)
          .replaceAll(
              '<meta http-equiv="Content-Type" content="text/html; charset=utf-8">',
              '')
          .trim();
      if (result == '1') return true;
      return false;
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

  @override
  void initState() {
    _counterController.text = _counter.toString();
    _preProcessForOptions();
    super.initState();
    _getReservationCurrent();
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
                  SizedBox(
                    height: size.height * 0.01,
                  ),
                  Padding(
                    padding: EdgeInsets.all(size.width * 0.02),
                    child: Wrap(
                      children: [
                        Text(
                          '상품 [',
                          style: TextStyle(fontSize: 17),
                        ),
                        Text(
                          '${widget.product.prodName}',
                          style: TextStyle(color: Colors.green, fontSize: 17),
                        ),
                        Text('] 예약하기', style: TextStyle(fontSize: 17)),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: size.height * 0.01,
                  ),
                  widget.user.isAdmin
                      ? Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: size.width * 0.04),
                          decoration: BoxDecoration(
                              border: Border.all(width: 1, color: Colors.black),
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.redAccent),
                          child: FlatButton(
                            padding: EdgeInsets.all(0),
                            onPressed: () {
                              showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                        title: Text('최대 예약 수량 설정'),
                                        content: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text('수량 : '),
                                                Container(
                                                  child: TextField(
                                                    controller:
                                                        _countController,
                                                    textAlign: TextAlign.center,
                                                    keyboardType:
                                                        TextInputType.number,
                                                  ),
                                                  width: size.width * 0.2,
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                              height: size.height * 0.015,
                                            ),
                                            Text(
                                              '* 제한을 두지 않을 경우에는 -1을 입력해주세요. (제한 없음 = -1)',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12,
                                                  color: Colors.deepOrange),
                                            )
                                          ],
                                        ),
                                        actions: [
                                          FlatButton(
                                              onPressed: () =>
                                                  Navigator.pop(context),
                                              child: Text('취소')),
                                          FlatButton(
                                              onPressed: () async {
                                                var res =
                                                    await _setReservationCountLimit();
                                                if (res) {
                                                  Fluttertoast.showToast(
                                                      msg:
                                                          '수량 제한 설정이 완료되었습니다.');
                                                } else {
                                                  Fluttertoast.showToast(
                                                      msg: '수량 제한에 실패하였습니다!');
                                                  _countController.text =
                                                      _initResvCount[
                                                          'max_count'];
                                                }
                                                Navigator.pop(context);
                                              },
                                              child: Text('설정'))
                                        ],
                                      ));
                            },
                            child: Text(
                              '[관리자] 예약 가능한 최대 수량 설정하기',
                              style: TextStyle(
                                  color: Colors.grey[200],
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12),
                            ),
                          ),
                        )
                      : SizedBox(),
                  SizedBox(
                    height: size.height * 0.01,
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
                    height: size.height * 0.01,
                  ),
                  Card(
                    child: ListTile(
                      leading: Text(
                        '결제 금액',
                        textAlign: TextAlign.center,
                      ),
                      title: Center(
                          child: Text(
                        '${_formatPrice(((widget.product.price * (1 - (widget.product.discount / 100.0)) + _additionalPrice) * _counter).round())}원',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      )),
                    ),
                  ),
                  !_isSelected
                      ? SizedBox()
                      : Column(
                          children: [
                            Row(
                              children: [
                                Padding(
                                  padding: EdgeInsets.all(size.width * 0.02),
                                  child: Text('  * 상품 옵션 내역',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                          color: Colors.black54)),
                                ),
                              ],
                            ),
                            Text(
                              _optionString,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            )
                          ],
                        ),
                  Divider(
                    thickness: 0.5,
                    indent: 5,
                    endIndent: 5,
                  ),
                  SizedBox(
                    height: size.height * 0.02,
                  ),
                  Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(size.width * 0.02),
                        child: Text('  * 추가 요청 사항',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: Colors.black54)),
                      ),
                    ],
                  ),
                  Center(
                    child: Container(
                      width: size.width * 0.9,
                      decoration: BoxDecoration(
                          border: Border.all(width: 1, color: Colors.black),
                          borderRadius: BorderRadius.circular(5)),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: ' 필요시 요청 사항을 입력하세요.',
                          hintStyle: TextStyle(color: Colors.grey),
                          border: InputBorder.none,
                        ),
                        controller: _requestOptionController,
                        maxLines: null,
                      ),
                    ),
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
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                  /*Padding(
                    padding: EdgeInsets.all(size.width * 0.02),
                    child: Row(
                      children: [
                        Text(
                          '※ 예약 기능은 ',
                          style: TextStyle(fontSize: 15),
                        ),
                        Text(
                          '선결제',
                          style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 15),
                        ),
                        Text('를 통해 이루어집니다.', style: TextStyle(fontSize: 15))
                      ],
                    ),
                  ),
                   */
                  Padding(
                    padding: EdgeInsets.all(size.width * 0.02),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('* 예약 후 상품의 재고가 입고하게 되면 '),
                        Row(
                          children: [
                            Text(
                              "  '예약 완료 처리 기준'",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green),
                            ),
                            Text('에 따라 처리가 됩니다.')
                          ],
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(size.width * 0.02),
                    child: Text("* 완료 처리가 되면 예약자에게 입고되었다는 '예약 알람 메세지'를 전송합니다."),
                  ),
                  Padding(
                    padding: EdgeInsets.all(size.width * 0.02),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              '※ 입고한 재고의 수량에 따라 ',
                              style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12),
                            ),
                            Text("'예약 알람 메세지'",
                                style: TextStyle(
                                    color: Colors.teal,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    decoration: TextDecoration.underline)),
                          ],
                        ),
                        Text('가 전송되지 않을 수 있습니다.',
                            style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                                fontSize: 12))
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(size.width * 0.02),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('* 예약 후 "예약 취소"는 결제하기 전에서만 가능합니다.'),
                        Row(
                          children: [
                            Text(
                              '결제를 마친 상태에서 예약 취소 및 환불을 원하시면 ',
                              style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey),
                            ),
                            Text(
                              "'문의하기'",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                  fontSize: 10),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Text('에서 문의 바랍니다.',
                                style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey))
                          ],
                        ),
                      ],
                    ),
                  ),
                  Divider(),
                  Padding(
                    padding: EdgeInsets.all(size.width * 0.02),
                    child: Row(
                      children: [
                        Text(
                          '예약 완료 처리 기준 (상품 수령 기준)',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(size.width * 0.02),
                    child: Text('* 예약 완료 처리에 대한 기준은 입고한 총 수량에 따릅니다.'),
                  ),
                  Padding(
                    padding: EdgeInsets.all(size.width * 0.02),
                    child: Text('* 총 수량에서 최대한 많은 사람이 완료 처리가 되도록 할당합니다. '),
                  ),
                  Padding(
                    padding: EdgeInsets.all(size.width * 0.02),
                    child: Text(
                        '* 총 수량에서 각 예약자들의 예약 수량에 따라 완료 처리될 사람들을 우선적으로 선별합니다. '),
                  ),
                  Padding(
                    padding: EdgeInsets.all(size.width * 0.02),
                    child: Text('* 선별된 사람들은 선별된 사람들끼리 예약한 순서대로 처리됩니다.'),
                  ),
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
                                        Text(
                                          '첫째로 A라는 사람이 상품을 5개 예약.',
                                          style: TextStyle(fontSize: 13),
                                        ),
                                        Text('둘째로 B라는 사람이 상품을 10개 예약.',
                                            style: TextStyle(fontSize: 13)),
                                        Text('셋째로 C라는 사람이 상품을 3개 예약.\n',
                                            style: TextStyle(fontSize: 13)),
                                        Text('위의 상황에서 상품이 8개 입고.\n',
                                            style: TextStyle(fontSize: 13)),
                                        Text(
                                            '현재 총 재고(8개)에서 최대한 많은 예약자들을 수용하기 위해서\n ',
                                            style: TextStyle(fontSize: 13)),
                                        Text(
                                            '8개 중에서 5개를 A에 3개를 C에 할당하는 것이 최대 효율이므로 A와 C를 선택\n',
                                            style: TextStyle(fontSize: 13)),
                                        Text(
                                            '선택한 예약자들을 순서대로 예약 완료 처리\n(즉, B를 제외한 나머지를 순서대로 처리)\n',
                                            style: TextStyle(fontSize: 14)),
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
                  _corpInfoLayout(size)
                ],
              ),
            ),
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
                  _isAgreed ? Icons.check_box : Icons.check_box_outline_blank,
                  color: _isAgreed ? Colors.blueAccent : Colors.grey,
                ),
                Text(' 위 내용을 확인했습니다.')
              ],
            ),
          ),
          FlatButton(
              padding: EdgeInsets.all(0),
              onPressed: () async {
                if (!_isAgreed) return;
                await _getReservationCurrent();
                if (int.parse(_initResvCount['max_count']) != -1 &&
                    int.parse(_initResvCount['cur_count']) +
                            int.parse(_counterController.text) >
                        int.parse(_initResvCount['max_count'])) {
                  await showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                            title: Text('예약 불가'),
                            content: Text(
                              '예약 가능한 최대 개수를 초과하는 예약 수량입니다! (${(int.parse(_initResvCount['cur_count']) + int.parse(_counterController.text)) - int.parse(_initResvCount['max_count'])}개 초과)',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            actions: [
                              FlatButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text('확인'))
                            ],
                          ));
                  return;
                }
                var r1 = await _registerReservation();
                if (!r1) return;
                var r2 = await _addOrderDetailRequest();
                if (!r2) return;
                var r3 = await _updateReservationCurrent();
                if (!r3) return;
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
                        builder: (context) => ReservationCompletePage(
                              totalPrice: ((widget.product.price *
                                              (1 -
                                                  (widget.product.discount /
                                                      100.0)) +
                                          _additionalPrice) *
                                      _counter)
                                  .round(),
                              user: widget.user,
                              product: widget.product,
                              count: _counter,
                              orderID: _generatedOID,
                            )));
              },
              child: Container(
                alignment: Alignment.center,
                width: size.width * 0.98,
                padding: EdgeInsets.all(size.width * 0.025),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: _isAgreed ? Colors.blueAccent : Colors.grey),
                child: Text(
                  '예약하기',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ))
        ],
      ),
    );
  }

  Widget _corpInfoLayout(Size size) {
    return Container(
      width: size.width,
      padding: EdgeInsets.all(size.width * 0.02),
      color: Colors.grey[200],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '회사 정보',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
          ),
          SizedBox(
            height: size.height * 0.005,
          ),
          Text(
            '사업자 번호: 135-82-17822',
            style: TextStyle(color: Colors.grey, fontSize: 9),
          ),
          Text('회사명: 안산강서고등학교 교육경제공동체 사회적협동조합',
              style: TextStyle(color: Colors.grey, fontSize: 9)),
          Text('대표자: 김은미', style: TextStyle(color: Colors.grey, fontSize: 9)),
          Text('위치: 경기도 안산시 단원구 와동 삼일로 367, 5층 공작관 다목적실 (안산강서고등학교)',
              style: TextStyle(color: Colors.grey, fontSize: 9)),
          Text('대표 전화: 031-485-9742',
              style: TextStyle(color: Colors.grey, fontSize: 9)),
          Text('대표 이메일: asgscoop@naver.com',
              style: TextStyle(color: Colors.grey, fontSize: 9))
        ],
      ),
    );
  }
}
