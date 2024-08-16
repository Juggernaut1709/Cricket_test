import 'package:cricket1/pages/loggedin/l_rankingpage.dart';
import 'package:cricket1/pages/loggedin/l_settingspage.dart';
import 'package:cricket1/pages/loggedin/match/create.dart';
import 'package:cricket1/pages/loggedin/match/join.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int? selectedBalls;

  void _createRoom() {
    if (selectedBalls == null) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Error"),
            content: const Text(
                "Number of balls must be specified before creating the room."),
            actions: [
              TextButton(
                child: const Text("OK"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CreateRoom(balls: selectedBalls!),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Container to replace AppBar
          Container(
            color:
                const Color.fromARGB(255, 33, 33, 33), // Dark background color
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Row(
              children: [
                // Menu on the left
                PopupMenuButton<int>(
                  icon: const Icon(Icons.menu,
                      color: Color(0xFF14FFEC)), // Bright color for the icon
                  color: const Color(0xFF14FFEC), // Bright color for the menu
                  onSelected: (item) {
                    if (item == 2) {
                      Navigator.of(context).pop(); // Go back on Sign Out
                    } else if (item == 1) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SettingsPage()),
                      );
                    } else if (item == 0) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => RankingPage()),
                      );
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem<int>(
                      value: 0,
                      child: Row(
                        children: const [
                          Icon(Icons.leaderboard,
                              color: Color(
                                  0xFF0D7377)), // Teal color for the icons
                          SizedBox(width: 8),
                          Text("Ranking",
                              style: TextStyle(
                                  color: Color.fromARGB(255, 33, 33, 33))),
                        ],
                      ),
                    ),
                    PopupMenuItem<int>(
                      value: 1,
                      child: Row(
                        children: const [
                          Icon(Icons.settings, color: Color(0xFF0D7377)),
                          SizedBox(width: 8),
                          Text("Settings",
                              style: TextStyle(
                                  color: Color.fromARGB(255, 33, 33, 33))),
                        ],
                      ),
                    ),
                    PopupMenuItem<int>(
                      value: 2,
                      child: Row(
                        children: const [
                          Icon(Icons.logout, color: Color(0xFF0D7377)),
                          SizedBox(width: 8),
                          Text("Sign Out",
                              style: TextStyle(
                                  color: Color.fromARGB(255, 33, 33, 33))),
                        ],
                      ),
                    ),
                  ],
                ),
                // Centered title
                const Expanded(
                  child: Center(
                    child: Text(
                      'HOME',
                      style: TextStyle(
                        color: Color(0xFF14FFEC), // Bright color for the title
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // The rest of the page
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    color: const Color.fromARGB(
                        255, 50, 50, 50), // Slightly lighter dark color
                    child: Stack(
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Buttons for 20, 50, 100
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildBallButton(20),
                                const SizedBox(width: 10),
                                _buildBallButton(50),
                                const SizedBox(width: 10),
                                _buildBallButton(100),
                              ],
                            ),
                            const SizedBox(height: 20),
                            // CREATE button
                            ElevatedButton(
                              onPressed: _createRoom,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(
                                    0xFF0D7377), // Teal color for the button
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 50, vertical: 20),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text(
                                'CREATE',
                                style: TextStyle(
                                  color: Color(
                                      0xFF14FFEC), // Bright color for the text
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    color: const Color.fromARGB(
                        255, 33, 33, 33), // Dark color for the bottom section
                    child: Stack(
                      children: [
                        Center(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const JoinRoom()),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(
                                  0xFF14FFEC), // Bright color for the button
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 50, vertical: 20),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              'JOIN',
                              style: TextStyle(
                                color: Color(
                                    0xFF0D7377), // Teal color for the text
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBallButton(int value) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          selectedBalls = value;
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: selectedBalls == value
            ? const Color(0xFF14FFEC)
            : const Color(0xFF0D7377), // Toggle colors
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Text(
        '$value',
        style: const TextStyle(
          color: Color(0xFF02111B), // Text color
          fontSize: 20,
        ),
      ),
    );
  }
}
