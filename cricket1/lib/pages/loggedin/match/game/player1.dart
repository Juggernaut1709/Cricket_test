/*
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:async';
import 'dart:math';
import 'dart:developer' as devtools show log;

class GameScreen extends StatefulWidget {
  final String roomId;

  const GameScreen({Key? key, required this.roomId}) : super(key: key);

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late DatabaseReference roomRef;
  late StreamSubscription roomSubscription;
  Timer? _choiceTimer;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  late String _currentUserId;

  late String _batsmanId;
  late String _bowlerId;
  late String _player1Id;
  late String _player2Id;
  int _ballCount = 0;
  int _runsPlayer1 = 0;
  int _runsPlayer2 = 0;
  String? _p1Choice;
  String? _p2Choice;
  String? _selectedButton;

  static const int choiceDuration = 4;

  @override
  void initState() {
    super.initState();
    _currentUserId = _auth.currentUser!.uid;
    _initializeGame();
  }

  @override
  void dispose() {
    _choiceTimer?.cancel();
    roomSubscription.cancel();
    super.dispose();
  }

  Future<void> _initializeGame() async {
    roomRef = FirebaseDatabase.instance.ref('rooms/${widget.roomId}');
    final roomSnapshot = await roomRef.get();

    if (roomSnapshot.exists) {
      final roomData = roomSnapshot.value as Map<dynamic, dynamic>;

      setState(() {
        _batsmanId = roomData['batsmanId'] ?? '';
        _bowlerId = roomData['bowlerId'] ?? '';
        _player1Id = roomData['player1Id'] ?? '';
        _player2Id = roomData['player2Id'] ?? '';
        _ballCount = roomData['ballCount'] ?? 0;
        _runsPlayer1 = roomData['runsPlayer1'] ?? 0;
        _runsPlayer2 = roomData['runsPlayer2'] ?? 0;
      });

      _startGameListener();
    } else {
      devtools.log('Room not found');
    }
  }

  void _startGameListener() {
    roomSubscription = roomRef.onValue.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>;

      if (data != null) {
        setState(() {
          _p1Choice = data['p1Choice'];
          _p2Choice = data['p2Choice'];
          _batsmanId = data['batsmanId'];
          _bowlerId = data['bowlerId'];
          _ballCount = data['ballCount'];
          _runsPlayer1 = data['runsPlayer1'] ?? _runsPlayer1;
          _runsPlayer2 = data['runsPlayer2'] ?? _runsPlayer2;
        });

        _turn1();
      }
    });
  }

  void _turn1() {
    if (_ballCount > 0) {
      devtools.log('Turn 1 started');
      _startChoiceTimer();
    } else {
      devtools.log('Game over');
      _endTurn1();
    }
  }

  void _startChoiceTimer() {
    // Cancel any existing timer to avoid multiple timers running simultaneously
    _choiceTimer?.cancel();

    _choiceTimer = Timer(Duration(seconds: choiceDuration), () {
      devtools.log('timer ended after 4 seconds');
      if (_p1Choice == null || _p2Choice == null) {
        devtools.log('Assigning random choices');
        _assignRandomChoices();
      }
      _endChoiceSelection();
    });
  }

  void _assignRandomChoices() async {
    if (_p1Choice == null) {
      devtools.log('Assigning random choice for player 1');
      _p1Choice = (Random().nextInt(6) + 1).toString();
      await roomRef.update({'p1Choice': _p1Choice});
    }

    if (_p2Choice == null) {
      devtools.log('Assigning random choice for player 2');
      _p2Choice = (Random().nextInt(6) + 1).toString();
      await roomRef.update({'p2Choice': _p2Choice});
    }
  }

  void _endChoiceSelection() {
    // Cancel the timer to prevent random assignment after choice is made
    _choiceTimer?.cancel();

    // If both choices are made, proceed to comparison
    someFunction();
  }

  void _compareChoices(String p1Choice, String p2Choice) async {
    devtools.log('Comparing choices: $p1Choice, $p2Choice');
    if (p1Choice == p2Choice) {
      devtools.log('Both players chose the same number');
      // Both players chose the same number, no runs scored
      await roomRef.update({
        'p1Choice': null,
        'p2Choice': null,
      });
      _endTurn1();
    } else {
      devtools.log('Choices are different');
      if (_batsmanId == _player1Id) {
        int runs = int.parse(p1Choice);
        await roomRef.update({
          'p1Choice': null,
          'p2Choice': null,
          'runsPlayer1': _runsPlayer1 + runs,
        });
      } else if (_batsmanId == _player2Id) {
        int runs = int.parse(p2Choice);
        await roomRef.update({
          'runsPlayer2': _runsPlayer2 + runs,
          'p1Choice': null,
          'p2Choice': null
        });
      }

      if (_currentUserId == _batsmanId) {
        await roomRef.update({
          'ballCount': _ballCount - 1,
        });
      }
    }

    setState(() {
      devtools.log('ballcount is now ${_ballCount - 1}');
      _p1Choice = null;
      _p2Choice = null;
      _ballCount -= 1;
    });

    _turn1();
  }

  void _endTurn1() {
    devtools.log('Turn 1 ended');
    // Proceed to the next phase of the game or determine the winner
    Navigator.pop(context);
  }

  void someFunction() {
    // Your existing code
    Timer(Duration(seconds: 2), () {
      if (_p1Choice != null && _p2Choice != null) {
        _compareChoices(_p1Choice!, _p2Choice!);
      }
    });
  }

  Future<void> _makeChoice(String choice) async {
    // Prevent multiple choices by checking if the choice is already set
    if (_currentUserId == _batsmanId && _p1Choice == null) {
      devtools.log('Batsman making choice: $choice');
      await roomRef.update({'p1Choice': choice});
    } else if (_currentUserId == _bowlerId && _p2Choice == null) {
      devtools.log('Baller making choice: $choice');
      await roomRef.update({'p2Choice': choice});
    }

    setState(() {
      _selectedButton = null;
    });
    _endChoiceSelection(); // Ensure the choice process ends after making a choice
  }

  @override
  Widget build(BuildContext context) {
    String displayText = _currentUserId == _batsmanId ? 'BATTING' : 'BALLING';
    return Scaffold(
      backgroundColor: const Color(0xFF212121),
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 20,
            right: 20,
            height: 100,
            child: Container(
              color: const Color(0xFF326050),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'P1: $_runsPlayer1',
                    style: const TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'P2: $_runsPlayer2',
                    style: const TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 100,
            left: 0,
            right: 0,
            height: 100,
            child: Container(
              color: const Color(0xFF505050),
              child: Center(
                child: Text(
                  'Balls left: $_ballCount',
                  style: const TextStyle(fontSize: 24, color: Colors.white),
                ),
              ),
            ),
          ),
          Positioned(
            top: 200,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(20.0),
              color: const Color(0xFF505050),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    displayText,
                    style: const TextStyle(
                        fontSize: 32, color: Color.fromARGB(255, 44, 117, 5)),
                  ),
                  const Text(
                    'Make your choice:',
                    style: TextStyle(fontSize: 24, color: Colors.white),
                  ),
                  const SizedBox(height: 20),
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildChoiceButton('1'),
                          const SizedBox(width: 10),
                          _buildChoiceButton('2'),
                          const SizedBox(width: 10),
                          _buildChoiceButton('3'),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildChoiceButton('4'),
                          const SizedBox(width: 10),
                          _buildChoiceButton('5'),
                          const SizedBox(width: 10),
                          _buildChoiceButton('6'),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChoiceButton(String value) {
    final isSelected = _selectedButton == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedButton = value;
        });
        _makeChoice(value);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        decoration: BoxDecoration(
          color: isSelected ? Colors.amber : const Color(0xFF76bed0),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF02111b),
          ),
        ),
      ),
    );
  }
}
*/