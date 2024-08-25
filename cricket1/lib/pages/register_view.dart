import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'login_view.dart'; // Import the LoginView

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  late final TextEditingController emailController;
  late final TextEditingController passwordController;
  late final TextEditingController confirmPasswordController;

  @override
  void initState() {
    emailController = TextEditingController();
    passwordController = TextEditingController();
    confirmPasswordController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Firebase.initializeApp(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          // Firebase is initialized, show the registration form
          return Material(
            color: const Color.fromRGBO(
                11, 42, 33, 1.0), // Dark Gray for the overall background
            child: Stack(
              children: [
                // Top curved background design
                Positioned(
                  top: -250,
                  left: 0,
                  right: -100,
                  child: Container(
                    height: 450,
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(213, 206, 163, 1.0), // Teal
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                // Bottom half-circle design
                Positioned(
                  bottom: -100,
                  left: -100,
                  child: Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      color:
                          Color.fromRGBO(229, 229, 203, 1.0), // Very Dark Gray
                      shape: BoxShape.circle,
                    ),
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
                          SizedBox(height: 190),
                          Text(
                            'REGISTER',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color.fromRGBO(213, 206, 163, 1.0), // Teal
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 40),
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
                                fillColor: Colors.transparent, // Very Dark Gray
                                prefixIcon: Icon(Icons.email,
                                    color: Color.fromRGBO(26, 18, 11, 1.0)),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 20, horizontal: 20),
                              ),
                              keyboardType: TextInputType.emailAddress,
                            ),
                          ),
                          SizedBox(height: 20),
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
                                fillColor: Colors.transparent, // Very Dark Gray
                                prefixIcon: Icon(Icons.lock,
                                    color: Color.fromRGBO(26, 18, 11, 1.0)),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 20, horizontal: 20),
                              ),
                              obscureText: true,
                              enableSuggestions: false,
                              autocorrect: false,
                            ),
                          ),
                          SizedBox(height: 20),
                          Container(
                            decoration: BoxDecoration(
                              color: const Color.fromRGBO(
                                  213, 206, 163, 1.0), // Beige
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: TextField(
                              controller: confirmPasswordController,
                              decoration: InputDecoration(
                                hintText: 'Confirm Password',
                                filled: true,
                                fillColor: Colors.transparent, // Very Dark Gray
                                prefixIcon: Icon(Icons.lock,
                                    color: Color.fromRGBO(26, 18, 11, 1.0)),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 20, horizontal: 20),
                              ),
                              obscureText: true,
                              enableSuggestions: false,
                              autocorrect: false,
                            ),
                          ),
                          SizedBox(height: 40),
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
                                // Check if the passwords match
                                if (passwordController.text !=
                                    confirmPasswordController.text) {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return const AlertDialog(
                                        title: Text('Password Mismatch'),
                                        content: Text(
                                            'The passwords do not match. Please try again.'),
                                      );
                                    },
                                  );
                                } else {
                                  try {
                                    final userCredential = await FirebaseAuth
                                        .instance
                                        .createUserWithEmailAndPassword(
                                            email: email, password: pword);
                                    print(userCredential);
                                    await userCredential.user!
                                        .sendEmailVerification();
                                    // Navigate to LoginView after successful registration
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const LoginView()),
                                    );
                                  } on FirebaseAuthException catch (e) {
                                    if (e.code == 'weak-password') {
                                      showDialog(
                                        context: context,
                                        builder: (context) {
                                          return const AlertDialog(
                                            title: Text('Weak Password'),
                                            content: Text(
                                                "The password you've created is weak. Create a stronger password."),
                                          );
                                        },
                                      );
                                    } else if (e.code ==
                                        'email-already-in-use') {
                                      showDialog(
                                        context: context,
                                        builder: (context) {
                                          return const AlertDialog(
                                            title: Text('Email already in use'),
                                            content: Text(
                                                "The Email you've provided is already in use. Try giving another Email."),
                                          );
                                        },
                                      );
                                    } else if (e.code == 'invalid-email') {
                                      showDialog(
                                        context: context,
                                        builder: (context) {
                                          return const AlertDialog(
                                            title: Text('Invalid Email'),
                                            content: Text(
                                                "The Email you've provided is invalid. Try giving another Email."),
                                          );
                                        },
                                      );
                                    }
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
                                child: Text(
                                  'Register',
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
                              // Navigate to LoginView
                              Navigator.pushNamed(context, '/login');
                            },
                            child: const Text(
                                "Already have an account? Login here.",
                                style: TextStyle(
                                  color: Colors.white,
                                )),
                          ),
                          SizedBox(
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
      },
    );
  }
}
