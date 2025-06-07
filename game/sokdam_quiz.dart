import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

void main() {
  runApp(SokdamQuizApp());
}

class SokdamQuizApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: StartScreen(),
    );
  }
}

class StartScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '속담 퀴즈',
              style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CountdownScreen()),
                );
              },
              child: Text('시작', style: TextStyle(fontSize: 24)),
            )
          ],
        ),
      ),
    );
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
          MaterialPageRoute(builder: (context) => SokdamQuizGame()),
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
          style: TextStyle(fontSize: 60),
        ),
      ),
    );
  }
}

class SokdamQuizGame extends StatefulWidget {
  @override
  _SokdamQuizGameState createState() => _SokdamQuizGameState();
}

class _SokdamQuizGameState extends State<SokdamQuizGame> {
  final List<Map<String, dynamic>> _questions = [
    {
      'question': '여름비는 잠비고, 가을비는 ( )',
      'options': ['떡비', '마비'],
      'answer': '떡비'
    },
    {
      'question': '( )도 제 말하면 온다.',
      'options': ['사자', '호랑이'],
      'answer': '호랑이'
    },
    {
      'question': '아닌 밤중에 ( )',
      'options': ['홍두깨', '홍당무'],
      'answer': '홍두깨'
    },
    {
      'question': '우물 안 ( )',
      'options': ['두꺼비', '개구리'],
      'answer': '개구리'
    },
    {
      'question': '( )에도 볕 들 날 있다.',
      'options': ['땅구멍', '쥐구멍'],
      'answer': '쥐구멍'
    },
    {
      'question': '( ) 겉핥기.',
      'options': ['수박', '참외'],
      'answer': '수박'
    },
    {
      'question': '( ) 날자 배 떨어진다.',
      'options': ['참새', '까마귀'],
      'answer': '까마귀'
    },
    {
      'question': '사공이 많으면 배가 ( )으로 간다.',
      'options': ['산', '개울'],
      'answer': '산'
    },
    {
      'question': '( ) 보고 놀란 가슴 솥뚜껑 보고 놀란다.',
      'options': ['토끼', '자라'],
      'answer': '자라'
    },
    {
      'question': '( )도 밟으면 꿈틀한다.',
      'options': ['뱀', '지렁이'],
      'answer': '지렁이'
    },
  ];

  int _currentQuestion = 0;
  int _score = 0;
  List<int> _questionOrder = [];
  bool _showMark = false;
  String _mark = '';
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _questionOrder = List.generate(_questions.length, (index) => index);
    _questionOrder.shuffle();
    _questionOrder = _questionOrder.sublist(0, 5);
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer(Duration(seconds: 10), () {
      _nextQuestion();
    });
  }

  void _answer(String option) {
    if (_showMark) return;
    _timer?.cancel();
    bool correct = option == _questions[_questionOrder[_currentQuestion]]['answer'];
    setState(() {
      _showMark = true;
      _mark = correct ? 'O' : 'X';
      if (correct) _score++;
    });
    Future.delayed(Duration(seconds: 1), () {
      _nextQuestion();
    });
  }

  void _nextQuestion() {
    setState(() {
      _showMark = false;
      _mark = '';
      _currentQuestion++;
    });
    if (_currentQuestion < 5) {
      _startTimer();
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ResultScreen(score: _score),
        ),
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var q = _questions[_questionOrder[_currentQuestion]];
    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(q['question'], style: TextStyle(fontSize: 24)),
                SizedBox(height: 40),
                ...q['options'].map<Widget>((opt) => ElevatedButton(
                      onPressed: () => _answer(opt),
                      child: Text(opt, style: TextStyle(fontSize: 20)),
                    ))
              ],
            ),
          ),
          if (_showMark)
            Container(
              color: Colors.white.withOpacity(0.8),
              child: Center(
                child: Text(
                  _mark,
                  style: TextStyle(fontSize: 100, fontWeight: FontWeight.bold),
                ),
              ),
            )
        ],
      ),
    );
  }
}

class ResultScreen extends StatelessWidget {
  final int score;

  ResultScreen({required this.score});

  @override
  Widget build(BuildContext context) {
    String message = score >= 3
        ? '축하합니다! $score개 맞추셨습니다.'
        : '아쉽네요, 문제가 많이 어려웠을까요?';
    return Scaffold(
      body: Center(
        child: Text(
          message,
          style: TextStyle(fontSize: 24),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
