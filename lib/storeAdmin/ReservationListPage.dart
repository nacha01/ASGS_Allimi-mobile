import 'package:asgshighschool/data/user_data.dart';
import 'package:flutter/material.dart';

class ReservationListPage extends StatefulWidget {
  final User user;
  ReservationListPage({this.user});
  @override
  _ReservationListPageState createState() => _ReservationListPageState();
}

class _ReservationListPageState extends State<ReservationListPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF9EE1E5),
        title: Text(
          '예약 목록 [관리자]',
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14),
        ),
        centerTitle: true,
        leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.arrow_back,
              color: Colors.black,
            )),
      ),
    );
  }
}
