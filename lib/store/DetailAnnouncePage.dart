import 'package:asgshighschool/data/announce_data.dart';
import 'package:asgshighschool/data/user_data.dart';
import 'package:asgshighschool/storeAdmin/AddAnnouncePage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

class DetailAnnouncePage extends StatefulWidget {
  DetailAnnouncePage({this.announce, this.user, this.isNew, this.newView});
  final Announce announce;
  final User user;
  final bool isNew;
  final int newView;
  @override
  _DetailAnnouncePageState createState() => _DetailAnnouncePageState();
}

class _DetailAnnouncePageState extends State<DetailAnnouncePage> {
  var _rcvResult;
  bool _isUsable = false;
  Announce _temp;
  TextEditingController _adminKeyController = TextEditingController();

  Future<bool> showToast(String message, bool fail) {
    return Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        backgroundColor: Colors.white,
        gravity: ToastGravity.BOTTOM,
        textColor: fail ? Colors.deepOrange : Colors.black);
  }

  /// 관리자임을 인증하는 HTTP 요청
  /// @param : HTTP GET : UID 값과 ADMIN KEY 값
  /// @result : 관리자 인증이 되었는지에 대한 bool 값
  Future<bool> _certifyAdminAccess() async {
    String uri = 'http://nacha01.dothome.co.kr/sin/arlimi_adminCertified.php';
    final response = await http
        .get(uri + '?uid=${widget.user.uid}&key=${_adminKeyController.text}');

    if (response.statusCode == 200) {
      if (response.body.contains('CERTIFIED')) {
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  void _terminateScreen() {
    Navigator.pop(context);
  }

  Future<bool> _deleteAnnounceRequest(int announceID) async {
    String uri = 'http://nacha01.dothome.co.kr/sin/arlimi_deleteAnnounce.php';
    final response = await http.get(uri + '?anID=$announceID');
    if (response.statusCode == 200) {
      if (response.body.contains('DELETED')) {
        return true;
      } else {
        return false;
      }
    }
    return false;
  }

  @override
  void initState() {
    _temp = widget.announce;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF9EE1E5),
        title: Text(
          '공지사항',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          widget.user.isAdmin
              ? IconButton(
                  icon: Icon(
                    Icons.update,
                    color: Colors.black,
                  ),
                  onPressed: () async {
                    final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AddAnnouncePage(
                                  user: widget.user,
                                  announce: _temp,
                                  isUpdate: true,
                                )));
                    setState(() {
                      _rcvResult = result;
                      if (_rcvResult == null) {
                        _isUsable = false;
                        return;
                      }
                      if (_rcvResult is Announce) {
                        _isUsable = true;
                        _temp = _rcvResult as Announce;
                      }
                    });
                  },
                )
              : SizedBox(),
          widget.user.isAdmin
              ? IconButton(
                  icon: Icon(Icons.delete, color: Colors.black),
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                              shape: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                      color: Colors.black, width: 2)),
                              title: Icon(
                                Icons.warning_amber_outlined,
                                color: Colors.red,
                                size: 60,
                              ),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '※이 글을 삭제하시겠습니까?',
                                    textAlign: TextAlign.center,
                                  ),
                                  Text(
                                    '[${_isUsable ? (_rcvResult as Announce).title : _temp.title}]',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 17),
                                  )
                                ],
                              ),
                              actions: [
                                FlatButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text('아니요')),
                                FlatButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      showDialog(
                                          context: context,
                                          builder: (ctx) => AlertDialog(
                                                title: Text('관리자 키 Key 입력'),
                                                content: Container(
                                                  decoration: BoxDecoration(
                                                      border: Border.all(
                                                          width: 1,
                                                          color: Colors
                                                              .orange[200]),
                                                      color: Colors.blue[100]),
                                                  child: TextField(
                                                    inputFormatters: [
                                                      UpperCaseTextFormatter()
                                                    ],
                                                    decoration: InputDecoration(
                                                        border:
                                                            InputBorder.none,
                                                        hintText: 'Admin Key'),
                                                    controller:
                                                        _adminKeyController,
                                                  ),
                                                ),
                                                actions: [
                                                  FlatButton(
                                                      onPressed: () =>
                                                          Navigator.pop(ctx),
                                                      child: Text('취소')),
                                                  FlatButton(
                                                      onPressed: () async {
                                                        var result =
                                                            await _certifyAdminAccess(); // 어드민 키 인증
                                                        if (result) {
                                                          var res = await _deleteAnnounceRequest(_isUsable
                                                              ? (_rcvResult
                                                                      as Announce)
                                                                  .announceID
                                                              : _temp
                                                                  .announceID); // DB에서 상품 삭제
                                                          if (res) {
                                                            Navigator.pop(ctx);
                                                            showToast(
                                                                '삭제가 완료되었습니다. 목록을 새로고침 바랍니다.',
                                                                false);
                                                            await Future.delayed(
                                                                Duration(
                                                                    milliseconds:
                                                                        500));
                                                            _terminateScreen();
                                                          } else {
                                                            Navigator.pop(ctx);
                                                            showToast(
                                                                '삭제가 실패되었습니다.',
                                                                true);
                                                          }
                                                        } else {
                                                          showToast(
                                                              '인증에 실패하였습니다!',
                                                              true);
                                                        }
                                                      },
                                                      child: Text('인증'))
                                                ],
                                              ));
                                    },
                                    child: Text('예'))
                              ],
                            ));
                  },
                )
              : SizedBox(),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      '${_isUsable ? (_rcvResult as Announce).title : _temp.title}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ),
                    ),
                    SizedBox(
                      width: size.width * 0.05,
                    ),
                    widget.isNew
                        ? Container(
                            padding: EdgeInsets.all(4),
                            child: Text(
                              'New',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                            decoration: BoxDecoration(
                                border: Border.all(
                                    width: 2, color: Colors.pinkAccent),
                                borderRadius: BorderRadius.circular(8)),
                          )
                        : SizedBox()
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Text(
                    '${_isUsable ? (_rcvResult as Announce).writeDate : _temp.writeDate}',
                    style: TextStyle(fontSize: 13, color: Colors.grey)),
              ),
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                        '작성자  ${_isUsable ? (_rcvResult as Announce).writer : _temp.writer}',
                        style: TextStyle(fontSize: 14)),
                    SizedBox(
                      width: size.width * 0.08,
                    ),
                    Text(
                      '조회  ${widget.newView}',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
              Divider(
                thickness: 1,
              ),
              Container(
                padding: EdgeInsets.all(6),
                child: Text(
                  '${_isUsable ? (_rcvResult as Announce).content : _temp.content}',
                  style: TextStyle(fontSize: 17),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
