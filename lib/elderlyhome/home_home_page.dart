import 'package:flutter/material.dart';

class ElderlyHomeHomePage extends StatefulWidget {
  final String username;

  ElderlyHomeHomePage({required this.username});

  @override
  _ElderlyHomeHomePageState createState() => _ElderlyHomeHomePageState();
}

class _ElderlyHomeHomePageState extends State<ElderlyHomeHomePage> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    switch (index) {
      case 0:
        Navigator.pushNamed(context, '/elderlyHomeHomePage', arguments: widget.username);
        break;
      case 1:
        Navigator.pushNamed(context, '/homeResponse', arguments: widget.username);
        break;
      case 2:
        Navigator.pushNamed(context, '/notifications', arguments: widget.username);
        break;
      case 3:
        Navigator.pushNamed(context, '/homeprofile', arguments: widget.username);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final username = widget.username.isNotEmpty ? widget.username : 'Guest';

    return Scaffold(
      backgroundColor: Color(0xFF21B2C5),
      body: Stack(
        children: [
          Column(
            children: [
              Container(
                height: 180,
                color: Color(0xFF21B2C5),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 60.0, 16.0, 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Hello, $username!',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Welcome Back!',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: AssetImage('assets/images/home_profile.png'),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: GridView.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    children: [
                      _buildGridItem('assets/images/home_appreciation_message.png', 'Appreciation Greetings', '/appreciationGreetings'),
                      _buildGridItem('assets/images/home_request.png', 'Request List', '/elderlyHomeRequestSelection'),
                      _buildGridItem('assets/images/home_donation.png', 'Donation', '/homemoneydonation'),
                      _buildGridItem('assets/images/home_calendar.png', 'Calendar', '/homecalendar'),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: Icon(Icons.menu, color: Colors.white),
                onPressed: () {},
              ),
              toolbarHeight: 80,
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'User Activity',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notifications',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white60,
        backgroundColor: Colors.black,
        type: BottomNavigationBarType.fixed,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildGridItem(String imagePath, String title, String route) {
    return Card(
      color: Colors.teal[100],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, route, arguments: widget.username); // Pass the username as an argument
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(imagePath, height: 80),
            SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.teal[900],
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
