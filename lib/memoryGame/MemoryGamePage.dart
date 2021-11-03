import 'dart:async';
import 'dart:ui';

import 'package:asgshighschool/data/user_data.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'dart:math';

import 'DrawCircle.dart';
import 'DrawRectangle.dart';
import 'DrawTriangle.dart';

class MemoryGamePage extends StatefulWidget {
  final User user;
  MemoryGamePage({this.user});
  @override
  _MemoryGamePageState createState() => _MemoryGamePageState();
}

class _MemoryGamePageState extends State<MemoryGamePage> {
  List<Widget> _shapeList = [];
  List<List> _shapeSize = [];
  List<double> _triangleSizes = [25.0, 30.0, 35.0];
  List<double> _circleSizes = [15.0, 20.0, 25.0];
  List<double> _rectSizes = [25.0, 30.0, 35.0];
  List<double> _lifeOpacityList = [1.0, 1.0, 1.0];
  Timer _timer;
  int _start = 30;
  int _currentOpacityIndex = 2;
  bool _isStart = false;

  @override
  void initState() {
    super.initState();
    _shapeSize.add(_triangleSizes);
    _shapeSize.add(_circleSizes);
    _shapeSize.add(_rectSizes);
    _addShape();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _startTimer() {
    const oneSec = const Duration(seconds: 1);
    _timer = Timer.periodic(oneSec, (timer) {
      if (_start == 0) {
        setState(() {
          timer.cancel();
        });
        _showGameOverDialog();
      } else {
        setState(() {
          _start--;
        });
      }
    });
  }

  void _reInitializeGameSetting() {
    _start = 30;
    _shapeList.clear();
    _addShape();
    _currentOpacityIndex = 2;
    _lifeOpacityList = [1.0, 1.0, 1.0];
  }

  Color _getRandomColor() {
    var rv = Random().nextInt(5) + 1;
    switch (rv) {
      case 1:
        return Colors.red;
      case 2:
        return Colors.blue;
      case 3:
        return Colors.green;
      case 4:
        return Colors.white;
      case 5:
        return Colors.yellow;
      default:
        return Colors.grey;
    }
  }

  void _addShape() {
    var shapeRv = Random().nextInt(3);
    var sizeRv = Random().nextInt(3);
    Widget obj;
    switch (shapeRv) {
      case 0: // 삼각형
        obj = _getTriangleObject(
            size: _shapeSize[shapeRv][sizeRv],
            color: _getRandomColor(),
            posKey: GlobalKey());
        break;
      case 1: // 원
        obj = _getCircleObject(
            size: _shapeSize[shapeRv][sizeRv],
            color: _getRandomColor(),
            posKey: GlobalKey());
        break;
      case 2: // 사각형
        obj = _getRectangleObject(
            size: _shapeSize[shapeRv][sizeRv],
            color: _getRandomColor(),
            posKey: GlobalKey());
        break;
    }
    _shapeList.add(obj);
  }

  Alignment _getRandomLocation() {
    while (true) {
      int x = Random().nextInt(200);
      int y = Random().nextInt(200);
      double dx = (x - 100) / 100.00;
      double dy = (y - 100) / 100.00;

      var tmp = Alignment(dx, dy);
      bool isIntersect = false;

      for (int i = 0; i < _shapeList.length; ++i) {
        var a = _shapeList[i] as Align;
        if (tmp.toString() == a.alignment.toString()) {
          isIntersect = true;
        }
      }
      if (!isIntersect) return Alignment(dx, dy);
    }
  }

  void _terminateScreen() {
    Navigator.pop(this.context);
  }

  void _showGameOverDialog() {
    showDialog(
        barrierDismissible: false, // 외부 터치로 인해 종료되는 상황 방지
        context: context,
        builder: (ctx) => AlertDialog(
              contentPadding: EdgeInsets.all(8),
              actionsPadding: EdgeInsets.all(5),
              title: Text(
                'Game Over!',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                    fontSize: 22),
                textAlign: TextAlign.center,
              ),
              content: Text(
                '최종 점수 : ${_shapeList.length - 1}점',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.purpleAccent),
                textAlign: TextAlign.center,
              ),
              actions: [
                FlatButton(
                    padding: EdgeInsets.all(0),
                    onPressed: () {
                      setState(() {
                        _reInitializeGameSetting();
                      });
                      Navigator.pop(ctx);
                    },
                    child: Text(
                      '다시하기',
                      style: TextStyle(
                          color: Colors.lightBlue, fontWeight: FontWeight.bold),
                    )),
                FlatButton(
                    padding: EdgeInsets.all(0),
                    onPressed: () {
                      Navigator.pop(ctx);
                      _terminateScreen();
                    },
                    child: Text('나가기',
                        style: TextStyle(
                            color: Colors.lightBlue,
                            fontWeight: FontWeight.bold))),
              ],
            ));
  }

  Widget _getTriangleObject({double size, Color color, Key posKey}) {
    return Align(
      key: posKey,
      alignment: _getRandomLocation(),
      child: GestureDetector(
        onTap: () {
          if (_shapeList.length == 1) {
            _startTimer();
          }
          if (posKey == _shapeList[_shapeList.length - 1].key) {
            setState(() {
              _addShape();
            });
          } else {
            setState(() {
              _lifeOpacityList[_currentOpacityIndex--] = 0.0;
            });
            if (_currentOpacityIndex == -1) {
              setState(() {
                _timer.cancel();
              });
              _showGameOverDialog();
            }
          }
        },
        child: CustomPaint(
          size: Size(size, size),
          painter: TriangleShape(color),
        ),
      ),
    );
  }

  Widget _getCircleObject({double size, Color color, Key posKey}) {
    return Align(
      key: posKey,
      alignment: _getRandomLocation(),
      child: GestureDetector(
        onTap: () {
          if (_shapeList.length == 1) {
            _startTimer();
          }
          if (posKey == _shapeList[_shapeList.length - 1].key) {
            setState(() {
              _addShape();
            });
          } else {
            setState(() {
              _lifeOpacityList[_currentOpacityIndex--] = 0.0;
            });
            if (_currentOpacityIndex == -1) {
              setState(() {
                _timer.cancel();
              });
              _showGameOverDialog();
            }
          }
        },
        child: CustomPaint(
          size: Size(size * 2, size * 2),
          painter: CircleShape(color, size),
        ),
      ),
    );
  }

  Widget _getRectangleObject({double size, Color color, Key posKey}) {
    return Align(
      key: posKey,
      alignment: _getRandomLocation(),
      child: GestureDetector(
        onTap: () {
          if (_shapeList.length == 1) {
            _startTimer();
          }
          if (posKey == _shapeList[_shapeList.length - 1].key) {
            setState(() {
              _addShape();
            });
          } else {
            setState(() {
              _lifeOpacityList[_currentOpacityIndex--] = 0.0;
            });
            if (_currentOpacityIndex == -1) {
              setState(() {
                _timer.cancel();
              });
              _showGameOverDialog();
            }
          }
        },
        child: CustomPaint(
          painter: RectangleShape(color, size),
          size: Size(size, size),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Memory Game',
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
      body: Column(
        children: [
          Container(
            width: size.width,
            height: size.height * 0.08,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: size.width * 0.4,
                  height: size.height * 0.1 * 0.7,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3),
                    border: Border.all(width: 1, color: Colors.black),
                  ),
                  child: Row(
                    children: [
                      Container(
                        child: Icon(Icons.face_rounded),
                      ),
                      Container(
                        height: size.height * 0.1 * 0.7,
                        width: size.width * 0.4 * 0.01,
                        color: Colors.black,
                      ),
                      SizedBox(
                        width: size.width * 0.03,
                      ),
                      Opacity(
                        opacity: _lifeOpacityList[0],
                        child: Icon(
                          Icons.favorite,
                          color: Colors.pinkAccent,
                          size: size.width * 0.08,
                        ),
                      ),
                      Opacity(
                        opacity: _lifeOpacityList[1],
                        child: Icon(
                          Icons.favorite,
                          color: Colors.pinkAccent,
                          size: size.width * 0.08,
                        ),
                      ),
                      Opacity(
                        opacity: _lifeOpacityList[2],
                        child: Icon(
                          Icons.favorite,
                          color: Colors.pinkAccent,
                          size: size.width * 0.08,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: size.width * 0.05,
                ),
                Container(
                  width: size.width * 0.24,
                  height: size.height * 0.1 * 0.7,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3),
                      border: Border.all(width: 1, color: Colors.black)),
                  child: Row(
                    children: [
                      Container(
                        child: Icon(
                          Icons.star,
                          color: Colors.yellow,
                        ),
                      ),
                      Container(
                        height: size.height * 0.1 * 0.7,
                        width: size.width * 0.24 * 0.01,
                        color: Colors.black,
                      ),
                      Expanded(
                          child: Center(
                              child: Text(
                        '${_shapeList.length - 1}',
                        style: TextStyle(
                            fontSize: 19, fontWeight: FontWeight.bold),
                      )))
                    ],
                  ),
                ),
                SizedBox(
                  width: size.width * 0.05,
                ),
                Container(
                  width: size.width * 0.22,
                  height: size.height * 0.1 * 0.7,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3),
                      border: Border.all(width: 1, color: Colors.black)),
                  child: Row(
                    children: [
                      Container(
                        child: Icon(
                          Icons.timer,
                          color: Colors.red,
                        ),
                      ),
                      Container(
                        height: size.height * 0.1 * 0.7,
                        width: size.width * 0.22 * 0.01,
                        color: Colors.black,
                      ),
                      Expanded(
                          child: Center(
                        child: Text('$_start',
                            style: TextStyle(
                                fontSize: 19, fontWeight: FontWeight.bold)),
                      ))
                    ],
                  ),
                ),
              ],
            ),
          ),
          Divider(
            thickness: 2,
          ),
          Expanded(
            child: Container(
              color: Colors.black,
              width: size.width,
              padding: EdgeInsets.all(size.width * 0.02),
              child: Stack(children: _shapeList),
            ),
          ),
        ],
      ),
    );
  }
}
