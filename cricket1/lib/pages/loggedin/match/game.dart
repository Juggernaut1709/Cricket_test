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
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  String _currentUserId = '';
  String _batsmanId = '';
  String _bowlerId = '';
  int _ballCount = 0;
  int _runsPlayer1 = 0;
  int _runsPlayer2 = 0;
  String _batsmanChoice = '';
  String _bowlerChoice = '';
  String _status = 'waiting'; // Default value
  bool _isChoosing = false;
  String _selectedButton = '';

  @override
  void initState() {
    super.initState();
    _currentUserId = _auth.currentUser!.uid;
    _initializeGame();
  }

  Future<void> _initializeGame() async {
    final roomRef = _database.ref('rooms/${widget.roomId}');
    final roomSnapshot = await roomRef.get();

    if (roomSnapshot.exists) {
      final roomData = roomSnapshot.value as Map<dynamic, dynamic>;

      // Retrieve player IDs
      final player1Id = roomData['player1Id'] as String?;
      final player2Id = roomData['player2Id'] as String?;

      if (player1Id != null && player2Id != null) {
        // Randomly assign batsman and bowler
        final random = Random();
        final isPlayer1Batsman =
            random.nextBool(); // Randomly choose which player is the batsman

        setState(() {
          _batsmanId = isPlayer1Batsman ? player1Id : player2Id;
          _bowlerId = isPlayer1Batsman ? player2Id : player1Id;
          _ballCount = roomData['ballCount'] ?? 0;
          _runsPlayer1 = roomData['runsPlayer1'] ?? 0;
          _runsPlayer2 = roomData['runsPlayer2'] ?? 0;
          _batsmanChoice = roomData['batsmanChoice'] ?? '';
          _bowlerChoice = roomData['bowlerChoice'] ?? '';
          _status = roomData['status'] ?? 'waiting';
        });

        // Update roles in Firebase
        await roomRef.update({
          'batsmanId': _batsmanId,
          'bowlerId': _bowlerId,
          'status': 'in_progress'
        });

        // Start the game turns
        _startTurns();
      } else {
        devtools.log('Player IDs are not set');
      }

      roomRef.onValue.listen((event) {
        final updatedData = event.snapshot.value as Map<dynamic, dynamic>?;

        if (updatedData != null) {
          setState(() {
            _batsmanId = updatedData['batsmanId'] ?? '';
            _bowlerId = updatedData['bowlerId'] ?? '';
            _ballCount = updatedData['ballCount'] ?? 0;
            _runsPlayer1 = updatedData['runsPlayer1'] ?? 0;
            _runsPlayer2 = updatedData['runsPlayer2'] ?? 0;
            _batsmanChoice = updatedData['batsmanChoice'] ?? '';
            _bowlerChoice = updatedData['bowlerChoice'] ?? '';
            _status = updatedData['status'] ?? 'waiting';
          });
        }
      });
    } else {
      devtools.log('Room does not exist');
    }
  }

  Future<void> _startTurns() async {
    if (_batsmanId.isNotEmpty && _bowlerId.isNotEmpty) {
      if (_batsmanId == _currentUserId) {
        await _turn1();
        await _showRoleSwapDialog();
        await _turn2();
        _checkWinner();
      } else {
        await _turn2();
        await _showRoleSwapDialog();
        await _turn1();
        _checkWinner();
      }
    }
  }

  Future<void> _turn1() async {
    while (_ballCount > 0) {
      await _makeChoice(_batsmanChoice);
      if (_ballCount <= 0) {
        return;
      }
      if (_status == 'out') {
        await _showOutScreen();
        return;
      }
    }
  }

  Future<void> _turn2() async {
    while (_ballCount > 0 && _bowlerId == _currentUserId) {
      await _makeChoice(_bowlerChoice);
      if (_ballCount <= 0) {
        return;
      }
      if (_status == 'out') {
        await _showOutScreen();
        return;
      }
    }
  }

  Future<void> _makeChoice(String choice) async {
    int balls = 0;
    setState(() {
      _isChoosing = true;
    });

    final roomRef = _database.ref('rooms/${widget.roomId}');
    final currentUserId = _auth.currentUser!.uid;

    if (currentUserId == _batsmanId) {
      await roomRef.update({'batsmanChoice': choice});
    } else if (currentUserId == _bowlerId) {
      await roomRef.update({'bowlerChoice': choice});
    }

    await Future.delayed(const Duration(seconds: 3), () async {
      devtools.log('Resolving choices...');

      final snapshot = await roomRef.get();
      final data = snapshot.value as Map<dynamic, dynamic>;

      devtools.log('Data: $data');

      final batsmanChoice = data['batsmanChoice'];
      final bowlerChoice = data['bowlerChoice'];

      if (batsmanChoice != null && bowlerChoice != null) {
        _resolveChoices(batsmanChoice, bowlerChoice, balls);
      } else {
        if (batsmanChoice == null) {
          await roomRef
              .update({'batsmanChoice': (Random().nextInt(6) + 1).toString()});
        }
        if (bowlerChoice == null) {
          await roomRef
              .update({'bowlerChoice': (Random().nextInt(6) + 1).toString()});
        }

        final updatedData =
            (await roomRef.get()).value as Map<dynamic, dynamic>;
        final newBatsmanChoice = updatedData['batsmanChoice'];
        final newBowlerChoice = updatedData['bowlerChoice'];
        _resolveChoices(newBatsmanChoice, newBowlerChoice, balls);
      }
    });
  }

  void _resolveChoices(
      String batsmanChoice, String bowlerChoice, int balls) async {
    final roomRef = _database.ref('rooms/${widget.roomId}');

    if (batsmanChoice == bowlerChoice) {
      final currentUserId = _auth.currentUser!.uid;
      final runs = currentUserId == _batsmanId ? _runsPlayer1 : _runsPlayer2;
      await roomRef.update({
        'ballCount': _ballCount,
        'batsmanChoice': null,
        'bowlerChoice': null,
        'runs${currentUserId == _batsmanId ? 'Player1' : 'Player2'}': runs,
        'status': 'out',
      });
    } else {
      balls++;
      final runs = _currentUserId == _batsmanId ? _runsPlayer1 : _runsPlayer2;
      await roomRef.update({
        'ballCount': _ballCount - 1,
        'runs${_currentUserId == _batsmanId ? 'Player1' : 'Player2'}':
            runs + int.parse(batsmanChoice),
        'batsmanChoice': null,
        'bowlerChoice': null,
        'status': 'in_progress',
      });
    }

    if (_ballCount <= 0) {
      await roomRef.update({
        'batsmanId': _bowlerId,
        'bowlerId': _batsmanId,
        'ballCount': 20, // Reset ball count for the new innings
        'status': 'waiting',
      });

      _showRoleSwapDialog();
    }

    setState(() {
      _isChoosing = false;
    });
  }

  Future<void> _checkWinner() async {
    final roomRef = _database.ref('rooms/${widget.roomId}');
    final snapshot = await roomRef.get();
    final data = snapshot.value as Map<dynamic, dynamic>;
    final runsPlayer1 = data['runsPlayer1'] ?? 0;
    final runsPlayer2 = data['runsPlayer2'] ?? 0;

    String result;

    if (runsPlayer1 > runsPlayer2) {
      result = 'Player 1 wins!';
    } else if (runsPlayer2 > runsPlayer1) {
      result = 'Player 2 wins!';
    } else {
      result = 'The match is a DRAW';
    }

    // Display result
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color.fromRGBO(50, 50, 50, 1),
          content: Text(
            result,
            style: const TextStyle(
              color: Color.fromRGBO(20, 255, 236, 1),
              fontSize: 40,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pushReplacementNamed(
                    context, '/home'); // Navigate to HomePage
              },
              child: const Text(
                'Return to Home',
                style: TextStyle(
                  color: Color.fromRGBO(13, 115, 119, 1),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showRoleSwapDialog() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color.fromRGBO(50, 50, 50, 1),
          content: const Text(
            'Roles have been swapped!',
            style: TextStyle(
              color: Color.fromRGBO(20, 255, 236, 1),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Continue',
                style: TextStyle(
                  color: Color.fromRGBO(13, 115, 119, 1),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showOutScreen() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color.fromRGBO(50, 50, 50, 1),
          content: const Text(
            'OUT!',
            style: TextStyle(
              color: Color.fromRGBO(20, 255, 236, 1),
              fontSize: 40,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Continue',
                style: TextStyle(
                  color: Color.fromRGBO(13, 115, 119, 1),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 58, 4, 105),
        title: Text(
          'Game - ${widget.roomId}',
          style: const TextStyle(color: Color.fromRGBO(20, 255, 236, 1)),
        ),
      ),
      backgroundColor: const Color.fromRGBO(50, 50, 50, 1),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Status: $_status',
                    style: const TextStyle(
                        fontSize: 20, color: Color.fromRGBO(20, 255, 236, 1)),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Balls Left: $_ballCount',
                    style: const TextStyle(
                        fontSize: 20, color: Color.fromRGBO(20, 255, 236, 1)),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Player 1 Runs: $_runsPlayer1',
                    style: const TextStyle(
                        fontSize: 18, color: Color.fromRGBO(20, 255, 236, 1)),
                  ),
                  Text(
                    'Player 2 Runs: $_runsPlayer2',
                    style: const TextStyle(
                        fontSize: 18, color: Color.fromRGBO(20, 255, 236, 1)),
                  ),
                ],
              ),
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildAnimatedButton('1'),
                      _buildAnimatedButton('2'),
                      _buildAnimatedButton('3'),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildAnimatedButton('4'),
                      _buildAnimatedButton('5'),
                      _buildAnimatedButton('6'),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedButton(String value) {
    final isSelected = _selectedButton == value;
    final isButtonDisabled = !_isChoosing && _status != 'in_progress';

    return ElevatedButton(
      onPressed: isButtonDisabled
          ? null
          : () {
              setState(() {
                _selectedButton = value;
              });
              _makeChoice(value);
            },
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected
            ? const Color.fromRGBO(20, 255, 236, 1)
            : const Color.fromRGBO(13, 115, 119, 1),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
      child: Text(
        value,
        style: const TextStyle(color: Color(0xFF02111B), fontSize: 18),
      ),
    );
  }
}
