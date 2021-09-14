import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class PaymentCompletePage extends StatefulWidget {
  PaymentCompletePage({this.result});
  final Map result;
  @override
  _PaymentCompletePageState createState() => _PaymentCompletePageState();
}

class _PaymentCompletePageState extends State<PaymentCompletePage> {
  @override
  Widget build(BuildContext context) {
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
          '주문 완료',
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 13),
        ),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text('주문이 성공적으로 완료되었습니다.'),
          Text('주문번호 ${widget.result['orderID']}'),
          Text('주문 현황 및 상세 정보는 "마이페이지" -> "주문 현황" 에서 확인할 수 있습니다.'),
          Text('주문 인증 QR 코드[주문을 했다고 증명할 수 있는 것들 QR코드, 주문번호]'),
          QrImage(
            data: widget.result['orderID'],
            size: 180,
          )
        ],
      ),
    );
  }
}
