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
  int _ballCount = 0;
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
    startListening();
  }

  @override
  void dispose() {
    _choiceTimer?.cancel();
    roomSubscription.cancel();
    roomRef.remove();
    super.dispose();
  }

  void _setupPlayerPresence(String roomId, String playerId) {
    DatabaseReference playerPresenceRef = FirebaseDatabase.instance
        .ref('rooms/$roomId/players/$playerId/presence');

    // Update the presence to 'online' when the player is connected
    playerPresenceRef.set('online');
    playerPresenceRef.onDisconnect().set('offline');
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
          _ballCount = roomData['ballCount'] ?? 0;
          _runsPlayer1 = roomData['runsPlayer1'] ?? 0;
          _runsPlayer2 = roomData['runsPlayer2'] ?? 0;
        });

        onPlayerJoin(widget.roomId, _currentUserId);

        _startGameListener();
      } else {
        devtools.log('Room not found');
      }
    } catch (e) {
      devtools.log('Error: $e');
    }
  }

  void onPlayerJoin(String roomId, String playerId) {
    // Set player as online
    final playerRef = FirebaseDatabase.instance.ref('rooms/$roomId/$playerId');

    playerRef
        .onDisconnect()
        .remove(); // Remove the player from the room on disconnect

    // Set initial status as online
    playerRef.set({"status": "online"});
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
            _ballCount = data['ballCount'];
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

  void startListening() {
    roomRef.onValue.listen((event) {
      if (event.snapshot.value != null) {
        Map roomData = event.snapshot.value as Map;

        if (roomData['player1Id'] == null || roomData['player2Id'] == null) {
          // If either player is null, close the room
          closeRoom(
              widget.roomId, roomData['player1Id'], roomData['player2Id']);
        }
      }
    });
  }

  void closeRoom(String roomId, String player1Id, String player2Id) {
    // Determine which player left
    String winnerId = player1Id != null ? player1Id : player2Id;
    String loserId = player1Id == null ? player2Id : player1Id;

    // Update player records
    if (winnerId != null) {
      FirebaseDatabase.instance
          .ref('players/$winnerId/wins')
          .set(ServerValue.increment(1));
    }
    if (loserId != null) {
      FirebaseDatabase.instance
          .ref('players/$loserId/losses')
          .set(ServerValue.increment(1));
    }

    // Close the room
    FirebaseDatabase.instance.ref('rooms/$roomId').remove();

    // Force navigation to home
    Navigator.pushReplacementNamed(context, '/home');
  }

  void _turn1() {
    try {
      if (!_isTurn1Active) return;
      if (_ballCount > 0) {
        devtools.log('Turn 1 started');
        _startChoiceTimer();
      } else {
        devtools.log('Game over');
        _endTurn1();
      }
    } catch (e) {
      devtools.log('Error: $e');
    }
  }

  void _turn2() {
    try {
      if (_ballCount > 0) {
        devtools.log('Turn 2 started');
        _startChoiceTimer();
      } else {
        devtools.log('Game over');
        _endTurn2();
      }
    } catch (e) {
      devtools.log('Error: $e');
    }
  }

  void _startChoiceTimer() {
    try {
      // Cancel any existing timer to avoid multiple timers running simultaneously
      if (_isGameActive) {
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

      if (turn == 1) {
        _turn1();
      } else {
        _turn2();
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
      Future.delayed(Duration(seconds: 2), () {
        _turn2();
      });
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
      Timer(Duration(seconds: 2), () {
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
      // Return a loading indicator or placeholder while the IDs are being initialized
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

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
