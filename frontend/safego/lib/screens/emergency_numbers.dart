import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

class EmergencyNumbersPage extends StatefulWidget {
  final String country;

  const EmergencyNumbersPage({required this.country});

  @override
  State<EmergencyNumbersPage> createState() => _EmergencyNumbersPageState();
}

class _EmergencyNumbersPageState extends State<EmergencyNumbersPage> {
  Map<String, String>? numbers;

  @override
  void initState() {
    super.initState();
    fetchEmergencyNumbers();
  }

  Future<void> fetchEmergencyNumbers() async {
    final uri = Uri.parse(
      'http://localhost:5000/emergency/numbers?country=${widget.country}',
    );
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        numbers = Map<String, String>.from(data['emergencyNumbers']);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch emergency numbers')),
      );
    }
  }

  void _callNumber(String number) async {
    final Uri launchUri = Uri(scheme: 'tel', path: number);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Emergency Numbers')),
      body:
          numbers == null
              ? Center(child: CircularProgressIndicator())
              : ListView(
                children:
                    numbers!.entries.map((entry) {
                      return ListTile(
                        title: Text('${entry.key.toUpperCase()}'),
                        subtitle: Text(entry.value),
                        trailing: IconButton(
                          icon: Icon(Icons.call, color: Colors.red),
                          onPressed: () => _callNumber(entry.value),
                        ),
                      );
                    }).toList(),
              ),
    );
  }
}
