import 'dart:ui';

import 'package:asgshighschool/data/product_data.dart';
import 'package:asgshighschool/data/user_data.dart';
import 'package:flutter/material.dart';

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
            Text('예약 현황 및 상세 정보는 '),
            Text("'마이페이지' → '예약 현황",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                    fontSize: 15))
          ],
        ),
      ),
    );
  }
}
