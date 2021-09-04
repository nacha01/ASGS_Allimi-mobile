import 'package:flutter/material.dart';

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
        children: [
          Text('주문이 성공적으로 완료되었습니다.'),
          Text('주문번호 ${widget.result['orderID']}')
        ],
      ),
    );
  }
}
