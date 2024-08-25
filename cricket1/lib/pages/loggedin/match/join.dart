import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class JoinRoom extends StatefulWidget {
  const JoinRoom({Key? key}) : super(key: key);

  @override
  _JoinRoomState createState() => _JoinRoomState();
}

class _JoinRoomState extends State<JoinRoom> {
  final TextEditingController _roomIdController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  late DatabaseReference userRef;

  bool _isJoining = false;
  String _errorMessage = '';

  Future<void> joinRoom() async {
    setState(() {
      _isJoining = true;
      _errorMessage = '';
    });

    final user = _auth.currentUser;
    final player2Id = user?.uid;
    final roomId = _roomIdController.text.trim();
    userRef = FirebaseDatabase.instance.ref('users/$player2Id');

    final userSnapshot = await userRef.get();

    if (roomId.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter a room ID.';
        _isJoining = false;
      });
      return;
    }

    final roomRef = FirebaseDatabase.instance.ref('rooms/$roomId');

    // Check if the room exists
    final roomSnapshot = await roomRef.get();
    if (!roomSnapshot.exists) {
      setState(() {
        _errorMessage = 'Room ID does not exist.';
        _isJoining = false;
      });
      return;
    }

    // Check if the room already has a second player
    final roomData = roomSnapshot.value as Map<dynamic, dynamic>;
    if (roomData['player2Id'] != null) {
      setState(() {
        _errorMessage = 'Room is already full.';
        _isJoining = false;
      });
      return;
    }

    // Set player2Id and start the game
    await roomRef.update({
      'player2Id': user?.uid,
      'status': 'in_progress',
    });

    if (!userSnapshot.exists) {
      // If the user's data does not exist, initialize it
      await userRef.set({
        'wins': 0,
        'losses': 0,
        'draws': 0,
      });
    }

    // Navigate to the game screen
    // ignore: use_build_context_synchronously
    Navigator.pushNamed(context, '/game', arguments: roomId);
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
        title: const Text('Join Room',
            style: TextStyle(color: Color.fromRGBO(20, 255, 236, 1))),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _roomIdController,
                decoration: InputDecoration(
                  labelText: 'Enter Room ID',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.text,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isJoining ? null : joinRoom,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(13, 115, 119, 1),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: _isJoining
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Join Room', style: TextStyle(fontSize: 18)),
              ),
              if (_errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Text(
                    _errorMessage,
                    style: const TextStyle(
                        color: Color.fromARGB(255, 235, 38, 24), fontSize: 16),
                  ),
                ),
            ],
          ),
        ),
      ),
      backgroundColor: const Color.fromRGBO(50, 50, 50, 1),
    );
  }
}
