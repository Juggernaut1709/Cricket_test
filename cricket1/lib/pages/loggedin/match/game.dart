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

  void someGameEndingFunction() {
    endGame(); // Call this function to clean up and navigate
  }

  void endGame() async {
    final roomRef = _database.ref('rooms/${widget.roomId}');
    if (roomRef != null || _batsmanId.isEmpty || _bowlerId.isEmpty) {
      await roomRef.remove();
      devtools.log('Room removed');
    }
    // ignore: use_build_context_synchronously
    Navigator.pushReplacementNamed(context, '/end');
  }

  Future<void> _initializeGame() async {
    final roomRef = _database.ref('rooms/${widget.roomId}');
    final roomSnapshot = await roomRef.get();

    if (roomSnapshot.exists) {
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

      // Check if both players are present and the game should start
      if (_batsmanId.isNotEmpty &&
          _bowlerId.isNotEmpty &&
          _status == 'waiting') {
        await roomRef.update({'status': 'in_progress'});
      }

      // Listen for changes to the game state
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
      // Handle the case where the room does not exist
      devtools.log('Room does not exist');
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
      _showOutScreen();
      _showRoleSwapDialog();
      await roomRef.update({
        'ballCount': _ballCount + balls,
        'batsmanChoice': null,
        'bowlerChoice': null,
        'runs${currentUserId == _batsmanId ? 'Player1' : 'Player2'}': runs + 0,
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
      // Swap roles
      await roomRef.update({
        'batsmanId': _bowlerId,
        'bowlerId': _batsmanId,
        'ballCount': 20, // Reset ball count for the new innings
        'status': 'waiting', // You can change status as needed
      });

      // Optional: Show a message indicating the roles have swapped
      _showRoleSwapDialog();
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

  void _showRoleSwapDialog() {
    showDialog(
      context: context,
      builder: (context) {
        // Create a Future for the automatic closing
        Future.delayed(const Duration(seconds: 5), () {
          if (Navigator.canPop(context)) {
            Navigator.of(context).pop();
          }
        });

        return AlertDialog(
          backgroundColor: const Color.fromRGBO(50, 50, 50, 1),
          content: const Text(
            'Roles have been swapped! The bowler is now the batsman, and vice versa.',
            style: TextStyle(
              color: Color.fromRGBO(20, 255, 236, 1),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          actions: [
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
}
