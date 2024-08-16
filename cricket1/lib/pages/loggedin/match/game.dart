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
      _batsmanId = roomData['batsmanId'];
      _bowlerId = roomData['bowlerId'];
      _ballCount = roomData['ballCount'];
      _runsPlayer1 = roomData['runsPlayer1'];
      _runsPlayer2 = roomData['runsPlayer2'];
      _batsmanChoice = roomData['batsmanChoice'] ?? '';
      _bowlerChoice = roomData['bowlerChoice'] ?? '';
      _status = roomData['status'] ?? 'waiting';
    });

    // Listen for changes to the game state
    roomRef.onValue.listen((event) {
      final updatedData = event.snapshot.value as Map<dynamic, dynamic>;
      setState(() {
        _batsmanId = updatedData['batsmanId'];
        _bowlerId = updatedData['bowlerId'];
        _ballCount = updatedData['ballCount'];
        _runsPlayer1 = updatedData['runsPlayer1'];
        _runsPlayer2 = updatedData['runsPlayer2'];
        _batsmanChoice = updatedData['batsmanChoice'] ?? '';
        _bowlerChoice = updatedData['bowlerChoice'] ?? '';
        _status = updatedData['status'] ?? 'waiting';
      });
    });
  }

  Future<void> _makeChoice(String choice) async {
    if (_isChoosing) return;

    setState(() {
      _isChoosing = true;
    });

    final roomRef = _database.ref('rooms/${widget.roomId}');
    final currentUserId = _auth.currentUser!.uid;

    if (currentUserId == _batsmanId) {
      await roomRef.update({
        'batsmanChoice': choice,
      });
    } else if (currentUserId == _bowlerId) {
      await roomRef.update({
        'bowlerChoice': choice,
      });
    }

    // Wait for both choices to be made or for the timeout
    await Future.delayed(const Duration(seconds: 3), () async {
      final snapshot = await roomRef.get();
      final data = snapshot.value as Map<dynamic, dynamic>;

      final batsmanChoice = data['batsmanChoice'];
      final bowlerChoice = data['bowlerChoice'];

      if (batsmanChoice != null && bowlerChoice != null) {
        _resolveChoices(batsmanChoice, bowlerChoice);
      } else {
        // Randomly choose if the player didn't choose in time
        if (batsmanChoice == null) {
          await roomRef.update({
            'batsmanChoice': Random().nextInt(6) + 1,
          });
        }
        if (bowlerChoice == null) {
          await roomRef.update({
            'bowlerChoice': Random().nextInt(6) + 1,
          });
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
      });
    } else {
      // Batsman scores a run
      final runs = _currentUserId == _batsmanId ? _runsPlayer1 : _runsPlayer2;
      await roomRef.update({
        'ballCount': _ballCount - 1,
        'batsmanChoice': null,
        'bowlerChoice': null,
        'runs${_currentUserId == _batsmanId ? 'Player1' : 'Player2'}': runs + 1,
      });
    }

    // Check if 20 balls are done
    if (_ballCount <= 1) {
      // Swap roles
      await roomRef.update({
        'batsmanId': _bowlerId,
        'bowlerId': _batsmanId,
        'ballCount': 20,
      });
    }

    setState(() {
      _isChoosing = false;
    });
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
              if (isBatsman)
                _buildChoiceButtons()
              else
                Text(
                  'Waiting for the batsman to make a choice...',
                  style: const TextStyle(
                      fontSize: 18, color: Color.fromRGBO(20, 255, 236, 1)),
                ),
            ],
          ),
        ),
      ),
      backgroundColor: const Color.fromRGBO(50, 50, 50, 1),
    );
  }

  Widget _buildChoiceButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(6, (index) {
        final choice = (index + 1).toString();
        return ElevatedButton(
          onPressed: _isChoosing ? null : () => _makeChoice(choice),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromRGBO(13, 115, 119, 1),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(choice,
              style: const TextStyle(
                  fontSize: 18, color: Color.fromRGBO(20, 255, 236, 1))),
        );
      }),
    );
  }
}
