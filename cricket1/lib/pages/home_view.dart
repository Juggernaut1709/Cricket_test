import 'package:cricket1/pages/login_view.dart';
import 'package:cricket1/pages/register_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart'; // Add this dependency to use Slidable

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff30332e), // Dark Gray background
      body: Stack(
        children: [
          // Top design - half-circle
          Positioned(
            top: -50,
            left: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Color(0xff62bbc1), // Light Blue
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Bottom design - half-circle
          Positioned(
            bottom: -80,
            right: -80,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                color: Color(0xffec058e), // Bright Pink
                shape: BoxShape.circle,
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'WELCOME',
                  style: TextStyle(
                    color: Color(0xfffffbfc), // Off-White
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                  child: Slidable(
                    startActionPane: ActionPane(
                      motion: ScrollMotion(),
                      children: [
                        SlidableAction(
                          onPressed: (context) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const LoginView()),
                            );
                          },
                          backgroundColor: Color(0xffec058e), // Bright Pink
                          foregroundColor: Colors.white,
                          icon: Icons.login,
                          label: 'Login',
                        ),
                      ],
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Color(0xff62bbc1), // Light Blue
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 10,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ListTile(
                        title: Center(
                          child: Text(
                            'Go to Login',
                            style: TextStyle(
                              color: Color(0xff010400), // Dark Green
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                  child: Slidable(
                    startActionPane: ActionPane(
                      motion: ScrollMotion(),
                      children: [
                        SlidableAction(
                          onPressed: (context) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const RegisterView()),
                            );
                          },
                          backgroundColor: Color(0xff62bbc1), // Light Blue
                          foregroundColor: Colors.white,
                          icon: Icons.app_registration,
                          label: 'Register',
                        ),
                      ],
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Color(0xffec058e), // Bright Pink
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 10,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ListTile(
                        title: Center(
                          child: Text(
                            'Go to Register',
                            style: TextStyle(
                              color: Color(0xfffffbfc), // Off-White
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
