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
    while (_ballCount > 0 && _batsmanId == _currentUserId) {
      await _makeChoice(_p1Choice);
    }
  }

  Future<void> _turn2() async {
    while (_ballCount > 0 && _bowlerId == _currentUserId) {
      await _makeChoice(_p2Choice);
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
      await roomRef.update({'p1Choice': choice});
    } else if (currentUserId == _bowlerId) {
      await roomRef.update({'p2Choice': choice});
    }

    await Future.delayed(const Duration(seconds: 4), () async {
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
      final currentUserId = _auth.currentUser!.uid;
      final int runs;
      if (currentUserId == _batsmanId) {
        runs = _runsPlayer1;
        await roomRef.update({
          'ballCount': _ballCount,
          'p1Choice': null,
          'p2Choice': null,
          'runsPlayer1': runs,
          'status': 'out',
        });
      } else {
        runs = _runsPlayer2;
        await roomRef.update({
          'ballCount': _ballCount,
          'p1Choice': null,
          'p2Choice': null,
          'runsPlayer2': runs,
          'status': 'out',
        });
        _status = 'out';
      }
    } else {
      balls++;
      final int runs;
      final currentUserId = _auth.currentUser!.uid;
      if (currentUserId == _batsmanId) {
        runs = _runsPlayer1;
        await roomRef.update({
          'runsPlayer1': runs + int.parse(p1Choice),
          'ballCount': _ballCount - 1,
          'p1Choice': null,
          'p2Choice': null,
          'status': 'in_progress',
        });
      } else {
        runs = _runsPlayer2;
        await roomRef.update({
          'runsPlayer2': runs + int.parse(p2Choice),
          'ballCount': _ballCount - 1,
          'p1Choice': null,
          'p2Choice': null,
          'status': 'in_progress',
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

      _showRoleSwapDialog();
    }

    if ('out' == _status) {
      await roomRef.update({
        'batsmanId': _bowlerId,
        'bowlerId': _batsmanId,
        'ballCount': balls, // Reset ball count for the new innings
        'status': 'waiting',
      });

      _showRoleSwapDialog();
    }
    setState(() {
      _isChoosing = false;
      _selectedButton = '';
    });
  }

  Future<void> _showRoleSwapDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap a button
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Role Swap'),
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Text('Now it\'s time to swap roles.'),
                Text('The bowler will now bat, and the batsman will bowl.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _checkWinner() async {
    final roomRef = _database.ref('rooms/${widget.roomId}');
    final snapshot = await roomRef.get();
    final roomData = snapshot.value as Map<dynamic, dynamic>;
    final runsPlayer1 = roomData['runsPlayer1'] ?? 0;
    final runsPlayer2 = roomData['runsPlayer2'] ?? 0;

    String winnerMessage;
    if (runsPlayer1 > runsPlayer2) {
      winnerMessage = 'Player 1 wins!';
      await _updatePlayerStats(_batsmanId, true);
      await _updatePlayerStats(_bowlerId, false);
    } else if (runsPlayer2 > runsPlayer1) {
      winnerMessage = 'Player 2 wins!';
      await _updatePlayerStats(_batsmanId, false);
      await _updatePlayerStats(_bowlerId, true);
    } else {
      winnerMessage = 'The match is a DRAW!';
    }

    // Show the winner message
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Game Over'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(winnerMessage),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pushNamedAndRemoveUntil(
                    '/home', (Route<dynamic> route) => false);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _updatePlayerStats(String userId, bool isWinner) async {
    final playerRef = _database.ref('players/$userId');
    final snapshot = await playerRef.get();
    final playerData = snapshot.value as Map<dynamic, dynamic>;
    final wins = playerData['wins'] ?? 0;
    final losses = playerData['losses'] ?? 0;

    if (isWinner) {
      await playerRef.update({'wins': wins + 1});
    } else {
      await playerRef.update({'losses': losses + 1});
    }
  }

  void _onButtonPressed(String choice) {
    setState(() {
      _selectedButton = choice;
    });
    _makeChoice(choice);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Top-left for Player 1 Score
            Positioned(
              top: 10,
              left: 10,
              child: Text(
                'Player 1: $_runsPlayer1',
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.green,
                ),
              ),
            ),

            // Top-right for Player 2 Score
            Positioned(
              top: 10,
              right: 10,
              child: Text(
                'Player 2: $_runsPlayer2',
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.red,
                ),
              ),
            ),

            // Buttons at the bottom
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                padding:
                    EdgeInsets.only(bottom: 20), // Adjust padding as needed
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildChoiceButton('1'),
                    _buildChoiceButton('2'),
                    _buildChoiceButton('3'),
                    _buildChoiceButton('4'),
                    _buildChoiceButton('5'),
                    _buildChoiceButton('6'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChoiceButton(String choice) {
    final bool isSelected = choice == _selectedButton;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: ElevatedButton(
        onPressed: () => _onButtonPressed(choice),
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? Colors.blue : Colors.grey,
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0),
          textStyle: const TextStyle(fontSize: 20),
        ),
        child: Text(choice),
      ),
    );
  }
}
