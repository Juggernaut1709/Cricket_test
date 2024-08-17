import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:async';
import 'dart:math';

class GameScreen extends StatefulWidget {
  final String roomId;

  const GameScreen({Key? key, required this.roomId}) : super(key: key);

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  late String _currentUserId;
  late String _batsmanId;
  late String _bowlerId;
  late int _ballCount;
  late int _runsPlayer1;
  late int _runsPlayer2;
  late String _batsmanChoice;
  late String _bowlerChoice;
  late String _status;
  bool _isChoosing = false;

  @override
  void initState() {
    super.initState();
    _currentUserId = _auth.currentUser!.uid;
    _initializeGame();
  }

  Future<void> _initializeGame() async {
    final roomRef = _database.ref('rooms/${widget.roomId}');
    final roomSnapshot = await roomRef.get();
    final roomData = roomSnapshot.value as Map<dynamic, dynamic>;

    setState(() {
      _batsmanId = roomData['batsmanId'] ?? '';
      _bowlerId = roomData['bowlerId'] ?? '';
      _ballCount = roomData['ballCount'] ?? 0;
      _runsPlayer1 = roomData['runsPlayer1'] ?? 0;
      _runsPlayer2 = roomData['runsPlayer2'] ?? 0;
      _batsmanChoice = roomData['batsmanChoice'] ?? '';
      _bowlerChoice = roomData['bowlerChoice'] ?? '';
      _status = roomData['status'] ?? 'waiting';
    });

    print(
        'Room Data: $_batsmanId, $_bowlerId, $_ballCount, $_status'); // Debugging

    // Listen for changes to the game state
    roomRef.onValue.listen((event) {
      final updatedData = event.snapshot.value as Map<dynamic, dynamic>;
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

      print(
          'Updated Room Data: $_batsmanId, $_bowlerId, $_ballCount, $_status'); // Debugging
    });
  }

  Future<void> _makeChoice(String choice) async {
    if (_isChoosing || _status != 'in_progress') return;

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

    print('User Choice Updated: $choice'); // Debugging

    await Future.delayed(const Duration(seconds: 3), () async {
      final snapshot = await roomRef.get();
      final data = snapshot.value as Map<dynamic, dynamic>;

      final batsmanChoice = data['batsmanChoice'];
      final bowlerChoice = data['bowlerChoice'];

      print(
          'Batsman Choice: $batsmanChoice, Bowler Choice: $bowlerChoice'); // Debugging

      if (batsmanChoice != null && bowlerChoice != null) {
        _resolveChoices(batsmanChoice, bowlerChoice);
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
        _resolveChoices(newBatsmanChoice, newBowlerChoice);
      }
    });
  }

  void _resolveChoices(String batsmanChoice, String bowlerChoice) async {
    final roomRef = _database.ref('rooms/${widget.roomId}');

    if (batsmanChoice == bowlerChoice) {
      // Batsman is out, reset choices and update runs
      final currentUserId = _auth.currentUser!.uid;
      final runs = currentUserId == _batsmanId ? _runsPlayer1 : _runsPlayer2;
      await roomRef.update({
        'ballCount': _ballCount - 1,
        'batsmanChoice': null,
        'bowlerChoice': null,
        'runs${currentUserId == _batsmanId ? 'Player1' : 'Player2'}': runs + 0,
        'status': 'out',
      });

      // Display "OUT" screen
      _showOutScreen();
    } else {
      // Batsman scores a run
      final runs = _currentUserId == _batsmanId ? _runsPlayer1 : _runsPlayer2;
      await roomRef.update({
        'ballCount': _ballCount - 1,
        'batsmanChoice': null,
        'bowlerChoice': null,
        'runs${_currentUserId == _batsmanId ? 'Player1' : 'Player2'}': runs + 1,
        'status': 'in_progress',
      });
    }

    // Check if 20 balls are done
    if (_ballCount <= 1) {
      // Swap roles or end the game
      final newStatus = _status == 'completed' ? 'completed' : 'waiting';
      await roomRef.update({
        'batsmanId': _bowlerId,
        'bowlerId': _batsmanId,
        'ballCount': 20,
        'status': newStatus,
      });
    }

    setState(() {
      _isChoosing = false;
    });
  }

  void _showOutScreen() {
    showDialog(
      context: context,
      builder: (context) {
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
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Continue the game
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
    final isBatsman = _auth.currentUser!.uid == _batsmanId;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(33, 33, 33, 1),
        title: Text('Game - ${widget.roomId}',
            style: const TextStyle(color: Color.fromRGBO(20, 255, 236, 1))),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
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
              const SizedBox(height: 20),
              if (_status == 'in_progress')
                if (isBatsman)
                  _buildChoiceButtons(isBatsman: true)
                else
                  _buildChoiceButtons(isBatsman: false)
              else
                const Text(
                  'Waiting for the game to start...',
                  style: TextStyle(
                      fontSize: 16, color: Color.fromRGBO(20, 255, 236, 1)),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChoiceButtons({required bool isBatsman}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(6, (index) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromRGBO(13, 115, 119, 1),
            ),
            onPressed: () {
              if (_isChoosing) return;
              _makeChoice((index + 1).toString());
            },
            child: Text(
              '${index + 1}',
              style: const TextStyle(
                color: Color(0xFF02111b),
                fontSize: 18,
              ),
            ),
          ),
        );
      }),
    );
  }
}
