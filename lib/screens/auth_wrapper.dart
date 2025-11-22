import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ecommerce_app/screens/login_screen.dart';
import 'package:ecommerce_app/screens/home_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // 1️⃣ Loading state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // 2️⃣ User is logged in
        if (snapshot.hasData && snapshot.data != null) {
          return const HomeScreen();
        }

        // 3️⃣ User is not logged in
        return const LoginScreen();
      },
    );
  }
}
