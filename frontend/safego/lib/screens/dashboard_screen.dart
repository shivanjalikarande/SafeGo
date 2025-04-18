import 'package:flutter/material.dart';
import 'package:safego/services/secure_storage_service.dart'; // For token storage
import 'package:safego/screens/signup_page.dart'; // For navigation to login page

class DashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.blue,
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
                      print("SOS Pressed");
                      // Add your SOS functionality here
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
                          // Navigate or handle Police tap
                        }),
                        _buildServiceItem(
                          Icons.local_hospital,
                          "Ambulance",
                          () {
                            print("Ambulance button tapped");
                            // Navigate or handle Ambulance tap
                          },
                        ),
                        _buildServiceItem(
                          Icons.local_fire_department,
                          "Fire",
                          () {
                            print("Fire button tapped");
                            // Navigate or handle Fire tap
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 30),

                  // Placeholder for map section
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

          // Top Blue Section with profile and name
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
                        Navigator.pushNamed(context, '/user-profile');
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
                  backgroundImage: AssetImage(
                    'assets/profile.png',
                  ), // Make sure this asset exists
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

          // Logout Button (Top Right Corner)
          Positioned(
            top: 80,
            right: 10,
            child: IconButton(
              icon: Icon(Icons.logout, color: Colors.white),
              onPressed: () async {
                // Clear the token from secure storage
                await SecureStorageService.clear();
                // Navigate to login page
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
