import 'package:flutter/material.dart';
import 'package:safego/screens/emergency_numbers.dart';
import 'package:safego/services/secure_storage_service.dart'; // For token storage
import 'package:safego/screens/signup_page.dart'; // For navigation to login page
import '../supabase_client.dart';
import 'user_profile_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  String country = 'USA';

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => EmergencyNumbersPage(country: country),
          ),
        );
        break;
      case 2:
        Navigator.pushNamed(context, '/history');
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => UserProfilePage()),
        );
        break;
    }
  }

  void _sendSOS(String type, BuildContext context) async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("User not logged in")));
        return;
      }

      final response = await http.post(
        Uri.parse(
          'http://192.168.58.129:5000/sos/trigger-sos',
        ), // Replace with your actual backend URL
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'user_id': user.id, 'type': type}),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final notified = json['notified'] ?? [];
        String msg = "SOS sent to ${type == 'All' ? 'all' : type} services";
        if (notified.isNotEmpty) {
          msg += ": ${notified.map((s) => s['name']).join(', ')}";
        }

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(msg)));
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Failed: ${response.body}")));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to send SOS: $e")));
    }
  }

  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.blue,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.phone_in_talk),
            label: 'Emergency',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
      body: Stack(
        children: [
          // White Curved Container
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: height * 0.75,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              child: Column(
                children: [
                  SizedBox(height: 80),

                  // SOS Button
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: CircleBorder(),
                      padding: EdgeInsets.all(50),
                      elevation: 6,
                    ),
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(25.0),
                          ),
                        ),
                        builder: (context) {
                          return Container(
                            padding: EdgeInsets.all(20),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "Select Emergency Type",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 20),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    _buildSOSOption(
                                      context,
                                      Icons.local_police,
                                      "Police",
                                    ),
                                    _buildSOSOption(
                                      context,
                                      Icons.local_hospital,
                                      "Ambulance",
                                    ),
                                    _buildSOSOption(
                                      context,
                                      Icons.local_fire_department,
                                      "Fire",
                                    ),
                                  ],
                                ),
                                SizedBox(height: 20),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    _sendSOS("All", context);
                                  },
                                  icon: Icon(Icons.warning_amber_rounded),
                                  label: Text("Send to All"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                    child: Text(
                      "SOS",
                      style: TextStyle(
                        fontSize: 24,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 30),

                  // Police, Ambulance, Fire Options
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildServiceItem(Icons.local_police, "Police", () {
                          print("Police button tapped");
                        }),
                        _buildServiceItem(Icons.local_hospital, "Ambulance", () {
                          print("Ambulance button tapped");
                        }),
                        _buildServiceItem(Icons.local_fire_department, "Fire", () {
                          print("Fire button tapped");
                        }),
                      ],
                    ),
                  ),
                  SizedBox(height: 30),

                  // Map Section
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(216, 245, 245, 245),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.location_on,
                          size: 40,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Top Blue Section
          Positioned(
            top: 40,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Home",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.settings, color: Colors.white),
                      onPressed: () {
                        if (supabase.auth.currentUser != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => UserProfilePage(),
                            ),
                          );
                        } else {
                          Navigator.pushNamed(context, '/login');
                        }
                      },
                    ),
                    Icon(Icons.notifications, color: Colors.white),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            top: 80,
            left: 20,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: AssetImage('assets/profile.png'),
                ),
                SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Hi, Laura",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "123 Veit St. Springfield",
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Logout Button (Top Right)
          Positioned(
            top: 80,
            right: 10,
            child: IconButton(
              icon: Icon(Icons.logout, color: Colors.white),
              onPressed: () async {
                await SecureStorageService.clear();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => SignupPage()),
                  (Route<dynamic> route) => false,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSOSOption(BuildContext context, IconData icon, String label) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        _sendSOS(label, context);
      },
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.red.shade100,
            child: Icon(icon, size: 30, color: Colors.red),
          ),
          SizedBox(height: 8),
          Text(label),
        ],
      ),
    );
  }

  Widget _buildServiceItem(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.blue, size: 30),
          ),
          SizedBox(height: 8),
          Text(label, style: TextStyle(color: Colors.black87)),
        ],
      ),
    );
  }
}
