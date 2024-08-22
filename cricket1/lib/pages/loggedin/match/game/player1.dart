/*import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:async';
import 'dart:math';
import 'dart:developer' as devtools show log;

class Player1 extends StatefulWidget {
  final String roomId;

  const Player1({
    super.key,
    required this.roomId,
  });

  @override
  // ignore: library_private_types_in_public_api
  _Player1State createState() => _Player1State();
}

class _Player1State extends State<Player1> {
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
  int _totalBalls = 0;

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
      if (_player1Id == _currentUserId) {
        final random = Random();
        final isPlayer1Batsman =
            random.nextBool(); // Randomly choose which player is the batsman
        setState(() {
          _batsmanId = isPlayer1Batsman ? _player1Id : _player2Id;
          _bowlerId = isPlayer1Batsman ? _player2Id : _player1Id;
        });
        await roomRef.update({
          'batsmanId': _batsmanId,
          'bowlerId': _bowlerId,
          'status': 'in_progress'
        });
      } else {
        _batsmanId = roomData['batsmanId'] ?? '';
        _bowlerId = roomData['bowlerId'] ?? '';
      }
      // Update roles in Firebase
      _ballCount = roomData['ballCount'] ?? 0;
      _runsPlayer1 = roomData['runsPlayer1'] ?? 0;
      _runsPlayer2 = roomData['runsPlayer2'] ?? 0;
      _p1Choice = roomData['p1Choice'] ?? '';
      _p2Choice = roomData['p2Choice'] ?? '';
      _status = roomData['status'] ?? 'waiting';
      _totalBalls = roomData['totalBalls'] ?? 0;

      // Start the game turns
      _startTurns();

      roomRef.onValue.listen((event) {
        final updatedData = event.snapshot.value as Map<dynamic, dynamic>?;

        if (updatedData != null) {
          setState(() {
            _batsmanId = updatedData['batsmanId'] ?? _batsmanId;
            _bowlerId = updatedData['bowlerId'] ?? _bowlerId;
            _ballCount = updatedData['ballCount'] ?? _ballCount;
            _runsPlayer1 = updatedData['runsPlayer1'] ?? _runsPlayer1;
            _runsPlayer2 = updatedData['runsPlayer2'] ?? _runsPlayer2;
            _p1Choice = updatedData['p1Choice'] ?? _p1Choice;
            _p2Choice = updatedData['p2Choice'] ?? _p2Choice;
            _status = updatedData['status'] ?? _status;
          });
        }
      });
    } else {
      devtools.log('Room does not exist');
    }
  }

  Future<void> _startTurns() async {
    if (_batsmanId.isNotEmpty && _bowlerId.isNotEmpty) {
      await _turn1();
      _checkWinner();
    }
  }

  Future<void> _turn1() async {
    if (_player1Id == _batsmanId) {
      _showBatting();
    } else {
      _showBalling();
    }
    while (_ballCount > 0 && _status != 'out') {
      await _makeChoice(_p1Choice);
    }
    _ballCount <= 0 ? _swapRoles() : _handleOut();
    if (_player1Id == _batsmanId) {
      _showBatting();
    } else {
      _showBalling();
    }
    while (_ballCount > 0 && _status != 'out') {
      await _makeChoice(_p1Choice);
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
    }

    // Timer to enforce a 5-second limit for choice selection
    // ignore: prefer_const_constructors
    Timer timer = Timer(Duration(seconds: 5), () async {
      final snapshot = await roomRef.get();
      final data = snapshot.value as Map<dynamic, dynamic>;

      await roomRef.update({'p1Choice': (Random().nextInt(6) + 1).toString()});
    });
    // Listen for changes in p1Choice and p2Choice
    roomRef.onValue.listen((event) async {
      final data = event.snapshot.value as Map<dynamic, dynamic>;
      final p1Choice = data['p1Choice'];
      final p2Choice = data['p2Choice'];
      if (p1Choice != null && p2Choice != null) {
        // Once both choices are made, resolve them
        timer
            .cancel(); // Cancel the timer if both choices are made within 5 seconds
        _resolveChoices(p1Choice, p2Choice);

        // Stop listening once choices are resolved
        roomRef.onValue.listen(null).cancel();
      }
    });
  }

  void _resolveChoices(String p1Choice, String p2Choice) async {
    final roomRef = _database.ref('rooms/${widget.roomId}');

    bool isOut = (p1Choice == p2Choice);

    if (isOut) {
      _status = 'out';
      await roomRef.update({
        'status': 'out',
        'ballCount': _ballCount,
        'p1Choice': null,
        'p2Choice': null,
      });
      if (_player1Id == _batsmanId) {
        await roomRef.update({
          'runsPlayer1': _runsPlayer1,
        });
      }
    } else {
      if (_player1Id == _batsmanId) {
        int runs = _runsPlayer1;
        runs += int.parse(_p1Choice);
        _ballCount--;
      }
      await roomRef.update({
        'runsPlayer1': runs,
        'ballCount': _ballCount,
        'p1Choice': null,
        'status': _ballCount <= 0 ? 'waiting' : 'in_progress',
      });
    }

    setState(() {
      _isChoosing = false;
      _selectedButton = '';
    });
  }

  void _handleOut() async {
    final roomRef = _database.ref('rooms/${widget.roomId}');

    // Check who is currently the batsman and swap roles

    // Update the role swap in Firebase
    await roomRef.update({
      'batsmanId': _bowlerId,
      'bowlerId': _batsmanId,
      'ballCount': _totalBalls, // Reset ball count for the new batsman
      'status': 'in_progress',
    });

    // Update the local state
    setState(() {
      String temp = _batsmanId;
      _batsmanId = _bowlerId;
      _bowlerId = temp;
      _ballCount = _totalBalls;
    });

    // Show role swap dialog or notification
    _showRoleSwapDialog();

    // Reset player choices after role swap
    await roomRef.update({
      'p1Choice': null,
    });

    setState(() {
      _isChoosing = false;
      _selectedButton = '';
    });
  }

  void _swapRoles() async {
    final roomRef = _database.ref('rooms/${widget.roomId}');

    // Swap the batsman and bowler IDs
    String newBatsmanId = _bowlerId;
    String newBowlerId = _batsmanId;

    // Update Firebase with the new roles and reset the ball count
    await roomRef.update({
      'batsmanId': newBatsmanId,
      'bowlerId': newBowlerId,
      'ballCount': _totalBalls, // Reset ball count for the new innings
      'status': 'in_progress',
    });

    // Update the local state
    setState(() {
      _batsmanId = newBatsmanId;
      _bowlerId = newBowlerId;
      _ballCount = _totalBalls;
    });

    // Reset choices after the role swap
    await roomRef.update({
      'p1Choice': null,
    });

    // Notify the players about the role swap
    _showRoleSwapDialog();
  }

  void _showRoleSwapDialog() {
    // Show the dialog after a 3-second delay
    Timer(Duration(seconds: 3), () {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          // Another timer to automatically close the dialog after 3 seconds
          Timer(Duration(seconds: 3), () {
            Navigator.of(context).pop(); // Close the dialog
          });

          return AlertDialog(
            title: const Text("Role Swap"),
            content:
                const Text("Roles have been swapped. You are now the bowler."),
            actions: [
              TextButton(
                child: const Text("OK"),
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog manually
                },
              ),
            ],
          );
        },
      );
    });
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
                _isChoosing = true; // Disable buttons while processing
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
}*/
