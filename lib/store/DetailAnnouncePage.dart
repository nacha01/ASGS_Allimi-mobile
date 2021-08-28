import 'package:asgshighschool/data/announce_data.dart';
import 'package:asgshighschool/data/user_data.dart';
import 'package:asgshighschool/storeAdmin/AddAnnouncePage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
                  onPressed: () {},
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
