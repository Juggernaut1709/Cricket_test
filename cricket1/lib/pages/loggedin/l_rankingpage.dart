import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fl_chart/fl_chart.dart';

class RankingPage extends StatefulWidget {
  const RankingPage({Key? key}) : super(key: key);

  @override
  _RankingPageState createState() => _RankingPageState();
}

class _RankingPageState extends State<RankingPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  late String _currentUserId;
  int _wins = 0;
  int _losses = 0;

  @override
  void initState() {
    super.initState();
    _currentUserId = _auth.currentUser!.uid;
    _fetchUserStats();
  }

  Future<void> _fetchUserStats() async {
    final userRef = _database.ref('players/$_currentUserId');
    final snapshot = await userRef.get();
    final data = snapshot.value as Map<dynamic, dynamic>?;

    setState(() {
      _wins = data?['wins'] ?? 0;
      _losses = data?['losses'] ?? 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(33, 33, 33, 1),
        title: const Text('Ranking',
            style: TextStyle(color: Color.fromRGBO(20, 255, 236, 1))),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Wins and Losses',
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color.fromRGBO(20, 255, 236, 1)),
            ),
            const SizedBox(height: 20),
            Expanded(child: _buildBarChart()),
          ],
        ),
      ),
      backgroundColor: const Color.fromRGBO(50, 50, 50, 1),
    );
  }

  Widget _buildBarChart() {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: (_wins > _losses ? _wins : _losses).toDouble() +
            1, // Add a little padding to the top
        titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                interval: 1, // This determines the interval of the titles
                getTitlesWidget: (value, meta) {
                  final titles = ['Wins', 'Losses'];
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    child: Text(
                      titles[value.toInt()],
                      style: TextStyle(color: Color.fromRGBO(20, 255, 236, 1)),
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                interval: 1, // This determines the interval of the titles
                getTitlesWidget: (value, meta) {
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    child: Text(
                      value.toInt().toString(),
                      style: TextStyle(color: Color.fromRGBO(20, 255, 236, 1)),
                    ),
                  );
                },
              ),
            )),
        borderData: FlBorderData(
          show: false,
        ),
        barGroups: [
          BarChartGroupData(
            x: 0,
            barRods: [
              BarChartRodData(
                toY: _wins.toDouble(),
                color: Colors.green,
                width: 30,
              ),
            ],
          ),
          BarChartGroupData(
            x: 1,
            barRods: [
              BarChartRodData(
                toY: _losses.toDouble(),
                color: Colors.red,
                width: 30,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
