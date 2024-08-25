import 'package:cricket1/pages/loggedin/l_homepage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as devtools show log;

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController emailController;
  late final TextEditingController passwordController;

  @override
  void initState() {
    emailController = TextEditingController();
    passwordController = TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: Firebase.initializeApp(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            final user = FirebaseAuth.instance.currentUser;
            return Material(
              color: const Color.fromRGBO(11, 42, 33, 1.0), // Dark Brown
              child: Stack(
                children: [
                  // Top-left circular design
                  Positioned(
                    top: -MediaQuery.of(context).size.height * 0.1,
                    left: -MediaQuery.of(context).size.width * 0.2,
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.6,
                      height: MediaQuery.of(context).size.width * 0.6,
                      decoration: const BoxDecoration(
                        color: Color.fromRGBO(213, 206, 163, 1.0), // Beige
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  // Bottom-right circular design
                  Positioned(
                    bottom: -MediaQuery.of(context).size.height * 0.1,
                    right: -MediaQuery.of(context).size.width * 0.2,
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.8,
                      height: MediaQuery.of(context).size.width * 0.9,
                      decoration: const BoxDecoration(
                        color: Color.fromRGBO(229, 229, 203, 1.0), // Off-White
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  // Slidable button to return to HomePage
                  SingleChildScrollView(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(height: 200),
                            const Text(
                              'LOGIN',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color.fromRGBO(
                                    229, 229, 203, 1.0), // Off-White
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 40),
                            Container(
                              decoration: BoxDecoration(
                                color: const Color.fromRGBO(
                                    213, 206, 163, 1.0), // Beige
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: TextField(
                                controller: emailController,
                                decoration: InputDecoration(
                                  hintText: 'Email',
                                  filled: true,
                                  fillColor: Colors.transparent,
                                  prefixIcon: const Icon(Icons.email,
                                      color: Color.fromRGBO(
                                          26, 18, 11, 1.0)), // Darker Brown
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                      vertical: 20, horizontal: 20),
                                ),
                                keyboardType: TextInputType.emailAddress,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Container(
                              decoration: BoxDecoration(
                                color: const Color.fromRGBO(
                                    213, 206, 163, 1.0), // Beige
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: TextField(
                                controller: passwordController,
                                decoration: InputDecoration(
                                  hintText: 'Password',
                                  filled: true,
                                  fillColor: Colors.transparent,
                                  prefixIcon: const Icon(Icons.lock,
                                      color: Color.fromRGBO(
                                          26, 18, 11, 1.0)), // Darker Brown
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                      vertical: 20, horizontal: 20),
                                ),
                                obscureText: true,
                                autocorrect: false,
                              ),
                            ),
                            const SizedBox(height: 40),
                            Container(
                              decoration: BoxDecoration(
                                color: const Color.fromRGBO(
                                    26, 18, 11, 1.0), // Darker Brown
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: TextButton(
                                onPressed: () async {
                                  final email = emailController.text;
                                  final pword = passwordController.text;
                                  try {
                                    final userCredential = await FirebaseAuth
                                        .instance
                                        .signInWithEmailAndPassword(
                                            email: email, password: pword);
                                    devtools.log(userCredential.user!.email!);
                                    if (user?.emailVerified == false) {
                                      showDialog(
                                        // ignore: use_build_context_synchronously
                                        context: context,
                                        builder: (context) {
                                          return const AlertDialog(
                                            title: Text('Unverified Email'),
                                            content: Text(
                                                "The Email given is not verified. Please verify and try again"),
                                          );
                                        },
                                      );
                                    } else {
                                      // Navigate to HomePage after successful login
                                      Navigator.pushReplacement(
                                        // ignore: use_build_context_synchronously
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const HomePage()),
                                      );
                                    }
                                  } on FirebaseAuthException catch (e) {
                                    if (e.code == 'invalid-credential') {
                                      showDialog(
                                        // ignore: use_build_context_synchronously
                                        context: context,
                                        builder: (context) {
                                          return const AlertDialog(
                                            title: Text('Invalid Credentials'),
                                            content: Text(
                                                "The Email or Password provided is wrong. Try Again"),
                                          );
                                        },
                                      );
                                    }
                                    if (e.code == 'channel-error') {
                                      showDialog(
                                        // ignore: use_build_context_synchronously
                                        context: context,
                                        builder: (context) {
                                          return const AlertDialog(
                                            title: Text('No value provided'),
                                            content: Text(
                                                "Please provide a valid Email and Password to login"),
                                          );
                                        },
                                      );
                                    }
                                  }
                                },
                                style: TextButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  padding: const EdgeInsets.all(0),
                                ),
                                child: Container(
                                  width: double.infinity,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 20),
                                  decoration: BoxDecoration(
                                    color: const Color.fromRGBO(
                                        26, 18, 11, 1.0), // Darker Brown
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: const Text(
                                    'Login',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                // Navigate to RegisterView
                                Navigator.pushNamed(context, '/register');
                              },
                              child: const Text(
                                  "Don't have an account? Register here",
                                  style: TextStyle(color: Colors.white)),
                            ),
                            const SizedBox(
                                height:
                                    20), // Additional spacing for when the keyboard is open
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          } else if (snapshot.hasError) {
            return const Scaffold(
              body: Center(
                child: Text("Error initializing Firebase"),
              ),
            );
          } else {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
        });
  }
}
