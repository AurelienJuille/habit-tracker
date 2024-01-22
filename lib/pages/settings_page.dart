import 'package:flutter/material.dart';
import 'package:habit_tracker_app/main.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatefulWidget {
  @override
  SettingsPageState createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.background,
        title: Text('Settings'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Dark Mode'),
            Switch(
              value: Theme.of(context).brightness == Brightness.dark,
              onChanged: (value) {
                // Change le mode sombre/clair
                Provider.of<HabitsProvider>(context, listen: false)
                    .toggleDarkMode(value);
              },
            ),
          ],
        ),
      ),
    );
  }
}
