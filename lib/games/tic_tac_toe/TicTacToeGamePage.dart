import 'package:asgshighschool/games/tic_tac_toe/TicTacToe.dart';
import 'package:flutter/material.dart';

import '../../component/ThemeAppBar.dart';
import 'GameColor.dart';

class TicTacToeGamePage extends StatefulWidget {
  const TicTacToeGamePage({Key? key}) : super(key: key);

  @override
  State<TicTacToeGamePage> createState() => _TicTacToeGamePageState();
}

class _TicTacToeGamePageState extends State<TicTacToeGamePage> {
  String _lastValue = "X";
  bool _isGameOver = false;
  int _currentTurn = 0;
  String _result = "";
  List<int> _scoreBoard = [0, 0, 0, 0, 0, 0, 0, 0];
  TicTacToe ticTacToe = new TicTacToe();

  @override
  void initState() {
    super.initState();
    ticTacToe.board = TicTacToe.initGameBoard();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
        backgroundColor: TicTacToeMainColor.primaryColor,
        appBar: ThemeAppBar(barTitle: '틱택토 게임'),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "$_lastValue 차례입니다.".toUpperCase(),
              style: TextStyle(
                color: Colors.white,
                fontSize: 58,
              ),
            ),
            SizedBox(
              height: 20.0,
            ),
            Container(
              width: size.width,
              height: size.width,
              child: GridView.count(
                crossAxisCount: TicTacToe.boardLength ~/ 3,
                padding: EdgeInsets.all(16.0),
                mainAxisSpacing: 8.0,
                crossAxisSpacing: 8.0,
                children: List.generate(TicTacToe.boardLength, (index) {
                  return InkWell(
                    onTap: _isGameOver
                        ? null
                        : () {
                            if (ticTacToe.board![index] == "") {
                              setState(() {
                                ticTacToe.board![index] = _lastValue;
                                _currentTurn++;
                                _isGameOver = ticTacToe.checkWinner(
                                    _lastValue, index, _scoreBoard, 3);

                                if (_isGameOver) {
                                  _result = "승자는 $_lastValue입니다!";
                                } else if (!_isGameOver && _currentTurn == 9) {
                                  _result = "무승부입니다!";
                                  _isGameOver = true;
                                }
                                if (_lastValue == "X")
                                  _lastValue = "O";
                                else
                                  _lastValue = "X";
                              });
                            }
                          },
                    child: Container(
                      width: TicTacToe.blockSize,
                      height: TicTacToe.blockSize,
                      decoration: BoxDecoration(
                        color: TicTacToeMainColor.secondaryColor,
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      child: Center(
                        child: Text(
                          ticTacToe.board![index],
                          style: TextStyle(
                            color: ticTacToe.board![index] == "X"
                                ? Colors.blue
                                : Colors.pink,
                            fontSize: 64.0,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
            SizedBox(
              height: 25.0,
            ),
            Text(
              _result,
              style: TextStyle(color: Colors.white, fontSize: 48.0),
            ),
            _isGameOver ? ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  ticTacToe.board = TicTacToe.initGameBoard();
                  _lastValue = "X";
                  _isGameOver = false;
                  _currentTurn = 0;
                  _result = "";
                  _scoreBoard = [0, 0, 0, 0, 0, 0, 0, 0];
                });
              },
              icon: Icon(Icons.replay),
              label: Text("게임 재시작하기"),
            ) : SizedBox(),
          ],
        ));
  }
}
