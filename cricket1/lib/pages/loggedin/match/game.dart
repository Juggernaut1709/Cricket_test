import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:async';
import 'dart:math';
import 'dart:developer' as devtools show log;

class GameScreen extends StatefulWidget {
  final String roomId;

  const GameScreen({
    super.key,
    required this.roomId,
  });

  @override
  // ignore: library_private_types_in_public_api
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  int balls = 0;
  late int runs;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  late DatabaseReference room;
  String _currentUserId = '';
  String _player1Id = '';
  String _player2Id = '';
  String _batsmanId = '';
  String _bowlerId = '';
  int _ballCount = 0;
  int _runsPlayer1 = 0;
  int _runsPlayer2 = 0;
  String _p1Choice = '';
  String _p2Choice = '';
  String _status = 'waiting'; // Default value
  bool _isChoosing = false;
  String _selectedButton = '';

  @override
  void initState() {
    super.initState();
    _currentUserId = _auth.currentUser!.uid;
    _initializeGame();
  }

  @override
  void dispose() {
    room.remove();
    super.dispose();
  }

  Future<void> _initializeGame() async {
    final roomRef = _database.ref('rooms/${widget.roomId}');
    room = roomRef;
    final roomSnapshot = await roomRef.get();

    if (roomSnapshot.exists) {
      final roomData = roomSnapshot.value as Map<dynamic, dynamic>;

      // Retrieve player IDs
      _player1Id = (roomData['player1Id'] as String?)!;
      _player2Id = (roomData['player2Id'] as String?)!;

      // Randomly assign batsman and bowler
      final random = Random();
      final isPlayer1Batsman =
          random.nextBool(); // Randomly choose which player is the batsman

      setState(() {
        _batsmanId = isPlayer1Batsman ? _player1Id : _player2Id;
        _bowlerId = isPlayer1Batsman ? _player2Id : _player1Id;
        _ballCount = roomData['ballCount'] ?? 0;
        _runsPlayer1 = roomData['runsPlayer1'] ?? 0;
        _runsPlayer2 = roomData['runsPlayer2'] ?? 0;
        _p1Choice = roomData['p1Choice'] ?? '';
        _p2Choice = roomData['p2Choice'] ?? '';
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

      roomRef.onValue.listen((event) {
        final updatedData = event.snapshot.value as Map<dynamic, dynamic>?;

        if (updatedData != null) {
          setState(() {
            _batsmanId = updatedData['batsmanId'] ?? '';
            _bowlerId = updatedData['bowlerId'] ?? '';
            _ballCount = updatedData['ballCount'] ?? 0;
            _runsPlayer1 = updatedData['runsPlayer1'] ?? 0;
            _runsPlayer2 = updatedData['runsPlayer2'] ?? 0;
            _p1Choice = updatedData['p1Choice'] ?? '';
            _p2Choice = updatedData['p2Choice'] ?? '';
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
      if (_player1Id == _currentUserId) {
        await _turn1();
      } else {
        await _turn2();
      }
      _checkWinner();
    }
  }

  Future<void> _turn1() async {
    if (_player1Id == _batsmanId) {
      _showBatting();
    } else {
      _showBalling();
    }
    while (_ballCount > 0 || _status != 'out') {
      await _makeChoice(_p1Choice);
    }
    await _showRoleSwapDialog();
    if (_player1Id == _batsmanId) {
      _showBatting();
    } else {
      _showBalling();
    }
    while (_ballCount > 0 || _status != 'out') {
      await _makeChoice(_p1Choice);
    }
  }

  Future<void> _turn2() async {
    if (_player2Id == _batsmanId) {
      _showBatting();
    } else {
      _showBalling();
    }
    while (_ballCount > 0 || _status != 'out') {
      await _makeChoice(_p2Choice);
    }
    await _showRoleSwapDialog();
    if (_player2Id == _batsmanId) {
      _showBatting();
    } else {
      _showBalling();
    }
    while (_ballCount > 0 || _status != 'out') {
      await _makeChoice(_p2Choice);
    }
  }

  Future<void> _makeChoice(String choice) async {
    setState(() {
      _isChoosing = true;
    });

    final roomRef = _database.ref('rooms/${widget.roomId}');
    final currentUserId = _auth.currentUser!.uid;

    if (currentUserId == _player1Id) {
      await roomRef.update({'p1Choice': choice});
    } else if (currentUserId == _player2Id) {
      await roomRef.update({'p2Choice': choice});
    }

    await Future.delayed(const Duration(seconds: 6), () async {
      devtools.log('Resolving choices...');

      final snapshot = await roomRef.get();
      final data = snapshot.value as Map<dynamic, dynamic>;

      devtools.log('Data: $data');

      final p1Choice = data['p1Choice'];
      final p2Choice = data['p2Choice'];

      if (p1Choice != null && p2Choice != null) {
        _resolveChoices(p1Choice, p2Choice, balls);
      } else {
        if (p1Choice == null) {
          await roomRef
              .update({'p1Choice': (Random().nextInt(6) + 1).toString()});
        }
        if (p2Choice == null) {
          await roomRef
              .update({'p2Choice': (Random().nextInt(6) + 1).toString()});
        }

        final updatedData =
            (await roomRef.get()).value as Map<dynamic, dynamic>;
        final newp1Choice = updatedData['p1Choice'];
        final newp2Choice = updatedData['p2Choice'];
        _resolveChoices(newp1Choice, newp2Choice, balls);
      }
    });
  }

  void _resolveChoices(String p1Choice, String p2Choice, int balls) async {
    final roomRef = _database.ref('rooms/${widget.roomId}');

    if (p1Choice == p2Choice) {
      if (_player1Id == _batsmanId) {
        runs = _runsPlayer1;
        await roomRef.update({
          'runsPlayer1': runs,
          'ballCount': _ballCount,
          'p1Choice': null,
          'p2Choice': null,
          'status': 'out',
        });
      } else if (_player2Id == _batsmanId) {
        runs = _runsPlayer2;
        await roomRef.update({
          'runsPlayer2': runs,
          'ballCount': _ballCount,
          'p1Choice': null,
          'p2Choice': null,
          'status': 'out',
        });
        _status = 'out';
      }
    } else {
      if (_player1Id == _batsmanId) {
        balls++;
        runs = _runsPlayer1;
        await roomRef.update({
          'runsPlayer1': runs + int.parse(p1Choice),
          'p1Choice': null,
          'p2Choice': null,
          'status': 'in_progress',
          'ballCount': _ballCount - 1
        });
      } else if (_player2Id == _batsmanId) {
        balls++;
        runs = _runsPlayer2;
        await roomRef.update({
          'runsPlayer2': runs + int.parse(p2Choice),
          'p1Choice': null,
          'p2Choice': null,
          'status': 'in_progress',
          'ballCount': _ballCount - 1
        });
      }
      _status = 'in_progress';
    }

    if (_ballCount <= 0) {
      await roomRef.update({
        'batsmanId': _bowlerId,
        'bowlerId': _batsmanId,
        'ballCount': balls, // Reset ball count for the new innings
        'status': 'waiting',
      });
    }

    if ('out' == _status) {
      await roomRef.update({
        'batsmanId': _bowlerId,
        'bowlerId': _batsmanId,
        'ballCount': _ballCount + balls, // Reset ball count for the new innings
        'status': 'waiting',
      });
    }
    setState(() {
      _isChoosing = false;
      _selectedButton = '';
    });
  }

  Future<void> _showRoleSwapDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible:
          false, // User cannot dismiss the dialog by tapping outside
      builder: (BuildContext context) {
        // Automatically close the dialog after 3 seconds
        Future.delayed(const Duration(seconds: 3), () {
          Navigator.of(context).pop(); // Dismiss the dialog
        });

        return const AlertDialog(
          title: Text('Role Swap'),
          content: Text('Swapping roles!'),
        );
      },
    );
  }

  Future<void> _showBatting() async {
    return showDialog<void>(
      context: context,
      barrierDismissible:
          false, // User cannot dismiss the dialog by tapping outside
      builder: (BuildContext context) {
        // Automatically close the dialog after 3 seconds
        Future.delayed(const Duration(seconds: 3), () {
          Navigator.of(context).pop(); // Dismiss the dialog
        });

        return const AlertDialog(
          title: Text('Batting'),
          content: Text('You are now batting!'),
        );
      },
    );
  }

  Future<void> _showBalling() async {
    return showDialog<void>(
      context: context,
      barrierDismissible:
          false, // User cannot dismiss the dialog by tapping outside
      builder: (BuildContext context) {
        // Automatically close the dialog after 3 seconds
        Future.delayed(const Duration(seconds: 3), () {
          Navigator.of(context).pop(); // Dismiss the dialog
        });

        return const AlertDialog(
          title: Text('Balling'),
          content: Text('You are now balling!'),
        );
      },
    );
  }

  Future<void> _checkWinner() async {
    final roomRef = _database.ref('rooms/${widget.roomId}');
    final roomSnapshot = await roomRef.get();

    if (roomSnapshot.exists) {
      final roomData = roomSnapshot.value as Map<dynamic, dynamic>;
      final int runsPlayer1 = roomData['runsPlayer1'] ?? 0;
      final int runsPlayer2 = roomData['runsPlayer2'] ?? 0;

      String message = '';

      if (runsPlayer1 > runsPlayer2) {
        message = 'Player 1 Wins!';
        await _updateWinLoss(_player1Id, _player2Id);
      } else if (runsPlayer2 > runsPlayer1) {
        message = 'Player 2 Wins!';
        await _updateWinLoss(_player2Id, _player1Id);
      } else {
        message = 'The match is a DRAW';
      }

      _showWinnerDialog(message);
    }

    Future.delayed(const Duration(seconds: 2), () {
      Navigator.of(context).pop(); // Pop GameScreen after showing the winner
    });
  }

  Future<void> _updateWinLoss(String winnerId, String loserId) async {
    final winnerRef = _database.ref('players/$winnerId');
    final loserRef = _database.ref('players/$loserId');

    final winnerSnapshot = await winnerRef.get();
    final loserSnapshot = await loserRef.get();

    if (winnerSnapshot.exists && loserSnapshot.exists) {
      final winnerData = winnerSnapshot.value as Map<dynamic, dynamic>;
      final loserData = loserSnapshot.value as Map<dynamic, dynamic>;

      final int wins = winnerData['wins'] ?? 0;
      final int losses = loserData['losses'] ?? 0;

      await winnerRef.update({'wins': wins + 1});
      await loserRef.update({'losses': losses + 1});
    }
  }

  void _showWinnerDialog(String message) {
    showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap a button to dismiss
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Game Over'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('Return to Home'),
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
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
                    'Player1: $_runsPlayer1',
                    style: const TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Player2: $_runsPlayer2',
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
      onTap: _isChoosing
          ? null
          : () {
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
