import 'package:asgshighschool/data/user_data.dart';
import 'package:flutter/material.dart';

class DetailReservationStatePage extends StatefulWidget {
  final User user;
  final Map data;
  DetailReservationStatePage({this.user, this.data});
  @override
  _DetailReservationStatePageState createState() =>
      _DetailReservationStatePageState();
}

class _DetailReservationStatePageState
    extends State<DetailReservationStatePage> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, true);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xFF9EE1E5),
          title: Text(
            '예약 정보 [${widget.data['oID']}]',
            style: TextStyle(
                color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14),
          ),
          centerTitle: true,
          leading: IconButton(
              onPressed: () => Navigator.pop(context, true),
              icon: Icon(
                Icons.arrow_back,
                color: Colors.black,
              )),
        ),
      ),
    );
  }
}
