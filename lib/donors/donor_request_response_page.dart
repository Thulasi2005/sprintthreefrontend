import 'package:flutter/material.dart';

class DonorRequestResponsePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final String? donorName = ModalRoute.of(context)?.settings.arguments as String?;

    return Scaffold(
      appBar: AppBar(
        title: Text('Choose Donation Type'),
        backgroundColor: Color(0xFF21B2C5),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (donorName != null)
              Text(
                'Hello, $donorName!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            SizedBox(height: 20),
            _buildDonationButton(
              context,
              title: 'Item Donation',
              subtitle: 'Donate items like clothes, food, etc.',
              onPressed: () {
                // Navigate to RequestListPage with donorName
                Navigator.pushNamed(context, '/donoritemrequestresponse', arguments: donorName);

              },
            ),
            SizedBox(height: 20),
            _buildDonationButton(
              context,
              title: 'Service Donation',
              subtitle: 'Donate services such as medical, maintenance, etc.',
              onPressed: () {
                _showServiceDonationOptions(context);
              },
            ),
            SizedBox(height: 20),
            _buildDonationButton(
              context,
              title: 'Money Donation',
              subtitle: 'Donate money to support various needs.',
              onPressed: () {
                Navigator.pushNamed(context, '/donormoney', arguments: donorName);
              },
            ),
            SizedBox(height: 20),
            _buildDonationButton(
              context,
              title: 'Calendar',
              subtitle: 'Visit and spend time with elders.',
              onPressed: () {
                Navigator.pushNamed(context, '/donorcalendarresponse', arguments: donorName);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDonationButton(BuildContext context, {
    required String title,
    required String subtitle,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFF21B2C5),
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 40),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 10),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  void _showServiceDonationOptions(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Service Donation Options'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text('Medical'),
                onTap: () {
                  Navigator.pop(context);
                  // Handle Medical service donation
                },
              ),
              ListTile(
                title: Text('Maintenance'),
                onTap: () {
                  Navigator.pop(context);
                  // Handle Maintenance service donation
                },
              ),
              ListTile(
                title: Text('Education'),
                onTap: () {
                  Navigator.pop(context);
                  // Handle Education service donation
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
