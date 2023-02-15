import 'package:asgshighschool/component/ThemeAppBar.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:asgshighschool/data/user.dart';

class MobileStudentCard extends StatefulWidget {
  MobileStudentCard({this.user});

  final User? user;

  @override
  _MobileStudentCardState createState() => _MobileStudentCardState();
}

class _MobileStudentCardState extends State<MobileStudentCard> {
  String? _prefixId = 'A';

  void onChanged(value) {
    print(value);
    setState(() {
      _prefixId = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
        appBar: ThemeAppBar(barTitle: '모바일 학생증'),
        body: Padding(
          padding: EdgeInsets.all(size.width * 0.02),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '사용자 아이디',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20.0),
                      ),
                      Text(
                        '${widget.user!.uid}',
                        style: TextStyle(fontSize: 20.0),
                      )
                    ]),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '이름',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 20.0),
                    ),
                    Text(
                      '${widget.user!.name}',
                      style: TextStyle(fontSize: 20.0),
                    )
                  ],
                ),
                Divider(
                  thickness: 2.0,
                ),
                RadioListTile(
                    title: const Text('출석'),
                    value: 'A',
                    groupValue: _prefixId,
                    onChanged: onChanged),
                RadioListTile(
                    title: const Text('우산'),
                    value: 'U',
                    groupValue: _prefixId,
                    onChanged: onChanged),
                Divider(
                  thickness: 2.0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(
                      child: QrImage(
                        data: '${_prefixId}_${widget.user!.uid}',
                        size: 250,
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ));
  }
}
