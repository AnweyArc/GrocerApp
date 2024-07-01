import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'main.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Consumer<ThemeModel>(
        builder: (context, themeModel, child) {
          return ListTile(
            title: Text('Dark Mode'),
            trailing: Switch(
              value: themeModel.isDarkMode,
              onChanged: (value) {
                themeModel.toggleTheme();
              },
            ),
          );
        },
      ),
    );
  }
}
