import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:law_app/Home/home_page.dart';
import 'package:law_app/auth/email_verification_page.dart';
import 'package:law_app/auth/login_page.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            // User is logged in
            User? user = snapshot.data;
            if (user != null && !user.emailVerified) {
              // Email is not verified, redirect to verification screen
              return const EmailVerificationPage(); // Make sure to create this widget
            } else {
              // Email is verified, go to home page
              return const HomePage();
            }
          }

          // user is NOT logged in
          else {
            return const LoginPage();
          }
        },
      ),
    );
  }
}
