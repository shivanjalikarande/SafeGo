import 'package:flutter/material.dart';
import 'package:safego/screens/dashboard_screen.dart';
import './screens/signup_page.dart';
import './screens/login_page.dart';
import './screens/verify_otp_page.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Supabase Auth',
      initialRoute: '/signup',
      routes: {
        '/signup': (_) => const SignupPage(),
        '/login': (_) => const LoginPage(),
        '/verify-otp': (_) => const VerifyOtpPage(),
        '/dashboard': (_) => DashboardScreen(),
      },
    );
  }
}

// import 'package:flutter/material.dart';
// import './screens/splash_screen.dart';

// void main() {
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'Emergency Contact App',
//       theme: ThemeData(primarySwatch: Colors.blue),
//       home: SplashScreen(),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'supabase_client.dart'; // 👈 Import your Supabase client

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Supabase Flutter',
//       home: Scaffold(
//         appBar: AppBar(title: const Text('Supabase Example')),
//         body: Center(
//           child: ElevatedButton(
//             onPressed: () async {
//               final response = await supabase.from('users').select().execute();
//               print(response.data);
//             },
//             child: const Text('Fetch Data'),
//           ),
//         ),
//       ),
//     );
//   }
// }
