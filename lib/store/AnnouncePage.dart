import 'dart:convert';
import 'dart:ui';

import 'package:asgshighschool/data/announce_data.dart';
import 'package:asgshighschool/data/renewUser_data.dart';
import 'package:asgshighschool/data/user_data.dart';
import 'package:asgshighschool/store/DetailAnnouncePage.dart';
import 'package:asgshighschool/storeAdmin/AddAnnouncePage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class AnnouncePage extends StatefulWidget {
  AnnouncePage({this.user});
  final User user;
  @override
  _AnnouncePageState createState() => _AnnouncePageState();
}

class _AnnouncePageState extends State<AnnouncePage> {
  List<Announce> _announceList = [];

  Future<bool> _getAnnounceRequest() async {
    String url = 'http://nacha01.dothome.co.kr/sin/arlimi_getAnnounce.php';
    final response = await http.get(url);
    if (response.statusCode == 200) {
      String result = utf8
          .decode(response.bodyBytes)
          .replaceAll(
              '<meta http-equiv="Content-Type" content="text/html; charset=utf-8">',
              '')
          .trim();
      List anList = json.decode(result);
      _announceList.clear();
      for (int i = 0; i < anList.length; ++i) {
        _announceList.add(Announce.fromJson(json.decode(anList[i])));
      }
      setState(() {});
      return true;
    } else {
      return false;
    }
  }

  Future<int> _increaseViewCountRequest(int anID) async {
    String uri =
        'http://nacha01.dothome.co.kr/sin/arlimi_increaseViewCount.php';
    final response = await http.get(uri + '?anID=$anID');

    if (response.statusCode == 200) {
      print(response.body);
      String result = utf8
          .decode(response.bodyBytes)
          .replaceAll(
              '<meta http-equiv="Content-Type" content="text/html; charset=utf-8">',
              '')
          .trim();
      return int.parse(result);
    } else {
      return -1;
    }
  }

  bool _compareDateIsNew(String cmpDate) {
    int diff = int.parse(
        DateTime.now().difference(DateTime.parse(cmpDate)).inDays.toString());
    return diff < 3 ? true : false;
  }

  @override
  void initState() {
    _getAnnounceRequest();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    var providedUser = Provider.of<RenewUserData>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF9EE1E5),
        title: Text(
          '두루두루 소식',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: SizedBox(),
        actions: [
          IconButton(
              onPressed: () {},
              icon: Icon(
                Icons.search,
                color: Colors.black,
              ))
        ],
      ),
      body: Center(
        child: RefreshIndicator(
          onRefresh: _getAnnounceRequest,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                width: size.width,
                height: size.height * 0.1,
                child: Column(
                  children: [
                    //brief 설명 적는 곳
                    Text('이 페이지의 간략한 설명 적는 란')
                  ],
                ),
              ),
              Divider(
                indent: 10,
                endIndent: 10,
                thickness: 1,
              ),
              SizedBox(
                height: size.height * 0.01,
              ),
              providedUser.user.isAdmin
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Container(
                            height: size.height * 0.05,
                            width: size.width * 0.28,
                            decoration: BoxDecoration(
                                border:
                                    Border.all(width: 2, color: Colors.black54),
                                borderRadius: BorderRadius.circular(8)),
                            child: FlatButton(
                                onPressed: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => AddAnnouncePage(
                                              user: providedUser.user,
                                            ))),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Icon(Icons.add),
                                    Text('글 쓰기'),
                                  ],
                                )),
                          ),
                        ),
                        Divider(
                          thickness: 1,
                          endIndent: 10,
                          indent: 10,
                        ),
                      ],
                    )
                  : SizedBox(),
              _announceList.length == 0
                  ? SingleChildScrollView(
                      physics: AlwaysScrollableScrollPhysics(),
                      child: Container(
                          alignment: Alignment.center,
                          margin: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(width: 1, color: Colors.black54),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          height: size.height * 0.2,
                          child: Text(
                            '공지사항이 없습니다!\n새로고침하려면 이 박스를 아래로 당겨주세요!',
                            textAlign: TextAlign.center,
                          )),
                    )
                  : Expanded(
                      child: ListView.builder(
                        itemBuilder: (context, index) => _announceItemLayout(
                            title: _announceList[index].title,
                            writer: _announceList[index].writer,
                            date: _announceList[index].writeDate,
                            isNew: _compareDateIsNew(
                                _announceList[index].writeDate),
                            size: size,
                            announce: _announceList[index]),
                        itemCount: _announceList.length,
                      ),
                    )
            ],
          ),
        ),
      ),
    );
  }

  Widget _announceItemLayout(
      {String title,
      String writer,
      String date,
      bool isNew,
      Size size,
      Announce announce}) {
    return GestureDetector(
      onTap: () async {
        int renew = await _increaseViewCountRequest(announce.announceID);
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => DetailAnnouncePage(
                      announce: announce,
                      user: widget.user,
                      isNew: isNew,
                      newView: renew,
                    )));
      },
      child: Container(
        width: size.width * 0.88,
        height: size.height * 0.12,
        margin: EdgeInsets.all(10),
        decoration: BoxDecoration(
            color: Colors.grey[200],
            border: Border.all(width: 1, color: Colors.black38),
            borderRadius: BorderRadius.circular(9)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: size.height * 0.1 * 0.4,
              child: Row(
                children: [
                  SizedBox(
                    width: size.width * 0.01,
                  ),
                  isNew
                      ? Container(
                          alignment: Alignment.center,
                          child: Text(
                            '신규',
                            style: TextStyle(
                                fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.yellowAccent[100],
                              border: Border.all(
                                  width: 1, color: Colors.redAccent[200])),
                          width: size.width * 0.1,
                        )
                      : SizedBox(
                          width: size.width * 0.1,
                        ),
                  VerticalDivider(
                    thickness: 1,
                    color: Colors.grey,
                  ),
                  Container(
                    child: Text(writer,
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    padding: EdgeInsets.symmetric(horizontal: 5),
                  ),
                  VerticalDivider(
                    thickness: 1,
                    color: Colors.grey,
                  ),
                  Expanded(
                    child: Container(
                      child: Text(
                        '$date',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 13),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Divider(
              thickness: 2,
            ),
            Container(
              alignment: Alignment.center,
              child: Text(title,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              height: size.height * 0.1 * 0.4,
            )
          ],
        ),
      ),
    );
  }
}
