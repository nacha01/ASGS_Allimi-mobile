import 'dart:ui';

import 'package:asgshighschool/data/user_data.dart';
import 'package:asgshighschool/main/RecordListPage.dart';
import 'package:asgshighschool/memoryGame/MemoryGamePAge.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class GameListPage extends StatefulWidget {
  final User user;
  GameListPage({this.user});
  @override
  _GameListPageState createState() => _GameListPageState();
}

class _GameListPageState extends State<GameListPage> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '게임 목록',
          style: TextStyle(color: Colors.black),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
        ),
        backgroundColor: Color(0xFF9EE1E5),
      ),
      body: GridView.count(
        childAspectRatio: (size.width * 0.35) / (size.height * 0.25),
        padding: EdgeInsets.all(size.width * 0.04),
        children: [
          _boardLayout(
              title: '기억력 게임',
              info:
                  '순발력과 기억력 게임으로, \n 가장 최근에 출현한 도형을 클릭하며, \n제한시간 안에 최대한 많은 도형을 클릭하세요 ',
              size: size,
              press: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => MemoryGamePage(
                              user: widget.user,
                            )));
              },
              record: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => RecordListPage(
                              user: widget.user,
                              gameCode: 1,
                            )));
              })
        ],
        crossAxisCount: 2,
        mainAxisSpacing: size.height * 0.025,
        crossAxisSpacing: size.width * 0.01,
      ),
    );
  }

  Widget _boardLayout(
      {String title,
      String info,
      void Function() press,
      Size size,
      void Function() record}) {
    return Container(
      padding: EdgeInsets.all(size.width * 0.02),
      decoration: BoxDecoration(
          border: Border.all(width: 0.3, color: Colors.black),
          borderRadius: BorderRadius.circular(5)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$title',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          Text(
            '$info',
            textAlign: TextAlign.center,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      border: Border.all(width: 0.3),
                      borderRadius: BorderRadius.circular(6),
                      color: Colors.orange),
                  child: IconButton(
                      onPressed: record, icon: Icon(Icons.emoji_events_rounded))),
              Container(
                width: size.width * 0.27,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    border: Border.all(width: 0.3),
                    borderRadius: BorderRadius.circular(6),
                    color: Colors.lightGreen),
                child: TextButton(
                  onPressed: press,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Icon(Icons.play_arrow),
                        Text(
                          '플레이',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        )
                      ]),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
