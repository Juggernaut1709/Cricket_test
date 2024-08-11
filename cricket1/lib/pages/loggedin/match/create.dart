import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

class CreatePage extends StatefulWidget {
  const CreatePage({super.key});

  @override
  _CreatePageState createState() => _CreatePageState();
}

class _CreatePageState extends State<CreatePage> {
  late String uniqueNumber;
  late FirebaseFirestore firestore;

  @override
  void initState() {
    super.initState();
    firestore = FirebaseFirestore.instance;
    generateUniqueNumber();
  }

  void generateUniqueNumber() async {
    final milliseconds = DateTime.now().millisecondsSinceEpoch;
    final random = Random().nextInt(999); // Add randomness to ensure uniqueness
    uniqueNumber = '$milliseconds$random';

    // Save the unique number to Firestore
    await firestore.collection('sync').doc(uniqueNumber).set({
      'joined': false,
    });

    // Listen for changes to the document
    firestore
        .collection('sync')
        .doc(uniqueNumber)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists && snapshot.data()?['joined'] == true) {
        // Navigate to another page or show a message when the JOIN is successful
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => const AnotherPage()));
      }
    });

    // Simulate a loading delay
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {});
    });
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
          'Create',
          style: TextStyle(
            color: Color(0xffF7EFE5),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            uniqueNumber.isEmpty
                ? CircularProgressIndicator(
                    color: const Color(0xff674188),
                  )
                : Text(
                    'Your Unique Number: $uniqueNumber',
                    style: const TextStyle(
                      color: Color(0xff674188),
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ],
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
