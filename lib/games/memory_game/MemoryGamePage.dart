import 'dart:async';
import 'package:asgshighschool/api/ApiUtil.dart';
import 'package:asgshighschool/data/user.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import '../../component/DefaultButtonComp.dart';
import '../../component/ThemeAppBar.dart';
import 'shapes/DrawCircle.dart';
import 'shapes/DrawRectangle.dart';
import 'shapes/DrawTriangle.dart';
import 'package:http/http.dart' as http;

class MemoryGamePage extends StatefulWidget {
  final User? user;

  MemoryGamePage({this.user});

  @override
  _MemoryGamePageState createState() => _MemoryGamePageState();
}

class _MemoryGamePageState extends State<MemoryGamePage> {
  List<Widget> _shapeList = []; // 생성된 도형들을 담는 리스트
  List<List> _shapeSize = []; // 원, 사각형, 삼각형 크기 리스트를 담는 2차원 List
  List<double> _triangleSizes = [
    25.0,
    30.0,
    35.0,
    40.0
  ]; // 삼각형의 랜덤한 크기들을 담은 리스트
  List<double> _circleSizes = [12.0, 15.0, 18.0, 21.0]; // 원의 랜덤한 크기들을 담은 리스트
  List<double> _rectSizes = [25.0, 30.0, 35.0, 40.0]; // 사각형의 랜덤한 크기를 담은 리스트
  List<double> _lifeOpacityList = [1.0, 1.0, 1.0]; // 목숨 위젯에 대한 투명도 리스트 (목숨 3개)
  List<Widget> _emptyList = []; // 새로운 도형 출현하기 전 깜빡임을 위한 눈속임용 비어있는 리스트
  Timer? _timer; // 게임 타이머
  int _start = 35; // 게임 타이머 시간초 값
  int _currentOpacityIndex = 2; // 목숨에 대한 Stack Index
  int _myRecord = 0; // 현재 나의 기록 값
  int _currentPoint = 0; // 게임 중간의 현재 점수에 대한 값
  bool _isRenew = false; // 게임 기록이 갱신되었는지 판단하는 값

  @override
  void initState() {
    super.initState();
    _shapeSize.add(_triangleSizes);
    _shapeSize.add(_circleSizes);
    _shapeSize.add(_rectSizes);
    _addShape();
    _initialProcessOnRecord();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  /// 가장 처음 게임 실행했을 때 기록에 관련된 초기 세팅을 하는 함수
  /// 해당 유저가 기록이 있는지 판단하고, 있으면 해당 유저의 현재 기록을 가져옴
  void _initialProcessOnRecord() async {
    var res = await _isThereRecord();
    if (res) {
      _myRecord = await _getCurrentRecord();
    }
  }

  /// 해당 유저의 게임 기록이 있는지 검색하는 함수 (DB에 넣기 위함)
  /// 존재하면 true, 아니면 false
  Future<bool> _isThereRecord() async {
    String url =
        '${ApiUtil.API_HOST}arlimi_searchRecordMG.php?uid=${widget.user!.uid}';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      String result = ApiUtil.getPureBody(response.bodyBytes);
      if (result.contains('EXIST')) {
        return true;
      }
    }
    return false;
  }

  /// 현재 DB에 기록되어 있는 유저의 게임 기록 값을 가져오는 요청
  /// @return : 해당 유저의 게임 기록 값
  Future<int> _getCurrentRecord() async {
    String url =
        '${ApiUtil.API_HOST}arlimi_getCurRecord.php?uid=${widget.user!.uid}';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      String result = ApiUtil.getPureBody(response.bodyBytes);
      int tmp = 0;
      try {
        tmp = int.parse(result);
        return tmp;
      } catch (e) {
        return -1;
      }
    } else {
      return -2;
    }
  }

  /// 게임의 기록이 최고기록을 달성했을 경우에 갱신한 값을 DB에 업데이트를 하는 요청
  /// @return : 기록 업데이트 성공 여부
  Future<bool> _updateRecord() async {
    String url = '${ApiUtil.API_HOST}arlimi_updateRecord.php';
    final response = await http.post(Uri.parse(url), body: <String, String?>{
      'uid': widget.user!.uid,
      'record': _myRecord.toString()
    });

    if (response.statusCode == 200) {
      String result = ApiUtil.getPureBody(response.bodyBytes);
      if (result != '1') {
        return false;
      }
      return true;
    } else {
      return false;
    }
  }

  /// 게임이 시작됨과 끝됨을 알리기 위한 게임 타이머
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

  /// 게임을 다시하기를 했을 경우 초기 상태를 위한 환경 재설정
  void _reInitializeGameSetting() {
    _start = 35;
    _currentPoint = 0;
    _shapeList.clear();
    _addShape();
    _currentOpacityIndex = 2;
    _lifeOpacityList = [1.0, 1.0, 1.0];
  }

  /// 랜덤으로 색을 가져오는 함수 (7개의 색)
  Color _getRandomColor() {
    var rv = Random().nextInt(7) + 1;
    switch (rv) {
      case 1:
        return Colors.red;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.yellow;
      case 4:
        return Colors.green;
      case 5:
        return Colors.blue;
      case 6:
        return Color(0xFF000080);
      case 7:
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  /// 새로운 도형을 리스트에 추가하는 함수인 동시에
  /// 랜덤한 색, 랜덤한 크기, 랜덤한 형태를 가져와서 새로운 오브젝트를 생성한 뒤, 리스트에 추가
  void _addShape() async {
    var shapeRv = Random().nextInt(3);
    var sizeRv = Random().nextInt(4);
    Widget obj = SizedBox();
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
    var tmp = _shapeList;
    setState(() {
      _shapeList = _emptyList;
    });
    await Future.delayed(Duration(milliseconds: 400), () {
      setState(() {
        _shapeList = tmp;
        _shapeList.add(obj);
      });
    });
  }

  /// 새로 생성될 도형이 배치(정렬)될 랜덤한 위치를 정하는 함수 (중복 위치 피함)
  /// @return : (-1 <= (x, y) <= 1)인 화면의 상대 좌표 공간에서 랜덤한 위치를 가진 Alignment 객체
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

  /// 현재 페이지(route)를 종료하는 함수
  void _terminateScreen() {
    Navigator.pop(this.context);
  }

  /// 게임이 종료되었을 때 실행되는 dialog 함수
  /// 다시하기 혹은 종료의 동작과 점수를 보여줌
  void _showGameOverDialog() async {
    if (_currentPoint > _myRecord) {
      _myRecord = _currentPoint;
      _isRenew = true;
      await _updateRecord();
    }
    await showDialog(
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
                '${_isRenew ? '최고 기록 달성! ' : ''}최종 점수 : $_currentPoint점',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.purpleAccent),
                textAlign: TextAlign.center,
              ),
              actions: [
                DefaultButtonComp(
                    onPressed: () {
                      setState(() {
                        _isRenew = false;
                        _reInitializeGameSetting();
                      });
                      Navigator.pop(ctx);
                    },
                    child: Text(
                      '다시하기',
                      style: TextStyle(
                          color: Colors.lightBlue, fontWeight: FontWeight.bold),
                    )),
                DefaultButtonComp(
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

  /// 화면에 배치될 랜덤한 색과 랜덤한 위치와 랜덤한 크기를 갖는 삼각형 오브젝트를 반환하는 함수
  /// @return : 모든 특성을 가진 삼각형 객체 반환
  Widget _getTriangleObject(
      {required double size, required Color color, Key? posKey}) {
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
              _currentPoint++;
            });
          } else {
            setState(() {
              _lifeOpacityList[_currentOpacityIndex--] = 0.0;
            });
            if (_currentOpacityIndex == -1) {
              setState(() {
                _timer!.cancel();
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

  /// 화면에 배치될 랜덤한 색과 랜덤한 위치와 랜덤한 크기를 갖는 원 오브젝트를 반환하는 함수
  /// @return : 모든 특성을 가진 원 객체 반환
  Widget _getCircleObject(
      {required double size, required Color color, Key? posKey}) {
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
              _currentPoint++;
            });
          } else {
            setState(() {
              _lifeOpacityList[_currentOpacityIndex--] = 0.0;
            });
            if (_currentOpacityIndex == -1) {
              setState(() {
                _timer!.cancel();
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

  /// 화면에 배치될 랜덤한 색과 랜덤한 위치와 랜덤한 크기를 갖는 사각형 오브젝트를 반환하는 함수
  /// @return : 모든 특성을 가진 사각형 객체 반환
  Widget _getRectangleObject(
      {required double size, required Color color, Key? posKey}) {
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
              _currentPoint++;
            });
          } else {
            setState(() {
              _lifeOpacityList[_currentOpacityIndex--] = 0.0;
            });
            if (_currentOpacityIndex == -1) {
              setState(() {
                _timer!.cancel();
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
      appBar: ThemeAppBar(barTitle: 'Memory Game'),
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
                        '$_currentPoint',
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
