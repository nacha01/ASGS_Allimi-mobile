import 'package:asgshighschool/component/ThemeAppBar.dart';
import 'package:asgshighschool/data/user.dart';
import 'package:asgshighschool/games/RecordListPage.dart';
import 'package:asgshighschool/games/tic_tac_toe/TicTacToeGamePage.dart';
import 'package:flutter/material.dart';

import '../component/DefaultButtonComp.dart';
import 'memory_game/MemoryGamePage.dart';

class GameListPage extends StatefulWidget {
  final User? user;

  GameListPage({this.user});

  @override
  _GameListPageState createState() => _GameListPageState();
}

class _GameListPageState extends State<GameListPage> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
        appBar: ThemeAppBar(barTitle: '게임 목록'),
        body: GridView.count(
            childAspectRatio: (size.width * 0.5) / (size.height * 0.3),
            padding: EdgeInsets.all(size.width * 0.03),
            children: [
              _boardLayout(
                  title: '기억력 게임',
                  info:
                      '순발력과 기억력을 요구합니다. \n가장 최근에 출현한 도형을 클릭하여 제한시간 안에 최대한 많은 도형을 클릭하세요! ',
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
                  }),
              _boardLayout(
                  title: '틱택토',
                  info:
                      '1대1로 3x3 보드에서 X와 O로 차례대로 표시하여, 먼저 가로, 세로, 대각선으로 같은 기호를 놓으세요!\n\nBy 테라바이트 조민호',
                  press: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => TicTacToeGamePage()));
                  },
                  size: size)
            ],
            crossAxisCount: 2,
            mainAxisSpacing: size.height * 0.025,
            crossAxisSpacing: size.width * 0.01));
  }

  Widget _boardLayout(
      {String? title,
      String? info,
      required void Function() press,
      required Size size,
      void Function()? record}) {
    return Container(
        padding: EdgeInsets.all(size.width * 0.015),
        decoration: BoxDecoration(
            border: Border.all(width: 0.3, color: Colors.black),
            borderRadius: BorderRadius.circular(5)),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('$title',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              Text('$info',
                  style: TextStyle(fontSize: 12), textAlign: TextAlign.start),
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        border: Border.all(width: 0.3),
                        borderRadius: BorderRadius.circular(6),
                        color: Colors.orange),
                    child: IconButton(
                        onPressed: record,
                        icon: Icon(Icons.emoji_events_rounded))),
                Container(
                    width: size.width * 0.27,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        border: Border.all(width: 0.3),
                        borderRadius: BorderRadius.circular(6),
                        color: Colors.lightGreen),
                    child: DefaultButtonComp(
                        onPressed: press,
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Icon(Icons.play_arrow, color: Colors.black),
                              SizedBox(width: size.width * 0.008),
                              Text(
                                '플레이',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black),
                              )
                            ])))
              ])
            ]));
  }
}
