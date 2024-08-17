import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(33, 33, 33, 1),
        title: const Text('Settings',
            style: TextStyle(color: Color.fromRGBO(20, 255, 236, 1))),
      ),
    );
  }
}
