import 'package:asgshighschool/data/user_data.dart';
import 'package:flutter/material.dart';

class ReservationStatePage extends StatefulWidget {
  final User user;
  ReservationStatePage({this.user});
  @override
  _ReservationStatePageState createState() => _ReservationStatePageState();
}

class _ReservationStatePageState extends State<ReservationStatePage> {
  Future<bool> _getReservationFromUser() async {}
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF9EE1E5),
        title: Text(
          '예약 현황',
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
