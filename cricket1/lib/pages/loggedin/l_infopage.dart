import 'package:flutter/material.dart';

class InfoPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Game Instructions',
            style: TextStyle(color: Colors.white)),
        backgroundColor: Color.fromRGBO(11, 42, 33, 1.0),
        centerTitle: true,
      ),
      body: const Stack(
        children: [
          // Background circles
          Positioned(
            top: -50,
            left: -50,
            child: CircleAvatar(
              radius: 100,
              backgroundColor: Color.fromRGBO(213, 206, 163, 0.3),
            ),
          ),
          Positioned(
            bottom: -50,
            right: -50,
            child: CircleAvatar(
              radius: 100,
              backgroundColor: Color.fromRGBO(19, 73, 58, 0.3),
            ),
          ),
          Positioned(
            top: 150,
            right: -50,
            child: CircleAvatar(
              radius: 80,
              backgroundColor: Color.fromRGBO(26, 18, 11, 0.3),
            ),
          ),
          Positioned(
            bottom: 150,
            left: -50,
            child: CircleAvatar(
              radius: 80,
              backgroundColor: Color.fromRGBO(213, 206, 163, 0.3),
            ),
          ),
          Center(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome to the Ultimate Cricket Showdown!',
                    style: TextStyle(
                      fontSize: 24,
                      color: Color.fromARGB(255, 19, 73, 58),
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  Text(
                    '1) Players are randomly assigned roles. Keep an eye on the screen!',
                    style: TextStyle(
                      fontSize: 18,
                      color: Color.fromRGBO(26, 18, 11, 1.0),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    '2) If you\'re the batsman, score as many runs as possible before getting out.',
                    style: TextStyle(
                      fontSize: 18,
                      color: Color.fromRGBO(26, 18, 11, 1.0),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    '3) If you\'re the bowler, try to outsmart the batsman by picking the same number!',
                    style: TextStyle(
                      fontSize: 18,
                      color: Color.fromRGBO(26, 18, 11, 1.0),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    '4) After the first round, the roles swap. Time for a comeback!',
                    style: TextStyle(
                      fontSize: 18,
                      color: Color.fromRGBO(26, 18, 11, 1.0),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    '5) As the new batsman, aim to beat the first score. It\'s your chance to shine!',
                    style: TextStyle(
                      fontSize: 18,
                      color: Color.fromRGBO(26, 18, 11, 1.0),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    '6) Bowlers, a wicket here means victory! No pressure, right?',
                    style: TextStyle(
                      fontSize: 18,
                      color: Color.fromRGBO(26, 18, 11, 1.0),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    '7) Click the button only once and wait for the magic to happen! (Wait for the score to update)',
                    style: TextStyle(
                      fontSize: 18,
                      color: Color.fromRGBO(26, 18, 11, 1.0),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    '8) This game is all about fun! Get ready for some epic moments!',
                    style: TextStyle(
                      fontSize: 18,
                      color: Color.fromRGBO(26, 18, 11, 1.0),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
