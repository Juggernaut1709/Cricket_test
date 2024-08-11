import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class JoinPage extends StatefulWidget {
  const JoinPage({super.key});

  @override
  _JoinPageState createState() => _JoinPageState();
}

class _JoinPageState extends State<JoinPage> {
  final TextEditingController numberController = TextEditingController();
  late FirebaseFirestore firestore;

  @override
  void initState() {
    super.initState();
    firestore = FirebaseFirestore.instance;
  }

  void joinSession() async {
    final number = numberController.text;

    // Check if the document with the unique number exists
    final doc = await firestore.collection('sync').doc(number).get();

    if (doc.exists) {
      // Update the 'joined' field to true
      await firestore.collection('sync').doc(number).update({
        'joined': true,
      });

      // Navigate to the connected page or show a success message
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => const AnotherPage()));
    } else {
      // Show error if the number is invalid
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: const Text('Invalid Number!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff694F8E),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xffF7EFE5)),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Join',
          style: TextStyle(
            color: Color(0xffF7EFE5),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: numberController,
                decoration: const InputDecoration(
                  labelText: 'Enter Unique Number',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: joinSession,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff674188),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'JOIN',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AnotherPage extends StatelessWidget {
  const AnotherPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connected'),
      ),
      body: const Center(
        child: Text('You are now connected!'),
      ),
    );
  }
}
