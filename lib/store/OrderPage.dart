import 'dart:ui';

import 'package:asgshighschool/data/product_data.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class OrderPage extends StatefulWidget {
  OrderPage({this.direct, this.cart, this.productCount});
  final Product direct; // 바로 결제 시 그 단일 상품 하나
  final List<Map> cart; // 장바구니에서 결제시 장바구니 리스트 Map 데이터
  final int productCount; // 바로 결제시 상품의 개수
  @override
  _OrderPageState createState() => _OrderPageState();
}

enum ReceiveMethod { DELIVERY, DIRECT }

class _OrderPageState extends State<OrderPage> {
  ReceiveMethod _receiveMethod = ReceiveMethod.DIRECT;
  TextEditingController _requestOptionController = TextEditingController();
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
          '주문하기',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: size.height * 0.05,
                  ),
                  Divider(
                    thickness: 0.5,
                    indent: 5,
                    endIndent: 5,
                  ),
                  SizedBox(
                    height: size.height * 0.02,
                  ),
                  Text(
                    ' * 수령 방식 선택',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: Colors.black54),
                  ),
                  RadioListTile(
                      subtitle: Text('직접 오셔서 물건을 수령하셔야 합니다.'),
                      title: Text('직접 수령'),
                      value: ReceiveMethod.DIRECT,
                      groupValue: _receiveMethod,
                      onChanged: (value) {
                        setState(() {
                          _receiveMethod = value;
                        });
                      }),
                  RadioListTile(
                      subtitle: Text('요청하신 장소로 배달해드립니다.'),
                      title: Text('배달'),
                      value: ReceiveMethod.DELIVERY,
                      groupValue: _receiveMethod,
                      onChanged: (value) {
                        setState(() {
                          _receiveMethod = value;
                        });
                      }),
                  Divider(
                    thickness: 0.5,
                    indent: 5,
                    endIndent: 5,
                  ),
                  SizedBox(
                    height: size.height * 0.02,
                  ),
                  Text(' * 결제 수단 선택',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: Colors.black54)),
                  SizedBox(
                    height: size.height * 0.03,
                  ),
                  Divider(
                    thickness: 0.5,
                    indent: 5,
                    endIndent: 5,
                  ),
                  SizedBox(
                    height: size.height * 0.02,
                  ),
                  Text(' * 휴대폰 본인 인증',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: Colors.black54)),
                  SizedBox(
                    height: size.height * 0.03,
                  ),
                  Divider(
                    thickness: 0.5,
                    indent: 5,
                    endIndent: 5,
                  ),
                  SizedBox(
                    height: size.height * 0.02,
                  ),
                  Text('  추가 요청 사항',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: Colors.black54)),
                  SizedBox(
                    height: size.height * 0.03,
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
                    height: size.height * 0.03,
                  ),
                  Divider(
                    thickness: 0.5,
                    indent: 5,
                    endIndent: 5,
                  ),
                  SizedBox(
                    height: size.height * 0.03,
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
                            children: [Text('결제 금액'), Text('원')],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [Text('할인 금액'), Text('원')],
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
                                '총 금액',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              Text('원',
                                  style: TextStyle(
                                      fontSize: 16, fontWeight: FontWeight.bold))
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: size.height * 0.03,
                  ),
                ],
              ),
            ),
          ),
          FlatButton(
            onPressed: () => Navigator.push(
                context, MaterialPageRoute(builder: (context) => OrderPage())),
            child: Container(
              alignment: Alignment.center,
              height: size.height * 0.04,
              margin: EdgeInsets.all(12),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(9),
                  color: Color(0xFF9EE1E5)),
              width: size.width,
              child: Text(
                '원  결제하기',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          )
        ],
      ),
    );
  }
}
