import 'package:asgshighschool/data/category.dart';
import 'package:asgshighschool/data/product.dart';
import 'package:asgshighschool/data/user.dart';
import 'package:flutter/material.dart';

import '../../component/ThemeAppBar.dart';

class ReservationCompletePage extends StatefulWidget {
  final User? user;
  final int? count;
  final Product? product;
  final String? orderID;
  final int? totalPrice;

  ReservationCompletePage(
      {this.user, this.product, this.count, this.orderID, this.totalPrice});

  @override
  _ReservationCompletePageState createState() =>
      _ReservationCompletePageState();
}

class _ReservationCompletePageState extends State<ReservationCompletePage> {

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, true);
        return false;
      },
      child: Scaffold(
        appBar: ThemeAppBar(barTitle: '예약완료'),
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
                padding: EdgeInsets.all(size.width * 0.02),
                margin: EdgeInsets.all(size.width * 0.008),
                decoration: BoxDecoration(
                    border: Border.all(width: 0.8, color: Colors.black),
                    borderRadius: BorderRadius.circular(12)),
                child: Wrap(
                  spacing: size.width * 0.01,
                  children: [
                    Text(
                      '[${Categories.categories[widget.product!.category].name}]',
                      style: TextStyle(color: Colors.grey),
                    ),
                    Text(
                      ' ${widget.product!.prodName} ${widget.count}개 ',
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
              /*QrImage(
                data: widget.orderID,
                size: 190,
              ),
               */
              Center(
                child: Padding(
                  padding: EdgeInsets.all(size.width * 0.01),
                  child: Text(
                    '결제(계좌이체 송금등) 처리가 되면 QR 코드가 부여됩니다.',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.redAccent),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              SizedBox(
                height: size.height * 0.015,
              ),
              Divider(),
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
      ),
    );
  }
}
