import 'package:flutter/material.dart';
import '../supabase_client.dart'; // 👈 Import your Supabase client

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Supabase Flutter',
      home: Scaffold(
        appBar: AppBar(title: const Text('Supabase Example')),
        body: Center(
          child: ElevatedButton(
            onPressed: () async {
              final response = await supabase.from('users').select().execute();
              print(response.data);
            },
            child: const Text('Fetch Data'),
          ),
        ),
      ),
    );
  }
}
