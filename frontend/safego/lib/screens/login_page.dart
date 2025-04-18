import 'package:flutter/material.dart';
import '../supabase_client.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final emailController = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final email = emailController.text.trim();

                // 1. Check user existence in DB
                final response = await http.post(
                  Uri.parse('http://localhost:5000/auth/check-user'),   //if using emulator, otherwise use <localhost>
                  headers: {'Content-Type': 'application/json'},
                  body: jsonEncode({'email': email}),
                );

                if (response.statusCode == 404) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('User not found. Please sign up first.'),
                    ),
                  );
                  Future.delayed(const Duration(seconds: 2), () {
                    Navigator.pushReplacementNamed(context, '/signup');
                  });
                  return;
                }

                // 2. If user exists, send OTP
                await supabase.auth.signInWithOtp(email: email);

                // 3. Navigate to OTP page with login context
                Navigator.pushNamed(
                  context,
                  '/verify-otp',
                  arguments: {'email': email, 'isLogin': true},
                );
              },
              child: const Text('Verify Email'),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/signup'),
              child: const Text('Do not have an account? Create Account'),
            ),
          ],
        ),
      ),
    );
  }
}
