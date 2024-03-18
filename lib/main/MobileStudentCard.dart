import 'dart:convert';

import 'package:asgshighschool/api/ApiUtil.dart';
import 'package:asgshighschool/component/ThemeAppBar.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:asgshighschool/data/user.dart';
import 'package:http/http.dart' as http;
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
  String _dateString = "";
  String _state = "";
  String _cumulString = "";

  void onChanged(StudentCardPurpose? purpose) {
    setState(() {
      _prefixId = purpose ?? StudentCardPurpose.ATTENDANCE;
    });
  }

  Future<void> _getStudiedTime() async {
    String url =
        "${ApiUtil.API_HOST}arlimi_getStudiedTime.php?uid=${widget.user!.uid}";

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      var json = jsonDecode(response.body);
      List<String> dates = json['date'].toString().split(" ");
      List<String> date = dates[0].split("-");
      List<String> time = dates[1].split(":");

      setState(() {
        _dateString =
            "${date[0]}년 ${date[1]}월 ${date[2]}일 ${time[0]}시 ${time[1]}분";
        _state = json['state'].toString() == "ENTRANCE" ? "입실" : "퇴실";
        List<String> cumul = json['cumul_time'].toString().split(":");
        _cumulString = "${cumul[0]}시간 ${cumul[1]}분";
      });
    } else if (response.statusCode == 404) {
      setState(() {
        _state = "없음";
        _cumulString = "00시간 00분";
      });
    }
  }

  @override
  void initState() {
    _isSelected = [_isAttendance, _isUmbrella];
    _getStudiedTime();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
        appBar: ThemeAppBar(barTitle: '모바일 학생증'),
        body: Padding(
          padding: EdgeInsets.all(size.width * 0.03),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('사용자 정보',
                  style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
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
                          fontSize: 15.0,
                        ),
                        textAlign: TextAlign.left,
                      ),
                      Text(
                        '이름: ',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15.0),
                        textAlign: TextAlign.left,
                      ),
                      Text(
                        '학번: ',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15.0),
                        textAlign: TextAlign.left,
                      ),
                    ],
                  ),
                  SizedBox(
                    width: size.width * 0.01,
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
                height: size.height * 0.01,
              ),
              Divider(),
              Text(
                '모바일 학생증 QR',
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: size.height * 0.01,
              ),
              _isAttendance
                  ? Padding(
                      padding: EdgeInsets.all(size.width * 0.01),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '오늘 마지막 상태: ',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                              Text(
                                _dateString,
                                style: TextStyle(fontSize: 12),
                              ),
                              Text(
                                _state,
                                style: TextStyle(
                                    color: _state == "입실"
                                        ? Colors.green
                                        : Colors.red,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold),
                              )
                            ],
                          ),
                          Text(
                            '오늘 누적 자습시간:    $_cumulString',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                          SizedBox(
                            height: size.height * 0.01,
                          ),
                          Text(
                            '* 누적시간은 퇴실 후의 최종 누적 시간을 보여줍니다.',
                            style: TextStyle(fontSize: 9),
                          ),
                          Text(
                              '* 입실 후 출입 가능한 시간 내에 퇴실 처리하지 않으면 자동으로 퇴실 처리되며 누적 시간이 적용되지 않습니다.',
                              style: TextStyle(fontSize: 9))
                        ],
                      ),
                    )
                  : SizedBox(),
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
