import 'package:cricket1/firebase_options.dart';
import 'package:cricket1/pages/home_view.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    /*return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text('HOME'),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: FutureBuilder(
              future: Firebase.initializeApp(
                options: DefaultFirebaseOptions.currentPlatform,
              ),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.done:
                    return LoginView();
                  default:
                    return const Text('LOADING...');
                }
              }),
        ),
      ),
    );*/
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cricket Cricket',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromRGBO(255, 173, 96, 0.2)),
        useMaterial3: true,
      ),
      home: HomePage(),
    );
  }
}
