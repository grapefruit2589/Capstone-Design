import 'dart:async';
import 'package:flutter/material.dart';
import '../SeniorGameScreen.dart';

class SammokGame extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CountdownScreen();
  }
}

class CountdownScreen extends StatefulWidget {
  @override
  _CountdownScreenState createState() => _CountdownScreenState();
}

class _CountdownScreenState extends State<CountdownScreen> {
  int _seconds = 3;

  @override
  void initState() {
    super.initState();
    Timer.periodic(Duration(seconds: 1), (timer) {
      if (_seconds == 1) {
        timer.cancel();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SammokGameScreen()),
        );
      } else {
        setState(() {
          _seconds--;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          '$_seconds',
          style: TextStyle(fontSize: 60, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class SammokGameScreen extends StatefulWidget {
  @override
  _SammokGameScreenState createState() => _SammokGameScreenState();
}

class _SammokGameScreenState extends State<SammokGameScreen> {
  List<String> board = List.generate(9, (index) => '');
  bool isOTurn = true; // true: O(파랑), false: X(빨강)
  String winner = '';

  void resetGame() {
    setState(() {
      board = List.generate(9, (index) => '');
      isOTurn = true;
      winner = '';
    });
  }

  void makeMove(int index) {
    if (board[index] == '' && winner == '') {
      setState(() {
        board[index] = isOTurn ? 'O' : 'X';
        isOTurn = !isOTurn;
        checkWinner();
      });
    }
  }

  void checkWinner() {
    List<List<int>> winPatterns = [
      [0, 1, 2], [3, 4, 5], [6, 7, 8],
      [0, 3, 6], [1, 4, 7], [2, 5, 8],
      [0, 4, 8], [2, 4, 6]
    ];

    for (var pattern in winPatterns) {
      String a = board[pattern[0]];
      String b = board[pattern[1]];
      String c = board[pattern[2]];
      if (a != '' && a == b && b == c) {
        setState(() {
          winner = a;
        });
        Future.delayed(Duration(milliseconds: 300), () {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: Text('${a == 'O' ? 'O (파란색)' : 'X (빨간색)'} 이 이겼습니다!'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _goToGameSelection();
                  },
                  child: Text('게임 선택 화면으로'),
                )
              ],
            ),
          );
        });
        break;
      }
    }
  }

  void _goToGameSelection() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => SeniorGameScreen()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('삼목 게임')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GridView.builder(
              shrinkWrap: true,
              itemCount: 9,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 5,
                mainAxisSpacing: 5,
              ),
              itemBuilder: (context, index) => GestureDetector(
                onTap: () => makeMove(index),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                    color: Colors.grey[200],
                  ),
                  child: Center(
                    child: Text(
                      board[index],
                      style: TextStyle(
                        fontSize: 70,
                        fontWeight: FontWeight.bold,
                        color: board[index] == 'O'
                            ? Colors.blue
                            : board[index] == 'X'
                            ? Colors.red
                            : Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: resetGame,
              child: Text('게임 초기화'),
            ),
          ],
        ),
      ),
    );
  }
}
