import 'package:flutter/material.dart';
import 'dart:async';
import './dashboard_screen.dart';
// import '../supabase_client.dart';
import './signup_page.dart'; // import your login screen
import '../services/auth_service.dart'; // auth session logic

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkSessionAndNavigate();
    // Timer(Duration(seconds: 15), () {
    //   Navigator.pushReplacement(
    //     context,
    //     MaterialPageRoute(builder: (context) => DashboardScreen()),
    //   );
    // });
  }

  Future<void> _checkSessionAndNavigate() async {
    // Wait 2 seconds just to show splash screen animation/logo
    await Future.delayed(Duration(seconds: 2));

    // Check and refresh session using AuthService
    bool isLoggedIn = await AuthService.checkAndRefreshSession();

    // Navigate based on login state
    if (isLoggedIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => DashboardScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => SignupPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.location_on, size: 100, color: Colors.white),
              SizedBox(height: 20),
              Text(
                "Dynamic Emergency Contact System",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 18),
              Text(
                "Your safety companion while you travel",
                style: TextStyle(fontSize: 15, color: Colors.white),
              ),
              SizedBox(height: 30),
              CircularProgressIndicator(color: Colors.white), // loading spinner
            ],
          ),
        ),
      ),
    );
  }
}
