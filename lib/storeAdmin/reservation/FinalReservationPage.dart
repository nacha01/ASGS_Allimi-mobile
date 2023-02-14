import 'dart:convert';
import 'package:asgshighschool/api/ApiUtil.dart';
import 'package:asgshighschool/component/ThemeAppBar.dart';
import 'package:asgshighschool/data/category.dart';
import 'package:asgshighschool/data/user.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

import '../../component/DefaultButtonComp.dart';

class FinalReservationPage extends StatefulWidget {
  final User? user;
  final Map? data;

  FinalReservationPage({this.user, this.data});

  @override
  _FinalReservationPageState createState() => _FinalReservationPageState();
}

class _FinalReservationPageState extends State<FinalReservationPage> {
  /// 실제로 상품을 예약자에게 수령하고 난 뒤, '수령 완료' 상태로 변경하기 위한 요청
  Future<bool> _convertFinishedState() async {
    String url =
        '${ApiUtil.API_HOST}arlimi_updateOrderFinal.php?oid=${widget.data!['oID']}';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      String result = ApiUtil.getPureBody(response.bodyBytes);
      if (result != '1') return false;
      return true;
    } else {
      return false;
    }
  }

  /// 현재 페이지를 종료하는 함수
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
        appBar: ThemeAppBar(
            barTitle: '예약정보 조회 완료',
            leadingClick: () => Navigator.pop(context, true)),
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
                                '  ${widget.data!['oID']}',
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
                                '  ${widget.data!['oDate']}',
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
                                ' ${widget.data!['name']}',
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
                              Text('${widget.data!['uid']}',
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
                        Padding(
                          padding: EdgeInsets.all(size.width * 0.01),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    '요청사항 및 상품 옵션',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16),
                                  ),
                                ],
                              ),
                              Text('${widget.data!['options']}',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.blueGrey))
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
                              imageUrl: widget.data!['detail'][0]['pInfo']
                                  ['imgUrl'],
                              fit: BoxFit.cover,
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
                                  width: size.width * 0.6,
                                  alignment: Alignment.center,
                                  child: Text(
                                    '최종 금액 ${_formatPrice(int.parse(widget.data!['totalPrice']))}원',
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
            DefaultButtonComp(
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
                            DefaultButtonComp(
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
                            DefaultButtonComp(
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
            ' [${Category.categoryIndexToStringMap[int.parse(widget.data!['detail'][0]['pInfo']['category'])]}]',
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
          Text(
            '  ${widget.data!['detail'][0]['pInfo']['pName']}  ',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Text(
            ' ${widget.data!['detail'][0]['quantity']}개',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          )
        ],
      ),
    );
  }
}
