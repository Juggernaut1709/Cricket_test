import 'package:cricket1/pages/loggedin/l_rankingpage.dart';
import 'package:cricket1/pages/loggedin/l_infopage.dart';
import 'package:cricket1/pages/loggedin/match/create.dart';
import 'package:cricket1/pages/loggedin/match/join.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int? selectedBalls;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Stack(
        children: [
          Column(
            children: [
              Container(
                height: 55,
                color: Color.fromRGBO(26, 18, 11, 1.0),
              ),
              Container(
                color: const Color.fromRGBO(213, 206, 163,
                    1.0), // Dark background color for the title bar
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Row(
                  children: [
                    PopupMenuButton<int>(
                      icon: const Icon(Icons.menu,
                          color: Color.fromRGBO(26, 18, 11, 1.0)),
                      color: const Color.fromRGBO(26, 18, 11, 1.0),
                      onSelected: (item) {
                        if (item == 2) {
                          Navigator.pushNamedAndRemoveUntil(context, '/login',
                              (route) => false); // Go back on Sign Out
                        } else if (item == 1) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => InfoPage()),
                          );
                        } else if (item == 0) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const RankingPage()),
                          );
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem<int>(
                          value: 0,
                          child: Row(
                            children: const [
                              Icon(Icons.leaderboard,
                                  color: Color.fromRGBO(213, 206, 163, 1.0)),
                              SizedBox(width: 8),
                              Text("Ranking",
                                  style: TextStyle(
                                      color:
                                          Color.fromRGBO(213, 206, 163, 1.0))),
                            ],
                          ),
                        ),
                        PopupMenuItem<int>(
                          value: 1,
                          child: Row(
                            children: const [
                              Icon(Icons.info,
                                  color: Color.fromRGBO(213, 206, 163, 1.0)),
                              SizedBox(width: 8),
                              Text("Info",
                                  style: TextStyle(
                                      color:
                                          Color.fromRGBO(213, 206, 163, 1.0))),
                            ],
                          ),
                        ),
                        PopupMenuItem<int>(
                          value: 2,
                          child: Row(
                            children: const [
                              Icon(Icons.logout,
                                  color: Color.fromRGBO(213, 206, 163, 1.0)),
                              SizedBox(width: 8),
                              Text("Sign Out",
                                  style: TextStyle(
                                      color:
                                          Color.fromRGBO(213, 206, 163, 1.0))),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(left: 110),
                        child: Text(
                          'HOME',
                          style: TextStyle(
                            color: Color.fromRGBO(26, 18, 11, 1.0),
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: _buildButtonSection(
                          color: const Color.fromRGBO(11, 42, 33, 1.0),
                          buttonText: 'CREATE',
                          buttonColor: const Color.fromRGBO(213, 206, 163, 1.0),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CreateRoom(),
                              ),
                            );
                          }),
                    ),
                    Expanded(
                      child: _buildButtonSection(
                        color: Color.fromARGB(255, 19, 73, 58),
                        buttonText: 'JOIN',
                        buttonColor: const Color.fromRGBO(213, 206, 163, 1.0),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const JoinRoom()),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
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

  Widget _buildButtonSection({
    required Color color,
    required String buttonText,
    required Color buttonColor,
    required VoidCallback onPressed,
  }) {
    return Container(
      color: color,
      child: Center(
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: buttonColor,
            padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30), // Circular corners
            ),
          ),
          child: Text(
            buttonText,
            style: const TextStyle(
              color: Color(0xFF02111B),
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
