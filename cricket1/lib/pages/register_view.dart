import 'package:flutter/material.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  late final TextEditingController _email;
  late final TextEditingController _password;
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Color(0xff8ecae6), // Light Blue for the overall background
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
                color: Color(0xff023047).withOpacity(0.8), // Dark Blue
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
                color: Color(0xffffb703).withOpacity(0.8), // Bright Yellow
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
                color: Color(0xff800000), // Maroon Red color for the ball
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
                        color: Color(0xfffb8500), // Orange
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 40),
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'Email',
                        filled: true,
                        fillColor:
                            Color(0xffffb703).withOpacity(0.2), // Light Yellow
                        prefixIcon: Icon(Icons.email, color: Color(0xfffb8500)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 20, horizontal: 20),
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
                            Color(0xffffb703).withOpacity(0.2), // Light Yellow
                        prefixIcon: Icon(Icons.lock, color: Color(0xfffb8500)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 20, horizontal: 20),
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
                        fillColor:
                            Color(0xffffb703).withOpacity(0.2), // Light Yellow
                        prefixIcon: Icon(Icons.lock, color: Color(0xfffb8500)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                      ),
                      obscureText: true,
                      enableSuggestions: false,
                      autocorrect: false,
                    ),
                    SizedBox(height: 40),
                    TextButton(
                      onPressed: () {
                        // Check if the passwords match
                        if (passwordController.text !=
                            confirmPasswordController.text) {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AboutDialog(
                                applicationName: 'Password Mismatch',
                                applicationVersion: '1.0',
                                children: [
                                  Text(
                                    'The passwords do not match. Please try again.',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Color(0xff023047),
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        } else {
                          // Perform registration logic here
                        }
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: Color(0xff219ebc), // Medium Blue
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
  }
}
