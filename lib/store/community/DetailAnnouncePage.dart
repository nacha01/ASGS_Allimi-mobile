import 'package:asgshighschool/data/announce.dart';
import 'package:asgshighschool/data/user.dart';
import 'package:asgshighschool/storeAdmin/AdminUtil.dart';
import 'package:asgshighschool/util/ToastMessage.dart';
import '../../api/ApiUtil.dart';
import '../../component/DefaultButtonComp.dart';
import '../../component/ThemeAppBar.dart';
import '../../storeAdmin/post/AddAnnouncePage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class DetailAnnouncePage extends StatefulWidget {
  DetailAnnouncePage({this.announce, this.user, this.isNew, this.newView});

  final Announce? announce;
  final User? user;
  final bool? isNew;
  final int? newView;

  @override
  _DetailAnnouncePageState createState() => _DetailAnnouncePageState();
}

class _DetailAnnouncePageState extends State<DetailAnnouncePage> {
  var _rcvResult;
  bool _isUsable = false;
  Announce? _temp;
  TextEditingController _adminKeyController = TextEditingController();

  /// 현재 페이지를 강제종료하는 작업
  void _terminateScreen({bool isDelete = false}) {
    Navigator.pop(context, true);
  }

  /// parameter의 ID를 가진 공지사항 데이터에 대해 삭제 요청하는 작업
  /// @response : 성공적으로 삭제 시 'DELETE'
  Future<bool> _deleteAnnounceRequest(int announceID) async {
    String url = '${ApiUtil.API_HOST}arlimi_deleteAnnounce.php';
    final response = await http.get(Uri.parse(url + '?anID=$announceID'));
    if (response.statusCode == 200) {
      if (response.body.contains('DELETED')) {
        return true;
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
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, true);
        return false;
      },
      child: Scaffold(
        appBar: ThemeAppBar(
          barTitle: '공지사항',
          leadingClick: () => Navigator.pop(context, true),
          actions: [
            widget.user!.isAdmin
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
                          _temp = _rcvResult as Announce?;
                        }
                      });
                    },
                  )
                : SizedBox(),
            widget.user!.isAdmin
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
                                      '[${_isUsable ? (_rcvResult as Announce).title : _temp!.title}]',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 17),
                                    )
                                  ],
                                ),
                                actions: [
                                  DefaultButtonComp(
                                      onPressed: () => Navigator.pop(context),
                                      child: Text('아니요')),
                                  DefaultButtonComp(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        AdminUtil.showCertifyDialog(
                                            context: context,
                                            keyController: _adminKeyController,
                                            admin: widget.user!,
                                            afterProcess: () async {
                                              var res =
                                                  await _deleteAnnounceRequest(
                                                      _isUsable
                                                          ? (_rcvResult
                                                                  as Announce)
                                                              .announceID
                                                          : _temp!
                                                              .announceID); // DB에서 상품 삭제
                                              if (res) {
                                                ToastMessage.show(
                                                    '삭제가 완료되었습니다.');

                                                await Future.delayed(Duration(
                                                    milliseconds: 500));
                                                _terminateScreen(
                                                    isDelete: true);
                                              } else {
                                                ToastMessage.show(
                                                    '삭제에 실패했습니다.');
                                              }
                                            });
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
                        '${_isUsable ? (_rcvResult as Announce).title : _temp!.title}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),
                      ),
                      SizedBox(
                        width: size.width * 0.05,
                      ),
                      widget.isNew!
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
                      '${_isUsable ? (_rcvResult as Announce).writeDate : _temp!.writeDate}',
                      style: TextStyle(fontSize: 13, color: Colors.grey)),
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                          '작성자  ${_isUsable ? (_rcvResult as Announce).writer : _temp!.writer}',
                          style: TextStyle(fontSize: 14)),
                      SizedBox(
                        width: size.width * 0.12,
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
                    '${_isUsable ? (_rcvResult as Announce).content : _temp!.content}',
                    style: TextStyle(fontSize: 17),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
