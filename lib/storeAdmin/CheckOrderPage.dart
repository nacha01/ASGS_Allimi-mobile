import 'package:flutter/material.dart';

class CheckOrderPage extends StatefulWidget {
  CheckOrderPage({this.orderID});
  final String orderID;
  @override
  _CheckOrderPageState createState() => _CheckOrderPageState();
}

class _CheckOrderPageState extends State<CheckOrderPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Color(0xFF9EE1E5),
        title: Text(
          '주문 조회 페이지',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Text(widget.orderID),
      ),
    );
  }
}
