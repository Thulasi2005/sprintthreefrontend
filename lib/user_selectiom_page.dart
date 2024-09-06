import 'package:flutter/material.dart';
import 'donors/sign_in_page.dart' as donor;
import 'elderlyhome/sign_in_page.dart';

class LoginSelectionPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF21B2C5),
      appBar: AppBar(
        title: Text('Login'),
        backgroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 50), // Add spacing at the top
              Image.asset(
                'assets/images/logo.png', // Make sure the path to your logo is correct
                height: MediaQuery.of(context).size.height * 0.2, // Make the image size responsive
              ),
              SizedBox(height: 50), // Add spacing between the logo and text
              Text(
                'Login As',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 50), // Add spacing between the text and buttons
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => donor.SignInPage()),
                    ); // Navigate to donor registration page
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 20), // Increase button padding
                    textStyle: TextStyle(fontSize: 22, fontWeight: FontWeight.bold), // Increase font size
                  ),
                  child: Text(
                    'Donor',
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 22, // Increase font size
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/elderlyHomeSignIn'); // Navigate to elderly home registration page (to be implemented)
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 20), // Increase button padding
                    textStyle: TextStyle(fontSize: 22, fontWeight: FontWeight.bold), // Increase font size
                  ),
                  child: Text(
                    'Elderly Home',
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 22, // Increase font size
                    ),
                  ),
                ),
              ),
              SizedBox(height: 50), // Add spacing at the bottom
            ],
          ),
        ),
      ),
    );
  }
}
