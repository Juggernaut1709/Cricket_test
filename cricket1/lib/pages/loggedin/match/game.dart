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
  Timer? _timer;
  StreamSubscription? roomSubscription;
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
    roomSubscription?.cancel(); // Ensure to cancel the subscription
    _timer?.cancel(); // Ensure to cancel the timer
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
      _batsmanId = roomData['batsmanId'] ?? '';
      _bowlerId = roomData['bowlerId'] ?? '';
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
      _turn1();
    }
  }

  Future<void> _turn1() async {
    if (_currentUserId == _player1Id) {
      _player1Id == _batsmanId ? _showBatting() : _showBalling();
    } else {
      _player2Id == _batsmanId ? _showBatting() : _showBalling();
    }
    devtools.log(_batsmanId);
    devtools.log(_bowlerId);
    while (_ballCount > 0 && _status != 'out') {
      if (_player1Id == _currentUserId) {
        await _makeChoice(_p1Choice);
      } else {
        await _makeChoice(_p2Choice);
      }
    }
  }

  bool _timerActive = false; // Flag to ensure only one timer runs at a time

  Future<void> _makeChoice(String choice) async {
    setState(() {
      _isChoosing = true;
    });

    final roomRef = _database.ref('rooms/${widget.roomId}');
    final currentUserId = _auth.currentUser!.uid;

    // Update the choice for the current user
    if (currentUserId == _player1Id) {
      await roomRef.update({'p1Choice': choice});
    } else {
      await roomRef.update({'p2Choice': choice});
    }

    // Set up the timer to enforce a 5-second limit for choice selection
    if (!_timerActive) {
      _timerActive = true;

      _timer = Timer(Duration(seconds: 4), () async {
        final snapshot = await roomRef.get();
        final data = snapshot.value as Map<dynamic, dynamic>;

        if (currentUserId == _player1Id && data['p1Choice'] == null) {
          await roomRef
              .update({'p1Choice': (Random().nextInt(6) + 1).toString()});
        } else if (currentUserId == _player2Id && data['p2Choice'] == null) {
          await roomRef
              .update({'p2Choice': (Random().nextInt(6) + 1).toString()});
        }

        setState(() {
          _timerActive =
              false; // Reset the timer flag after the timer completes
          _isChoosing = false; // Re-enable buttons after the timer
        });
      });
    }

    // Cancel any existing listener before setting a new one
    await roomSubscription?.cancel();

    // Listen for changes in p1Choice and p2Choice
    roomSubscription = roomRef.onValue.listen((event) async {
      final data = event.snapshot.value as Map<dynamic, dynamic>;
      final p1Choice = data['p1Choice'];
      final p2Choice = data['p2Choice'];

      if (p1Choice != null && p2Choice != null) {
        // Both choices are available, resolve the game logic
        _resolveChoices(p1Choice, p2Choice);

        // Cancel the timer since both choices are made
        _timer?.cancel();
        _timer = null;

        // Cancel the listener to avoid multiple triggers
        await roomSubscription?.cancel();
        roomSubscription = null; // Clean up the reference

        setState(() {
          _isChoosing = false; // Re-enable buttons once choices are resolved
        });
      }
    });
  }

  void _resolveChoices(String p1Choice, String p2Choice) async {
    devtools.log('P1choice: $p1Choice, P2choice: $p2Choice');
    final roomRef = _database.ref('rooms/${widget.roomId}');
    bool isOut = (p1Choice == p2Choice);
    if (isOut) {
      _status = 'out';
      if (_player1Id == _currentUserId) {
        await roomRef.update({
          'status': 'out',
          'ballCount': _ballCount,
          'p1Choice': null,
          'p2Choice': null,
        });
      }
      if (_player1Id == _batsmanId) {
        await roomRef.update({
          'runsPlayer1': _runsPlayer1,
        });
      } else {
        await roomRef.update({
          'runsPlayer2': _runsPlayer2,
        });
      }
      //_handleOut();
    } else {
      int runs = (_batsmanId == _player1Id) ? _runsPlayer1 : _runsPlayer2;
      String runChoice = (_batsmanId == _player1Id) ? p1Choice : p2Choice;
      runs += int.parse(runChoice);

      if (_player1Id == _batsmanId) {
        await roomRef.update({
          'ballCount': _ballCount - 1,
          'runsPlayer1': runs,
          'p1Choice': null,
          'p2Choice': null,
        });
      } else {
        await roomRef.update({
          'ballCount': _ballCount - 1,
          'runsPlayer2': runs,
          'p1Choice': null,
          'p2Choice': null,
        });
      }
    }

    // Check game status after making a choice
    _checkGameStatus();
  }

  void _checkGameStatus() async {
    if (_ballCount <= 0) {
      // Both players have batted, decide the winner
      await _determineWinner();
    }
  }

  Future<void> _determineWinner() async {
    final roomRef = _database.ref('rooms/${widget.roomId}');
    final snapshot = await roomRef.get();
    final data = snapshot.value as Map<dynamic, dynamic>;

    final runsPlayer1 = data['runsPlayer1'] as int?;
    final runsPlayer2 = data['runsPlayer2'] as int?;

    if (runsPlayer1 == runsPlayer2) {
      // It's a draw
      await roomRef.update({'status': 'draw'});
    } else {
      // Determine winner
      String winner = runsPlayer1! > runsPlayer2! ? _player1Id : _player2Id;
      await roomRef.update({
        'status': winner,
      });

      // Update wins and losses
      await _updateStats(winner);
    }
  }

  Future<void> _updateStats(String winnerId) async {
    final loserId = winnerId == _player1Id ? _player2Id : _player1Id;
    final userRef = _database.ref('players');

    await userRef.child(winnerId).update({
      'wins': ServerValue.increment(1),
    });

    await userRef.child(loserId).update({
      'losses': ServerValue.increment(1),
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
}
