import 'dart:ui';

import 'package:asgshighschool/data/user_data.dart';
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
              info: '순발력과 기억력으로 이미 클릭한 도형을 기억하며, 시간안에 최대한 많은 도형을 클릭하세요 ',
              size: size,
              press: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => MemoryGamePage(
                              user: widget.user,
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
      {String title, String info, void Function() press, Size size}) {
    return Container(
      padding: EdgeInsets.all(size.width * 0.02),
      decoration: BoxDecoration(
          border: Border.all(width: 0.5, color: Colors.black),
          borderRadius: BorderRadius.circular(3)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$title',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          Text('$info'),
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
                      onPressed: () {}, icon: Icon(Icons.military_tech))),
              Container(
                width: size.width * 0.27,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    border: Border.all(width: 0.3),
                    borderRadius: BorderRadius.circular(6),
                    color: Colors.lightGreen),
                child: FlatButton(
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
