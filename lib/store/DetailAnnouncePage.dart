import 'package:asgshighschool/data/announce_data.dart';
import 'package:asgshighschool/data/user_data.dart';
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
                  onPressed: () {},
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
                      '${widget.announce.title}',
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
                child: Text('${widget.announce.writeDate}',
                    style: TextStyle(fontSize: 13, color: Colors.grey)),
              ),
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('작성자   ${widget.announce.writer}',
                        style: TextStyle(fontSize: 15)),
                    SizedBox(
                      width: size.width * 0.08,
                    ),
                    Text(
                      '조회수   ${widget.newView}',
                      style: TextStyle(fontSize: 15),
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
                  '${widget.announce.content}',
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
