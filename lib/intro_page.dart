import 'package:flutter/material.dart';
import 'sign_in_page.dart';

class IntroPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF21B2C5),
      body: Center(
        child: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SignInPage()),
            );
          },
          child: Image.asset('assets/images/logo.png'), // Ensure the path is correct
        ),
      ),
    );
  }
}
