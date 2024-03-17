import 'package:asgshighschool/component/ThemeAppBar.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:asgshighschool/data/user.dart';

import '../data/status.dart';

enum StudentCardPurpose { ATTENDANCE, UMBRELLA }

class MobileStudentCard extends StatefulWidget {
  MobileStudentCard({this.user});

  final User? user;

  @override
  _MobileStudentCardState createState() => _MobileStudentCardState();
}

class _MobileStudentCardState extends State<MobileStudentCard> {
  StudentCardPurpose _prefixId = StudentCardPurpose.ATTENDANCE;
  late List<bool> _isSelected;
  bool _isAttendance = true;
  bool _isUmbrella = false;

  void onChanged(StudentCardPurpose? purpose) {
    setState(() {
      _prefixId = purpose ?? StudentCardPurpose.ATTENDANCE;
    });
  }

  @override
  void initState() {
    _isSelected = [_isAttendance, _isUmbrella];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
        appBar: ThemeAppBar(barTitle: '모바일 학생증'),
        body: Padding(
          padding: EdgeInsets.all(size.width * 0.02),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('사용자 정보',
                  style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold)),
              Divider(),
              SizedBox(
                height: size.height * 0.01,
              ),
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '아이디: ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0,
                        ),
                        textAlign: TextAlign.left,
                      ),
                      Text(
                        '이름: ',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16.0),
                        textAlign: TextAlign.left,
                      ),
                      Text(
                        '학번: ',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16.0),
                        textAlign: TextAlign.left,
                      ),
                    ],
                  ),
                  SizedBox(
                    width: size.width * 0.02,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${widget.user!.uid}',
                          style: TextStyle(fontSize: 16.0),
                        ),
                        Text(
                          '${widget.user!.name} [${Status.statusList[widget.user!.identity - 1]}]',
                          style: TextStyle(fontSize: 16.0),
                        ),
                        Text(
                          '${widget.user!.studentId}',
                          style: TextStyle(fontSize: 16.0),
                        )
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: size.height * 0.02,
              ),
              Divider(),
              Text(
                '모바일 학생증 QR',
                style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: size.height * 0.01,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ToggleButtons(
                    constraints: BoxConstraints.expand(
                        width: (size.width / 2) - size.width * 0.05),
                    children: [Text('출석'), Text('우산')],
                    isSelected: _isSelected,
                    onPressed: (index) {
                      if (index == 0) {
                        _isAttendance = true;
                        _isUmbrella = false;
                        _prefixId = StudentCardPurpose.ATTENDANCE;
                      } else {
                        _isAttendance = false;
                        _isUmbrella = true;
                        _prefixId = StudentCardPurpose.UMBRELLA;
                      }
                      setState(() {
                        _isSelected = [_isAttendance, _isUmbrella];
                      });
                    },
                  ),
                ],
              ),
              Expanded(
                child: Center(
                  child: widget.user!.identity != 1
                      ? Text(
                          '재학생이 아닙니다.',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        )
                      : QrImage(
                          data:
                              '${_prefixId.name}_${widget.user!.uid}_${widget.user!.studentId}_${widget.user!.name}',
                          size: 250,
                        ),
                ),
              )
            ],
          ),
        ));
  }
}
