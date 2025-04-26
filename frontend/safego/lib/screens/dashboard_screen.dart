import 'package:flutter/material.dart';
import 'package:safego/screens/emergency_numbers.dart';
import 'package:safego/services/secure_storage_service.dart'; // For token storage
import 'package:safego/screens/signup_page.dart'; // For navigation to login page
import '../supabase_client.dart';
import 'user_profile_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/location_scheduler.dart'; // import the location scheduler!
import 'package:telephony/telephony.dart';
import '../services/location_service.dart';
import './sos_history.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool isSafeMode = false;

  final Telephony telephony = Telephony.instance;
  @override
  void initState() {
    super.initState();
    askForSmsPermission();
    LocationScheduler.startLocationUpdates();
  }

  void askForSmsPermission() async {
    bool? permissionsGranted = await telephony.requestSmsPermissions;
    if (permissionsGranted == true) {
      print("✅ SMS permissions granted");
    } else {
      print("❌ SMS permissions denied");
    }
  }

  @override
  void dispose() {
    LocationScheduler.stopLocationUpdates();
    super.dispose();
  }

  Future<Map<String, dynamic>> _getLocation() async {
    try {
      final position = await LocationService.getCurrentLocation();
      return {"lat": position.latitude, "lng": position.longitude};
    } catch (e) {
      print("⚠️ Error getting location: $e");
      return {"lat": 0.0, "lng": 0.0};
    }
  }

  Future<String> _getAddress() async {
    try {
      final position = await LocationService.getCurrentLocation();
      final address = await LocationService.getAddressFromLatLng(
        position.latitude,
        position.longitude,
      );
      return address;
    } catch (e) {
      print("⚠️ Error getting address: $e");
      return "Address unavailable";
    }
  }

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
        // Navigator.pushNamed(context, '/history');
        final user = supabase.auth.currentUser;
        if (user != null) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => SOSHistoryPage(userId: user.id)),
          );
        } else {
          // Handle not logged-in case (optional)
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("User not logged in")));
        }
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => UserProfilePage()),
        );
        break;
    }
  }

  void _showSeverityDialog(BuildContext context) {
    String selectedSeverity = "High";
    bool informEmbassy = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (
            BuildContext context,
            void Function(void Function()) setState,
          ) {
            return AlertDialog(
              title: Text("Emergency Alert"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Select Severity:"),
                  DropdownButton<String>(
                    value: selectedSeverity,
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          selectedSeverity = newValue;
                        });
                      }
                    },
                    items:
                        ['High', 'Moderate', 'Low']
                            .map(
                              (level) => DropdownMenuItem(
                                value: level,
                                child: Text(level),
                              ),
                            )
                            .toList(),
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Checkbox(
                        value: informEmbassy,
                        onChanged: (bool? value) {
                          setState(() {
                            informEmbassy = value ?? false;
                          });
                        },
                      ),
                      Text("Inform Embassy?"),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  child: Text("Yes"),
                  onPressed: () {
                    Navigator.pop(context); // Close dialog
                    _triggerEmergency(selectedSeverity, informEmbassy);
                  },
                ),
                TextButton(
                  child: Text("Cancel"),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _triggerEmergency(String severity, bool informEmbassy) async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("User not logged in")));
      return;
    }

    final contactsResponse = await http.get(
      Uri.parse('http://192.168.58.129:5000/contacts/${user.id}'),
    );

    if (contactsResponse.statusCode == 200) {
      final contacts = jsonDecode(contactsResponse.body);
      final location = await _getLocation();
      final address = await _getAddress();

      final userData =
          await supabase
              .from('users')
              .select('name')
              .eq('id', user.id)
              .single();

      final userName = userData['name'] ?? 'Someone';

      for (var contact in contacts) {
        final phone = contact['phone'];
        // final name = contact['name'];

        final message =
            "Emergency Alert for $userName!\n"
            "Severity: $severity\n"
            "Condition: User is in distress.\n"
            "Live location: $location\n"
            "${informEmbassy ? 'Embassy has been informed.' : ''}";

        _sendSMSOffline(phone, message); // Step 3
      }
      await http.post(
        Uri.parse('http://192.168.58.129:5000/sos'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': user.id,
          'status': 'Unsafe',
          'location': location,
          'severity': severity,
          'reason': 'SOS Emergency Alert',
          'address': address,
        }),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Messages sent to all saved contacts ✅"),
          duration: Duration(seconds: 5),
        ),
      );

      setState(() {
        isSafeMode = true;
      });
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to fetch contacts.")));
    }
  }

  void _sendSMSOffline(String phone, String message) async {
    final Telephony telephony = Telephony.instance;

    bool? permissionsGranted = await telephony.requestPhonePermissions;
    if (permissionsGranted == true) {
      await telephony.sendSms(to: phone, message: message);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("SMS permission not granted")));
    }
  }

  void _showSafeConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text("Confirm Safety"),
            content: Text("Are you sure you're now safe?"),
            actions: [
              TextButton(
                child: Text("No"),
                onPressed: () => Navigator.pop(context),
              ),
              TextButton(
                child: Text("Yes"),
                onPressed: () {
                  Navigator.pop(context);
                  _handleSafeConfirmation();
                },
              ),
            ],
          ),
    );
  }

  void _handleSafeConfirmation() async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("User not logged in")));
      return;
    }

    final contactsResponse = await http.get(
      Uri.parse('http://192.168.58.129:5000/contacts/${user.id}'),
    );

    if (contactsResponse.statusCode == 200) {
      final contacts = jsonDecode(contactsResponse.body);
      final location = await _getLocation();
      final address = await _getAddress();

      final userData =
          await supabase
              .from('users')
              .select('name')
              .eq('id', user.id)
              .single();

      final userName = userData['name'] ?? 'Someone';

      for (var contact in contacts) {
        final phone = contact['phone'];
        final message =
            "$userName is now safe.\n"
            "Current location: $location";

        _sendSMSOffline(phone, message);
      }

      await http.post(
        Uri.parse('http://192.168.58.129:5000/sos'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': user.id,
          'status': 'safe',
          'location': location,
          'reason': 'Marked as Safe',
          'address': address,
        }),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Safe confirmation sent to contacts ✅")),
      );

      setState(() {
        isSafeMode = false; // Back to SOS mode
      });
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to fetch contacts.")));
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
                  isSafeMode
                      ? ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 20,
                          ),
                        ),
                        onPressed: () => _showSafeConfirmation(context),
                        child: Text(
                          "Now Safe",
                          style: TextStyle(fontSize: 20, color: Colors.white),
                        ),
                      )
                      : ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          shape: CircleBorder(),
                          padding: EdgeInsets.all(50),
                          elevation: 6,
                        ),
                        onPressed: () {
                          _showSeverityDialog(context);
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

  // Widget _buildServiceItem(IconData icon, String label, VoidCallback onTap) {
  //   return GestureDetector(
  //     onTap: onTap,
  //     child: Column(
  //       children: [
  //         Container(
  //           padding: EdgeInsets.all(14),
  //           decoration: BoxDecoration(
  //             color: Colors.blue.shade50,
  //             shape: BoxShape.circle,
  //           ),
  //           child: Icon(icon, color: Colors.blue, size: 30),
  //         ),
  //         SizedBox(height: 8),
  //         Text(label, style: TextStyle(color: Colors.black87)),
  //       ],
  //     ),
  //   );
  // }
}
