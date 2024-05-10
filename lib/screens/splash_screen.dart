import 'dart:async';
import 'package:flutter/material.dart';

import '../app.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Initialization tasks or delay here
    await Future.delayed(Duration(seconds:1));

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => MyHomePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset(
          'assets/jd.png', // Replace with the path to your logo image
          width: 200, // Adjust width as needed
          height: 200, // Adjust height as needed
          // You can add additional properties like fit, alignment, etc.
        ),

      ),
    );
  }
}
