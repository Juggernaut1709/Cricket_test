import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class RankingPage extends StatefulWidget {
  const RankingPage({Key? key}) : super(key: key);

  @override
  _RankingPageState createState() => _RankingPageState();
}

class _RankingPageState extends State<RankingPage> {
  late Future<Map<String, dynamic>> _rankingData;

  @override
  void initState() {
    super.initState();
    _rankingData = _fetchRankingData();
  }

  Future<Map<String, dynamic>> _fetchRankingData() async {
    final user = FirebaseAuth.instance.currentUser;
    final userId = user?.uid;

    if (userId != null) {
      final ref = FirebaseDatabase.instance.ref('users/$userId');
      final snapshot = await ref.get();

      if (snapshot.exists) {
        return Map<String, dynamic>.from(snapshot.value as Map);
      }
    }
    return {};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
            child: Text('RANKING',
                style: TextStyle(
                  color: Color.fromARGB(255, 26, 18, 11),
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ))),
        backgroundColor: const Color.fromARGB(255, 213, 206, 163),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _rankingData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error fetching data'));
          } else {
            final data = snapshot.data ?? {};
            final wins = data['wins'] ?? 0;
            final losses = data['losses'] ?? 0;
            final draws = data['draws'] ?? 0;

            return Container(
              color: const Color.fromRGBO(11, 42, 33, 1.0),
              child: Center(
                // Center widget to center the column
                child: Column(
                  mainAxisSize: MainAxisSize.min, // Adjust to content size
                  children: [
                    _buildStatCard(
                        'Wins', wins, Color.fromARGB(255, 111, 78, 62)),
                    const SizedBox(height: 20),
                    _buildStatCard(
                        'Losses', losses, Color.fromARGB(255, 57, 39, 24)),
                    const SizedBox(height: 20),
                    _buildStatCard(
                        'Draws', draws, const Color.fromARGB(255, 26, 18, 11)),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildStatCard(String title, int value, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color.fromARGB(255, 213, 206, 163),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            value.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
