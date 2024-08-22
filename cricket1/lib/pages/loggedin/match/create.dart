import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:math';

class CreateRoom extends StatefulWidget {
  final int balls;

  const CreateRoom({
    Key? key,
    required this.balls, // Accept balls as a required parameter
  }) : super(key: key);

  @override
  _CreateRoomState createState() => _CreateRoomState();
}

class _CreateRoomState extends State<CreateRoom> {
  late String roomId;
  late DatabaseReference roomRef;
  bool isLoading = true;
  late String _batsmanId;
  late String _bowlerId;

  @override
  void initState() {
    super.initState();
    createRoom();
  }

  void dispose() {
    // Remove the room when the user leaves the page
    super.dispose();
  }

  void createRoom() async {
    // Generate a unique room ID based on the current time and a random number
    final milliseconds = DateTime.now().millisecondsSinceEpoch;
    final random = Random().nextInt(999);
    roomId = '$milliseconds$random';

    // Get the current user ID
    final user = FirebaseAuth.instance.currentUser;
    final player1Id = user?.uid;

    // Reference to the room in Firebase
    roomRef = FirebaseDatabase.instance.ref('rooms/$roomId');

    // Set initial room data
    await roomRef.set({
      'player1Id': player1Id,
      'player2Id': null,
      'batsmanId': null,
      'bowlerId': null,
      'ballCount': widget.balls,
      'runsPlayer1': 0,
      'runsPlayer2': 0,
      'batsmanChoice': null,
      'bowlerChoice': null,
      'p1Choice': null,
      'p2Choice': null,
      'status': 'waiting',
      'totalBalls': widget.balls,
    });

    // Set loading to false after room creation
    setState(() {
      isLoading = false;
    });

    // Listen for the second player joining
    roomRef.child('player2Id').onValue.listen((event) {
      if (event.snapshot.value != null) {
        // Player 2 has joined, start the game
        startGame();
      }
    });
  }

  void startGame() async {
    final user = FirebaseAuth.instance.currentUser;
    final player1Id = user?.uid;
    // Ensure we have a valid user and roomRef
    if (user == null || roomRef == null) return;

    final player2Id = (await roomRef.child('player2Id').get()).value as String?;

    if (player2Id == null) return;
    final random = Random();
    final isPlayer1Batsman =
        random.nextBool(); // Randomly choose which player is the batsman
    setState(() {
      _batsmanId = (isPlayer1Batsman ? player1Id : player2Id)!;
      _bowlerId = (isPlayer1Batsman ? player2Id : player1Id)!;
    });
    await roomRef.update({
      'batsmanId': _batsmanId,
      'bowlerId': _bowlerId,
      'status': 'in_progress'
    });

    Navigator.pushReplacementNamed(context, '/game', arguments: roomId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(33, 33, 33, 1),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,
              color: Color.fromRGBO(20, 255, 236, 1)),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('Create Room',
            style: TextStyle(color: Color.fromRGBO(20, 255, 236, 1))),
      ),
      body: Center(
        child: isLoading
            ? CircularProgressIndicator(
                color: const Color.fromRGBO(13, 115, 119, 1))
            : Text(
                'Room ID: $roomId\nWaiting for another player to join...',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color.fromRGBO(13, 115, 119, 1),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
      backgroundColor: const Color.fromRGBO(50, 50, 50, 1),
    );
  }
}
