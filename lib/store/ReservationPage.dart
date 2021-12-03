import 'package:asgshighschool/data/product_data.dart';
import 'package:asgshighschool/data/user_data.dart';
import 'package:flutter/material.dart';

class ReservationPage extends StatefulWidget {
  ReservationPage({this.product, this.user});

  final Product product;
  final User user;

  @override
  _ReservationPageState createState() => _ReservationPageState();
}

class _ReservationPageState extends State<ReservationPage> {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('상품 ['),
              Text(
                '${widget.product.prodName}',
                style: TextStyle(color: Colors.blueAccent),
              ),
              Text('] 예약하기'),
            ],
          ),
          Divider(),

        ],
      ),
    );
  }
}
