import 'package:flutter/material.dart';

class SignInPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF21B2C5),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 50), // Add some spacing at the top
              Image.asset(
                'assets/images/logo.png',
                height: MediaQuery.of(context).size.height * 0.3, // Make the image size responsive
              ),
              SizedBox(height: 50), // Add spacing between the image and buttons
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/signIn'); // Navigate to donor sign-in page
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 20), // Increase button padding
                  ),
                  child: Text(
                    'Donors',
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 20, // Increase font size
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/elderlyHomeSignIn'); // Navigate to elderly home sign-in page
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 20), // Increase button padding
                  ),
                  child: Text(
                    'Homes',
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 20, // Increase font size
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/register'); // Navigate to the registration selection page
                },
                child: Text(
                  "Don't have an account? Sign Up",
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 18, // Increase font size
                    color: Colors.white, // Ensure the text is visible
                  ),
                ),
              ),
              SizedBox(height: 50), // Add some spacing at the bottom
            ],
          ),
        ),
      ),
    );
  }
}
