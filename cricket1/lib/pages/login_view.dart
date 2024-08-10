import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart'; // Add this dependency to use Slidable

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController _email;
  late final TextEditingController _password;

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
          // Top circle design
          Positioned(
            top: -80,
            left: -60,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Color(0xff023047).withOpacity(0.8), // Dark Blue
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
                color: Color(0xff219ebc).withOpacity(0.8), // Medium Blue
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
                color: Color(0xffffb703).withOpacity(0.8), // Bright Yellow
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(100),
                  topRight: Radius.circular(100),
                ),
              ),
            ),
          ),
          // Cricket bat design
          Positioned(
            top: 200,
            left: 30,
            child: Column(
              children: [
                // Handle
                Container(
                  width: 20,
                  height: 80,
                  color: Color(0xff023047), // Dark Blue
                ),
                // Blade
                Container(
                  width: 60,
                  height: 180,
                  decoration: BoxDecoration(
                    color: Color(0xfffb8500), // Orange
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(10),
                      bottomRight: Radius.circular(10),
                    ),
                  ),
                ),
              ],
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
                      Navigator.pop(context); // Navigate back to HomePage
                    },
                    backgroundColor: Color(0xff023047), // Dark Blue
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
                      autocorrect: false,
                    ),
                    SizedBox(height: 40),
                    TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(
                        backgroundColor: Color(0xff219ebc), // Medium Blue
                        padding: EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Login',
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
