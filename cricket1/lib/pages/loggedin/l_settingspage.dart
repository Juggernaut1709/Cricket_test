import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text('Attribute 1'),
            subtitle: Text('Description of Attribute 1'),
            trailing: Switch(
              value: true,
              onChanged: (value) {},
            ),
          ),
          ListTile(
            title: Text('Attribute 2'),
            subtitle: Text('Description of Attribute 2'),
            trailing: Switch(
              value: false,
              onChanged: (value) {},
            ),
          ),
          ListTile(
            title: Text('Attribute 3'),
            subtitle: Text('Description of Attribute 3'),
            trailing: Switch(
              value: true,
              onChanged: (value) {},
            ),
          ),
          // Add more ListTiles for additional attributes
        ],
      ),
    );
  }
}
