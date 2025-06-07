import 'dart:async';
import 'package:flutter/material.dart';

void main() {
  runApp(SammokGameApp());
}

class SammokGameApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '삼목 게임',
      home: SammokStartScreen(),
    );
  }
}

class SammokStartScreen extends StatelessWidget {
  void startCountdown(BuildContext context) async {
    for (int i = 3; i > 0; i--) {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          content: Text(
            '$i',
            style: TextStyle(fontSize: 48),
            textAlign: TextAlign.center,
          ),
        ),
      );
      await Future.delayed(Duration(milliseconds: 500));
      Navigator.of(context).pop();
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SammokGameScreen()),
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
            Text(
              '삼목 게임',
              style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => startCountdown(context),
              child: Text('시작', style: TextStyle(fontSize: 24)),
            ),
          ],
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
  bool isBlackTurn = true;
  String winner = '';

  void resetGame() {
    setState(() {
      board = List.generate(9, (index) => '');
      isBlackTurn = true;
      winner = '';
    });
  }

  void makeMove(int index) {
    if (board[index] == '' && winner == '') {
      setState(() {
        board[index] = isBlackTurn ? '흑' : '백';
        isBlackTurn = !isBlackTurn;
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
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text('$winner 이 이겼습니다!'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  resetGame();
                },
                child: Text('다시하기'),
              )
            ],
          ),
        );
        break;
      }
    }
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
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 5,
                mainAxisSpacing: 5,
              ),
              itemCount: 9,
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
                      style: TextStyle(fontSize: 36),
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
