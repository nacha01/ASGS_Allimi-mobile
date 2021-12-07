import 'dart:ui';

import 'package:asgshighschool/data/product_data.dart';
import 'package:asgshighschool/data/user_data.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ReservationCompletePage extends StatefulWidget {
  final User user;
  final int count;
  final Product product;
  final String orderID;

  ReservationCompletePage({this.user, this.product, this.count, this.orderID});

  @override
  _ReservationCompletePageState createState() =>
      _ReservationCompletePageState();
}

class _ReservationCompletePageState extends State<ReservationCompletePage> {
  final _categoryReverseMap = {
    0: '음식류',
    1: '간식류',
    2: '음료류',
    3: '문구류',
    4: '핸드메이드'
  };
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF9EE1E5),
        title: Text(
          '예약 완료',
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: size.height * 0.03,
            ),
            Text(
              '예약이 성공적으로 완료되었습니다.',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: size.height * 0.02,
            ),
            Divider(
              thickness: 0.5,
            ),
            SizedBox(
              height: size.height * 0.02,
            ),
            Text(
              '예약번호(주문번호) ${widget.orderID}',
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.lightBlue),
            ),
            SizedBox(
              height: size.height * 0.02,
            ),
            Container(
              width: size.width * 0.8,
              height: size.height * 0.06,
              padding: EdgeInsets.all(8),
              margin: EdgeInsets.all(4),
              decoration: BoxDecoration(
                  border: Border.all(width: 0.8, color: Colors.black),
                  borderRadius: BorderRadius.circular(12)),
              child: Row(
                children: [
                  Text(
                    '[${_categoryReverseMap[widget.product.category]}]',
                    style: TextStyle(color: Colors.grey),
                  ),
                  Text(
                    ' ${widget.product.prodName} ${widget.count}개 ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: size.height * 0.02,
            ),
            Text('예약 현황 및 상세 정보는 '),
            Text("'마이페이지' → '예약 현황'",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                    fontSize: 15)),
            SizedBox(
              height: size.height * 0.01,
            ),
            Text(' 에서도 확인할 수 있습니다.', style: TextStyle(fontSize: 12)),
            SizedBox(
              height: size.height * 0.03,
            ),
            Divider(
              thickness: 0.5,
              indent: 3,
              endIndent: 3,
            ),
            Text(
              '예약 확인용 QR 코드',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: size.height * 0.02,
            ),
            QrImage(
              data: widget.orderID,
              size: 190,
            ),
            SizedBox(
              height: size.height * 0.01,
            ),
            Padding(
              padding: EdgeInsets.all(size.width * 0.03),
              child: Text(
                "※상품이 입고한 뒤 본인이 '수령 가능한 상태'에 해당하면 알람 메세지가 전송될 예정입니다. ",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo,
                    fontSize: 16),
              ),
            ),
            Divider(
              indent: 3,
              endIndent: 3,
            ),
            SizedBox(
              height: size.height * 0.02,
            ),
            Padding(
              padding: EdgeInsets.all(size.width * 0.03),
              child: Text(
                'QR 코드나 예약 번호(주문 번호)는 본인이 예약을 했다는 것을 인증할 수 있는 수단으로써 상품을 수령하기 위해서는 반드시 필요한 것입니다.',
                style: TextStyle(fontSize: 11, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
