import 'dart:convert';
import 'dart:ui';

import 'package:asgshighschool/data/user_data.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

class FinalReservationPage extends StatefulWidget {
  final User user;
  final Map data;
  FinalReservationPage({this.user, this.data});
  @override
  _FinalReservationPageState createState() => _FinalReservationPageState();
}

class _FinalReservationPageState extends State<FinalReservationPage> {
  final _categoryReverseMap = {
    0: '음식류',
    1: '간식류',
    2: '음료류',
    3: '문구류',
    4: '핸드메이드'
  };

  Future<bool> _convertFinishedState() async {
    String url =
        'http://nacha01.dothome.co.kr/sin/arlimi_updateOrderFinal.php?oid=${widget.data['oID']}';
    final response = await http.get(url);

    if (response.statusCode == 200) {
      String result = utf8
          .decode(response.bodyBytes)
          .replaceAll(
              '<meta http-equiv="Content-Type" content="text/html; charset=utf-8">',
              '')
          .trim();
      if (result != '1') return false;
      return true;
    } else {
      return false;
    }
  }

  void _terminateScreen() {
    Navigator.pop(this.context, true);
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
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, true);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xFF9EE1E5),
          title: Text(
            '예약정보 조회 완료',
            style: TextStyle(
                color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14),
          ),
          centerTitle: true,
          leading: IconButton(
              onPressed: () => Navigator.pop(context, true),
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
                      height: size.height * 0.015,
                    ),
                    Text(
                      '예약 정보',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: size.height * 0.015,
                    ),
                    Text(
                      " *하단의 '최종 수령 완료 처리하기' 버튼은 예약자에게 실제로 예약된 상품을 수령한 후 사용하는 버튼입니다.",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                          fontSize: 13),
                      textAlign: TextAlign.center,
                    ),
                    Divider(),
                    Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.all(size.width * 0.01),
                          child: Row(
                            children: [
                              Text(
                                '예약 번호',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              Text(
                                '  ${widget.data['oID']}',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.red),
                              )
                            ],
                          ),
                        ),
                        SizedBox(
                          height: size.height * 0.01,
                        ),
                        Padding(
                          padding: EdgeInsets.all(size.width * 0.01),
                          child: Row(
                            children: [
                              Text(
                                '예약 일자',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              Text(
                                '  ${widget.data['oDate']}',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: Colors.grey),
                              )
                            ],
                          ),
                        ),
                        SizedBox(
                          height: size.height * 0.01,
                        ),
                        Padding(
                          padding: EdgeInsets.all(size.width * 0.01),
                          child: Row(
                            children: [
                              Text(
                                '예약자 이름 ',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              Text(
                                ' ${widget.data['name']}',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.green),
                              )
                            ],
                          ),
                        ),
                        SizedBox(
                          height: size.height * 0.01,
                        ),
                        Padding(
                          padding: EdgeInsets.all(size.width * 0.01),
                          child: Row(
                            children: [
                              Text(
                                '예약자 ID ',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              Text('${widget.data['uid']}',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.green))
                            ],
                          ),
                        ),
                        SizedBox(
                          height: size.height * 0.01,
                        ),
                        _productItemTile(size),
                        SizedBox(
                          height: size.height * 0.01,
                        ),
                        Divider(),
                        SizedBox(
                          height: size.height * 0.01,
                        ),
                        Container(
                            width: size.width * 0.9,
                            height: size.height * 0.5,
                            child: CachedNetworkImage(
                              imageUrl: widget.data['detail'][0]['pInfo']
                                  ['imgUrl'],
                              fit: BoxFit.fill,
                              progressIndicatorBuilder: (context, string,
                                      progress) =>
                                  Center(child: CircularProgressIndicator()),
                            )),
                        Divider(),
                        Padding(
                          padding: EdgeInsets.all(size.width * 0.02),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Card(
                                child: Container(
                                  padding: EdgeInsets.all(size.width * 0.04),
                                  width: size.width * 0.4,
                                  alignment: Alignment.center,
                                  child: Text(
                                    '총 ${_formatPrice(int.parse(widget.data['detail'][0]['quantity']) * int.parse(widget.data['detail'][0]['pInfo']['price']))}원',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Divider(),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            FlatButton(
              padding: EdgeInsets.all(0),
              onPressed: () async {
                showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                          title: Text('예약 완료 처리하기'),
                          content: Text(
                            '예약자가 예약한 상품을 수령했습니까? 정말로 최종 완료 처리를 하시겠습니까?',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          actions: [
                            FlatButton(
                                onPressed: () async {
                                  var res = await _convertFinishedState();
                                  if (res) {
                                    Fluttertoast.showToast(
                                        msg: '예약 완료처리가 성공적으로 완료 되었습니다!');
                                    Navigator.pop(context);
                                    _terminateScreen();
                                  } else {
                                    Fluttertoast.showToast(
                                        msg: '예약 완료처리에 실패하였습니다!');
                                    Navigator.pop(context);
                                  }
                                },
                                child: Text(
                                  '예',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blueAccent),
                                )),
                            FlatButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text(
                                  '아니오',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red),
                                ))
                          ],
                        ));
              },
              child: Container(
                alignment: Alignment.center,
                child: Text(
                  '최종 수령 완료 처리하기',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                width: size.width,
                height: size.height * 0.05,
                margin: EdgeInsets.all(size.width * 0.01),
                decoration: BoxDecoration(
                    border: Border.all(width: 0.5, color: Colors.black),
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.tealAccent),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _productItemTile(Size size) {
    return Container(
      width: size.width,
      padding: EdgeInsets.all(size.width * 0.03),
      margin: EdgeInsets.all(size.width * 0.01),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(width: 2, color: Colors.grey)),
      child: Row(
        children: [
          Text(
            ' [${_categoryReverseMap[int.parse(widget.data['detail'][0]['pInfo']['category'])]}]',
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
          Text(
            '  ${widget.data['detail'][0]['pInfo']['pName']}  ',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Text(
            ' ${widget.data['detail'][0]['quantity']}개',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          )
        ],
      ),
    );
  }
}
