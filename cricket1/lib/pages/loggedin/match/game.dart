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
  late DatabaseReference userRef;
  late StreamSubscription roomSubscription;
  Timer? _choiceTimer;

  bool _isTurn1Active = true;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late String _currentUserId;
  late String temp;
  late String _batsmanId;
  late String _bowlerId;
  late String _player1Id;
  late String _player2Id;
  int _runsPlayer1 = 0;
  int _runsPlayer2 = 0;
  int turn = 1;
  late int _wins = 0;
  late int _losses = 0;
  late int _draws = 0;
  String? _p1Choice;
  String? _p2Choice;
  String? _selectedButton;
  bool _isGameActive = true;

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
    _removeRoom();
    super.dispose();
  }

  void _removeRoom() {
    Future.delayed(const Duration(seconds: 5), () {
      roomRef.remove();
    });
  }

  Future<void> _initializeGame() async {
    try {
      roomRef = FirebaseDatabase.instance.ref('rooms/${widget.roomId}');
      userRef = FirebaseDatabase.instance.ref('users/$_currentUserId');
      final roomSnapshot = await roomRef.get();
      final userSnapshot = await userRef.get();

      if (userSnapshot.exists) {
        final userData = userSnapshot.value as Map<dynamic, dynamic>;

        devtools.log('User data: $_wins, $_losses, $_draws');

        setState(() {
          _wins = userData['wins'] ?? 0;
          _losses = userData['losses'] ?? 0;
          _draws = userData['draws'] ?? 0;
        });
      }

      if (roomSnapshot.exists) {
        final roomData = roomSnapshot.value as Map<dynamic, dynamic>;

        devtools.log('Room data: $roomData');

        setState(() {
          _batsmanId = roomData['batsmanId'] ?? '';
          _bowlerId = roomData['bowlerId'] ?? '';
          _player1Id = roomData['player1Id'] ?? '';
          _player2Id = roomData['player2Id'] ?? '';
          _runsPlayer1 = roomData['runsPlayer1'] ?? 0;
          _runsPlayer2 = roomData['runsPlayer2'] ?? 0;
        });
        _startGameListener();
      } else {
        devtools.log('Room not found');
      }
    } catch (e) {
      devtools.log('Error: $e');
    }
  }

  void _startGameListener() {
    try {
      roomSubscription = roomRef.onValue.listen((event) {
        final data = event.snapshot.value as Map<dynamic, dynamic>;

        if (data != null) {
          setState(() {
            _p1Choice = data['p1Choice'];
            _p2Choice = data['p2Choice'];
            _batsmanId = data['batsmanId'];
            _bowlerId = data['bowlerId'];
            _runsPlayer1 = data['runsPlayer1'] ?? _runsPlayer1;
            _runsPlayer2 = data['runsPlayer2'] ?? _runsPlayer2;
          });

          _turn1();
        }
      });
    } catch (e) {
      devtools.log('Error: $e');
    }
  }

  void _turn1() {
    try {
      if (!_isTurn1Active) return;
      devtools.log('Turn 1 started');
      _startChoiceTimer();
    } catch (e) {
      devtools.log('Error: $e');
    }
  }

  void _turn2() {
    try {
      devtools.log('Turn 2 started');
      _startChoiceTimer();
    } catch (e) {
      devtools.log('Error: $e');
    }
  }

  void _startChoiceTimer() {
    try {
      // Cancel any existing timer to avoid multiple timers running simultaneously
      if (_isGameActive) {
        _choiceTimer?.cancel();

        _choiceTimer = Timer(const Duration(seconds: choiceDuration), () {
          devtools.log('timer ended after 4 seconds');
          if (_p1Choice == null || _p2Choice == null) {
            devtools.log('Assigning random choices');
            _assignRandomChoices();
          }
          _endChoiceSelection();
        });
      }
    } catch (e) {
      devtools.log('Error: $e');
    }
  }

  void _assignRandomChoices() async {
    try {
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
    } catch (e) {
      devtools.log('Error: $e');
    }
  }

  void _endChoiceSelection() {
    try {
      // Cancel the timer to prevent random assignment after choice is made
      _choiceTimer?.cancel();

      // If both choices are made, proceed to comparison
      someFunction();
    } catch (e) {
      devtools.log('Error: $e');
    }
  }

  void _compareChoices(String p1Choice, String p2Choice) async {
    try {
      devtools.log('Comparing choices: $p1Choice, $p2Choice');
      if (p1Choice == p2Choice) {
        devtools.log('Both players chose the same number');
        // Both players chose the same number, no runs scored
        await roomRef.update({
          'p1Choice': null,
          'p2Choice': null,
        });
        if (turn == 1) {
          _endTurn1();
        } else {
          _endTurn2();
        }
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
      }

      setState(() {
        _p1Choice = null;
        _p2Choice = null;
      });

      if (turn == 1) {
        _turn1();
      } else {
        String batsmanId = _batsmanId;
        if (batsmanId == _player1Id && _runsPlayer1 > _runsPlayer2) {
          _endTurn2();
        } else if (batsmanId == _player2Id && _runsPlayer2 > _runsPlayer1) {
          _endTurn2();
        } else {
          _turn2();
        }
      }
    } catch (e) {
      devtools.log('Error: $e');
    }
  }

  void _endTurn1() async {
    try {
      devtools.log('Turn 1 ended');
      // Proceed to the next phase of the game or determine the winner
      //Navigator.pop(context);
      _isTurn1Active = false;
      _choiceTimer?.cancel();
      showDialog(
        context: context,
        builder: (context) {
          return const AlertDialog(
            title: Text(
              'OUT',
              style: TextStyle(
                fontSize: 24,
                color: Colors.red,
              ),
            ),
            content: Text(
              'Swapping roles',
              style: TextStyle(
                fontSize: 18,
              ),
            ),
          );
        },
      );
      Future.delayed(const Duration(seconds: 3), () {
        Navigator.pop(context);
      });

      await roomRef.update({
        'batsmanId': _bowlerId,
        'bowlerId': _batsmanId,
      });
      setState(() {
        temp = _batsmanId;
        _batsmanId = _bowlerId;
        _bowlerId = temp;
        _isTurn1Active = false;
      });

      turn = 2;
      _isTurn1Active = false;
      _choiceTimer?.cancel();
      _turn2();
    } catch (e) {
      devtools.log('Error: $e');
    }
  }

  void _endTurn2() async {
    try {
      _isGameActive = false;
      devtools.log('Turn 2 ended');
      devtools.log('player1: $_runsPlayer1');
      devtools.log('player2: $_runsPlayer2');
      // Determine the winner of the game
      String winnerId;
      String loserId;
      if (_runsPlayer1 > _runsPlayer2) {
        winnerId = _player1Id;
        loserId = _player2Id;
        if (winnerId == _currentUserId) {
          _wins += 1;
          _showWinnerDialog();
        } else if (loserId == _currentUserId) {
          _losses += 1;
          _showLoserDialog();
        }
      } else if (_runsPlayer2 > _runsPlayer1) {
        winnerId = _player2Id;
        loserId = _player1Id;
        if (winnerId == _currentUserId) {
          _wins += 1;
          _showWinnerDialog();
        } else if (loserId == _currentUserId) {
          _losses += 1;
          _showLoserDialog();
        }
      } else {
        // It's a draw
        _draws += 1;
        _showDrawDialog();
      }

      await userRef.update({
        'wins': _wins,
        'losses': _losses,
        'draws': _draws,
      });
    } catch (e) {
      devtools.log('Error: $e');
    }
  }

  void someFunction() {
    try {
      // Your existing code
      Timer(const Duration(seconds: 2), () {
        if (_p1Choice != null && _p2Choice != null) {
          _compareChoices(_p1Choice!, _p2Choice!);
        }
      });
    } catch (e) {
      devtools.log('Error: $e');
    }
  }

  Future<void> _makeChoice(String choice) async {
    try {
      // Prevent multiple choices by checking if the choice is already set
      if (_currentUserId == _player1Id && _p1Choice == null) {
        devtools.log('Batsman making choice: $choice');
        await roomRef.update({'p1Choice': choice});
      } else if (_currentUserId == _player2Id && _p2Choice == null) {
        devtools.log('Baller making choice: $choice');
        await roomRef.update({'p2Choice': choice});
      }

      setState(() {
        _selectedButton = null;
      });
      _endChoiceSelection(); // Ensure the choice process ends after making a choice
    } catch (e) {
      devtools.log('Error: $e');
    }
  }

  void _showWinnerDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Congratulations!'),
          content: const Text('You won the game!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(
                    context, '/home', (route) => false);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showLoserDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Better luck next time!'),
          content: const Text('You lost the game!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(
                    context, '/home', (route) => false);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showDrawDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('It\'s a draw!'),
          content: const Text('The game ended in a draw!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(
                    context, '/home', (route) => false);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_batsmanId == null || _bowlerId == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    String displayText = _currentUserId == _batsmanId ? 'BATTING' : 'BOWLING';

    // Determine the labels based on the current user ID
    String userLabel = 'USR';
    String opponentLabel = 'OPP';

    // Determine the scores to display based on the current user ID
    String userScore =
        _currentUserId == _player1Id ? '$_runsPlayer1' : '$_runsPlayer2';
    String opponentScore =
        _currentUserId == _player2Id ? '$_runsPlayer1' : '$_runsPlayer2';

    return Scaffold(
      backgroundColor: const Color.fromRGBO(11, 42, 33, 1.0),
      body: Stack(
        children: [
          Positioned(
            top: 20,
            left: 20,
            right: 20,
            height: 100,
            child: Container(
              color: const Color.fromRGBO(11, 42, 33, 1.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$userLabel: $userScore',
                    style: const TextStyle(
                      fontSize: 24,
                      color: Color.fromRGBO(213, 206, 163, 1.0),
                    ),
                  ),
                  Text(
                    '$opponentLabel: $opponentScore',
                    style: const TextStyle(
                      fontSize: 24,
                      color: Color.fromRGBO(213, 206, 163, 1.0),
                    ),
                  ),
                ],
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
              color: const Color.fromRGBO(11, 42, 33, 1.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    displayText,
                    style: const TextStyle(
                      fontSize: 32,
                      color: Color.fromARGB(255, 213, 206, 163),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        height: 50,
                        color: Color.fromRGBO(11, 42, 33, 1.0),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildChoiceButton('1'),
                          _buildChoiceButton('2'),
                          _buildChoiceButton('3'),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildChoiceButton('4'),
                          _buildChoiceButton('5'),
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
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color.fromRGBO(60, 42, 33, 1)
              : const Color.fromARGB(255, 213, 206, 163),
          shape: BoxShape.circle,
        ),
        width: 90,
        height: 90,
        child: Center(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 1, 12, 20),
            ),
          ),
        ),
      ),
    );
  }
}
