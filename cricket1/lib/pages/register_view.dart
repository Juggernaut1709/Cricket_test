import 'package:cricket1/constants/routes.dart';
import 'package:cricket1/services/auth/auth_exp.dart';
import 'package:cricket1/services/auth/auth_services.dart';
import 'package:cricket1/services/dialog/dialog.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as devtools;
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
      future: AuthServices.firebase().initialize(),
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
                    decoration: const BoxDecoration(
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
                    decoration: const BoxDecoration(
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
                          const SizedBox(height: 190),
                          const Text(
                            'REGISTER',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color.fromRGBO(213, 206, 163, 1.0), // Teal
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
                                fillColor: Colors.transparent, // Very Dark Gray
                                prefixIcon: const Icon(Icons.email,
                                    color: Color.fromRGBO(26, 18, 11, 1.0)),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
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
                                fillColor: Colors.transparent, // Very Dark Gray
                                prefixIcon: const Icon(Icons.lock,
                                    color: Color.fromRGBO(26, 18, 11, 1.0)),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 20, horizontal: 20),
                              ),
                              obscureText: true,
                              enableSuggestions: false,
                              autocorrect: false,
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
                              controller: confirmPasswordController,
                              decoration: InputDecoration(
                                hintText: 'Confirm Password',
                                filled: true,
                                fillColor: Colors.transparent, // Very Dark Gray
                                prefixIcon: const Icon(Icons.lock,
                                    color: Color.fromRGBO(26, 18, 11, 1.0)),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 20, horizontal: 20),
                              ),
                              obscureText: true,
                              enableSuggestions: false,
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
                                final cpword = confirmPasswordController.text;
                                try {
                                  final userCredential =
                                      await AuthServices.firebase()
                                          .signUp(email, pword, cpword);
                                  print(userCredential);
                                  AuthServices.firebase()
                                      .sendEmailVerification();
                                  // Navigate to LoginView after successful registration
                                  Navigator.pushNamedAndRemoveUntil(
                                      context, LoginRoute, (route) => false);
                                } on EmailAlreadyInUseException {
                                  showErrorDialog(
                                    context,
                                    'Email already in use',
                                    'The email you entered is already in use. Please try again.',
                                  );
                                } on WeakPasswordException {
                                  showErrorDialog(
                                    context,
                                    'Weak password',
                                    'The password you entered is too weak. Please try again.',
                                  );
                                } on InvalidEmailException {
                                  showErrorDialog(
                                    context,
                                    'Invalid email',
                                    'The email you entered is invalid. Please try again.',
                                  );
                                } on UserNotCreatedException {
                                  showErrorDialog(
                                    context,
                                    'User not created',
                                    'The user could not be created. Please try again.',
                                  );
                                } on GeneralException catch (e) {
                                  showErrorDialog(
                                    context,
                                    'General exception',
                                    'An exception occurred: ${e.message}',
                                  );
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
                              Navigator.pushNamedAndRemoveUntil(
                                  context, LoginRoute, (route) => false);
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
