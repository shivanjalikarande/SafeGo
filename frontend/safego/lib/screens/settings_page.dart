import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CheckInSettingsPage extends StatefulWidget {
  @override
  _CheckInSettingsPageState createState() => _CheckInSettingsPageState();
}

class _CheckInSettingsPageState extends State<CheckInSettingsPage> {
  bool _enableResponsivenessAlert = false;
  int _selectedIntervalMinutes = 5; // default to 5 minutes

  List<int> _intervalOptions = [5, 10, 15, 30, 60]; // in minutes

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _enableResponsivenessAlert = prefs.getBool('enable_alert') ?? false;
      _selectedIntervalMinutes = prefs.getInt('interval_minutes') ?? 5;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('enable_alert', _enableResponsivenessAlert);
    await prefs.setInt('interval_minutes', _selectedIntervalMinutes);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SwitchListTile(
              title: Text('Enable Responsiveness Alert?'),
              value: _enableResponsivenessAlert,
              onChanged: (bool value) {
                setState(() {
                  _enableResponsivenessAlert = value;
                });
                _saveSettings();
              },
            ),
            SizedBox(height: 20),
            if (_enableResponsivenessAlert) ...[
              Row(
                children: [
                  Text('Select Interval: '),
                  SizedBox(width: 10),
                  DropdownButton<int>(
                    value: _selectedIntervalMinutes,
                    onChanged: (int? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedIntervalMinutes = newValue;
                        });
                        _saveSettings();
                      }
                    },
                    items:
                        _intervalOptions.map((int minutes) {
                          return DropdownMenuItem<int>(
                            value: minutes,
                            child: Text('$minutes minutes'),
                          );
                        }).toList(),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
