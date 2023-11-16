import 'package:asgshighschool/games/tic_tac_toe/Player.dart';

class TicTacToe {
  static final boardLength = 9;
  static final blockSize = 100.0;
  List<String>? board;

  static List<String>? initGameBoard() =>
      List.generate(boardLength, (index) => Player.empty);

  bool checkWinner(
      String player, int index, List<int> scoreBoard, int gridSize) {
    int row = index ~/ 3;
    int col = index % 3;
    int score = player == "X" ? 1 : -1;

    scoreBoard[row] += score;
    scoreBoard[gridSize + col] += score;
    if (row == col) {
      scoreBoard[2 * gridSize] += score;
    }
    if (gridSize - col - 1 == row) {
      scoreBoard[2 * gridSize + 1] += score;
    }

    if (scoreBoard.contains(3) || scoreBoard.contains(-3)) {
      return true;
    }
    return false;
  }
}
