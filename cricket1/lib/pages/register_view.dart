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
          return Scaffold(
            backgroundColor:
                Color(0xFFF7EFE5), // Light Cream for the overall background
            body: Stack(
              children: [
                // Top curved background design
                Positioned(
                  top: -50,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 300,
                    decoration: BoxDecoration(
                      color: Color(0xFF674188).withOpacity(0.8), // Deep Purple
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(150),
                        bottomRight: Radius.circular(150),
                      ),
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
                          Color(0xFFC8A1E0).withOpacity(0.8), // Light Lavender
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                // Cricket ball design
                Positioned(
                  top: 200,
                  left: 30,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Color(0xFFE2BFD9), // Light Pink for the ball
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        // Stitches
                        Center(
                          child: Container(
                            height: 12,
                            width: 80,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                        ),
                        // Small white dots
                        Positioned(
                          top: 20,
                          left: 20,
                          child: Container(
                            width: 5,
                            height: 5,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 50,
                          left: 60,
                          child: Container(
                            width: 4,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 20,
                          right: 20,
                          child: Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 50,
                          right: 60,
                          child: Container(
                            width: 4,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
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
                          SizedBox(height: 120),
                          Text(
                            'REGISTER',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFF674188), // Deep Purple
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
                              fillColor: Color(0xFFC8A1E0)
                                  .withOpacity(0.2), // Light Lavender
                              prefixIcon:
                                  Icon(Icons.email, color: Color(0xFF674188)),
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
                              fillColor: Color(0xFFC8A1E0)
                                  .withOpacity(0.2), // Light Lavender
                              prefixIcon:
                                  Icon(Icons.lock, color: Color(0xFF674188)),
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
                          SizedBox(height: 20),
                          TextField(
                            controller: confirmPasswordController,
                            decoration: InputDecoration(
                              hintText: 'Confirm Password',
                              filled: true,
                              fillColor: Color(0xFFC8A1E0)
                                  .withOpacity(0.2), // Light Lavender
                              prefixIcon:
                                  Icon(Icons.lock, color: Color(0xFF674188)),
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
                          SizedBox(height: 40),
                          TextButton(
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
                                  } else if (e.code == 'email-already-in-use') {
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
                              backgroundColor: Color(0xFF674188), // Deep Purple
                              padding: EdgeInsets.symmetric(vertical: 20),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(
                              'Register',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
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
