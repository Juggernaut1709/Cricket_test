import 'package:cricket1/pages/loggedin/l_homepage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart'; // Add this dependency to use Slidable

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
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: Firebase.initializeApp(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            final user = FirebaseAuth.instance.currentUser;
            return Scaffold(
              backgroundColor: const Color(0xffE2BFD9), // Light Purple
              body: Stack(
                children: [
                  // Top circle design
                  Positioned(
                    top: -80,
                    left: -60,
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        color: const Color(0xff674188), // Dark Purple
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  // Bottom circle design
                  Positioned(
                    bottom: -100,
                    right: -80,
                    child: Container(
                      width: 250,
                      height: 250,
                      decoration: BoxDecoration(
                        color: const Color(0xffC8A1E0), // Light Lavender
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  // Middle wave-like background design
                  Positioned(
                    top: 250,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 400,
                      decoration: BoxDecoration(
                        color: const Color(0xffF7EFE5), // Light Cream
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(100),
                          topRight: Radius.circular(100),
                        ),
                      ),
                    ),
                  ),
                  // Slidable button to return to HomePage
                  Positioned(
                    bottom: 40,
                    left: 10,
                    right: 10,
                    child: Slidable(
                      startActionPane: ActionPane(
                        motion: ScrollMotion(),
                        children: [
                          SlidableAction(
                            onPressed: (context) {
                              Navigator.pop(
                                  context); // Navigate back to HomePage
                            },
                            backgroundColor:
                                const Color(0xff674188), // Dark Purple
                            foregroundColor: Colors.white,
                            icon: Icons.arrow_back,
                            label: 'Previous',
                          ),
                        ],
                      ),
                      child: const Text(''),
                    ),
                  ),
                  SingleChildScrollView(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            SizedBox(height: 120),
                            Text(
                              'LOGIN',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: const Color(0xff674188), // Dark Purple
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 40),
                            TextField(
                              controller: emailController,
                              decoration: InputDecoration(
                                hintText: 'Email',
                                filled: true,
                                fillColor:
                                    const Color(0xffF7EFE5), // Light Cream
                                prefixIcon: Icon(Icons.email,
                                    color:
                                        const Color(0xff674188)), // Dark Purple
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 20, horizontal: 20),
                              ),
                              keyboardType: TextInputType.emailAddress,
                            ),
                            SizedBox(height: 20),
                            TextField(
                              controller: passwordController,
                              decoration: InputDecoration(
                                hintText: 'Password',
                                filled: true,
                                fillColor:
                                    const Color(0xffF7EFE5), // Light Cream
                                prefixIcon: Icon(Icons.lock,
                                    color:
                                        const Color(0xff674188)), // Dark Purple
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 20, horizontal: 20),
                              ),
                              obscureText: true,
                              autocorrect: false,
                            ),
                            SizedBox(height: 40),
                            TextButton(
                              onPressed: () async {
                                final email = emailController.text;
                                final pword = passwordController.text;
                                try {
                                  final userCredential = await FirebaseAuth
                                      .instance
                                      .signInWithEmailAndPassword(
                                          email: email, password: pword);
                                  print(userCredential);
                                  if (user?.emailVerified == false) {
                                    showDialog(
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
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const HomePage()),
                                    );
                                  }
                                } on FirebaseAuthException catch (e) {
                                  if (e.code == 'invalid-credential') {
                                    showDialog(
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
                                }
                              },
                              style: TextButton.styleFrom(
                                backgroundColor:
                                    const Color(0xffC8A1E0), // Light Lavender
                                padding: EdgeInsets.symmetric(vertical: 20),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text(
                                'Login',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                // Navigate to RegisterView
                                Navigator.pushNamed(context, '/register');
                              },
                              child: const Text(
                                  "Don't have an account? Register here"),
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
            return Scaffold(
              body: Center(
                child: Text("Error initializing Firebase"),
              ),
            );
          } else {
            return Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
        });
  }
}
