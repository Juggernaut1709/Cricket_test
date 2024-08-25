import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:math';

class CreateRoom extends StatefulWidget {
  const CreateRoom({
    Key? key,
  }) : super(key: key);

  @override
  _CreateRoomState createState() => _CreateRoomState();
}

class _CreateRoomState extends State<CreateRoom> {
  late String roomId;
  late DatabaseReference userRef;
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
    userRef = FirebaseDatabase.instance.ref('users/$player1Id');

    final userSnapshot = await userRef.get();

    // Set initial room data
    await roomRef.set({
      'player1Id': player1Id,
      'player2Id': null,
      'batsmanId': null,
      'bowlerId': null,
      'runsPlayer1': 0,
      'runsPlayer2': 0,
      'batsmanChoice': null,
      'bowlerChoice': null,
      'p1Choice': null,
      'p2Choice': null,
      'status': 'waiting',
    });

    if (!userSnapshot.exists) {
      // If the user's data does not exist, initialize it
      await userRef.set({
        'wins': 0,
        'losses': 0,
        'draws': 0,
      });
    }

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
        backgroundColor: const Color.fromARGB(255, 26, 18, 11),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,
              color: Color.fromARGB(255, 213, 206, 163)),
          onPressed: () {
            Navigator.pop(context);
            // Remove the room when the user leaves the page
            roomRef.remove();
          },
        ),
        title: const Text('Create Room',
            style: TextStyle(color: Color.fromARGB(255, 213, 206, 163))),
      ),
      body: Stack(
        children: [
          Positioned(
            top: 50,
            left: 30,
            child: _buildCircle(70, const Color.fromARGB(255, 213, 206, 163)),
          ),
          Positioned(
            top: 150,
            right: 50,
            child: _buildCircle(50, const Color.fromARGB(255, 229, 229, 203)),
          ),
          Positioned(
            bottom: 200,
            left: 40,
            child: _buildCircle(90, const Color.fromARGB(255, 213, 206, 163)),
          ),
          Positioned(
            bottom: 100,
            right: 30,
            child: _buildCircle(60, const Color.fromARGB(255, 229, 229, 203)),
          ),
          Positioned(
            top: 300,
            left: 150,
            child: _buildCircle(40, const Color.fromARGB(255, 213, 206, 163)),
          ),
          Positioned(
            bottom: 50,
            left: 150,
            child: _buildCircle(50, const Color.fromARGB(255, 213, 206, 163)),
          ),
          Center(
            child: isLoading
                ? CircularProgressIndicator(
                    color: const Color.fromARGB(255, 213, 206, 163))
                : Text(
                    'Room ID: $roomId\nWaiting for another player to join...',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color.fromARGB(255, 213, 206, 163),
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ],
      ),
      backgroundColor: const Color.fromRGBO(11, 42, 33, 1.0),
    );
  }

  Widget _buildCircle(double diameter, Color color) {
    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}
