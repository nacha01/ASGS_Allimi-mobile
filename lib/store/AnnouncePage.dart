import 'package:asgshighschool/data/user_data.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AnnouncePage extends StatefulWidget {
  AnnouncePage({this.user});
  final User user;
  @override
  _AnnouncePageState createState() => _AnnouncePageState();
}

class _AnnouncePageState extends State<AnnouncePage> {
  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF9EE1E5),
        title: Text(
          '나래 소식',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: SizedBox(),
        actions: [IconButton(onPressed: () {}, icon: Icon(Icons.search,color: Colors.black,))],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                _announceItemLayout(
                    title: '테1',
                    writer: '관리자',
                    date: '2021-08-27',
                    isNew: true,
                    size: size),
                _announceItemLayout(
                    title: '테2',
                    writer: '관리자',
                    date: '2021-08-27',
                    isNew: true,
                    size: size),
                _announceItemLayout(
                    title: '테3',
                    writer: '관리자',
                    date: '2021-08-27',
                    isNew: true,
                    size: size)
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _announceItemLayout(
      {String title, String writer, String date, bool isNew, Size size}) {
    return Container(
      width: size.width * 0.9,
      height: size.height * 0.1,
      decoration: BoxDecoration(
          border: Border.all(width: 1, color: Colors.black),
          borderRadius: BorderRadius.circular(9)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: size.height * 0.1 * 0.4,
            child: Row(
              children: [
                isNew
                    ? Container(
                        alignment: Alignment.center,
                        child: Text('신규'),
                        decoration: BoxDecoration(
                            color: Colors.yellowAccent[100],
                            border: Border.all(
                                width: 1, color: Colors.redAccent[200])),
                        width: size.width * 0.1,
                      )
                    : SizedBox(
                        width: size.width * 0.1,
                      ),

                VerticalDivider(
                  thickness: 2,
                  color: Colors.grey,
                ),
                Container(
                  child: Text(writer),
                  width: size.width * 0.15,
                ),
                VerticalDivider(
                  thickness: 2,
                  color: Colors.grey,
                ),
                Container(
                  child: Text(date),
                  width: size.width * 0.3,
                ),
              ],
            ),
          ),
          Divider(
            thickness: 2,
          ),
          Text(title)
        ],
      ),
    );
  }
}
