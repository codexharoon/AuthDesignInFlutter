import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:law_app/Home/home_page.dart';

Future<void> signInWithGoogle(BuildContext context) async {
  try {
    final GoogleSignIn googleSignIn = GoogleSignIn();
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

    if (googleUser != null) {
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // await FirebaseAuth.instance.signInWithCredential(credential);

      // Sign in the user with the credential
      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      // Access the user information
      final User? user = userCredential.user;

      if (user != null) {
        // Store user information in Firestore
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'name': user.displayName,
          'email': user.email,
          'phone': user.phoneNumber.toString(),
        });

        // Success Snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sign in successful')),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(),
          ),
        );
      }
    } else {
      // User cancelled the login
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sign in cancelled by user')),
      );
    }
  } catch (e) {
    // Error handling
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error signing in: $e')),
    );
  }
}
