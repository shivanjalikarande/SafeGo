import 'package:flutter/material.dart';
import 'package:supabase/supabase.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../supabase_client.dart';
import '../services/secure_storage_service.dart'; // import your secure storage service

class VerifyOtpPage extends StatefulWidget {
  const VerifyOtpPage({super.key});

  @override
  State<VerifyOtpPage> createState() => _VerifyOtpPageState();
}

class _VerifyOtpPageState extends State<VerifyOtpPage> {
  final otpController = TextEditingController();

  Future<void> _verifyOtp(Map args) async {
    final email = args['email'];
    final name = args['name'] ?? '';
    final phone = args['phone'] ?? '';
    final isLogin = args['isLogin'] ?? false;

    try {
      final res = await supabase.auth.verifyOTP(
        type: OtpType.email,
        token: otpController.text.trim(),
        email: email,
      );

      final user = res.user;
      final session = res.session;

      if (user != null && session != null) {
        if (!isLogin) {
          // Only insert into DB during signup
          final response = await http.post(
            Uri.parse(
              'http://192.168.58...:5000/auth/register',
            ), // If using emulator, otherwise use <localhost>
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'id': user.id,
              'email': email,
              'name': name,
              'phone': phone,
            }),
          );
          if (response.statusCode != 200) {
            throw Exception('User DB insert failed');
          }
        }

        // Store the JWT token in Secure Storage
        final jwtToken = session.accessToken;
        await SecureStorageService.write(
          'jwt',
          jwtToken,
        ); // This is where the token is saved

        Navigator.pushReplacementNamed(context, '/dashboard');
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Invalid OTP')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map? ?? {};

    return Scaffold(
      appBar: AppBar(title: const Text('Verify OTP')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: otpController,
              decoration: const InputDecoration(labelText: 'Enter OTP'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _verifyOtp(args),
              child: const Text('Verify'),
            ),
          ],
        ),
      ),
    );
  }
}
