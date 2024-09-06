import 'package:flutter/material.dart';

class SideNavDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: AssetImage('assets/images/avatar.png'), // replace with your image asset
                ),
                SizedBox(height: 10),
                Text(
                  'Hello, Sasha!',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ],
            ),
            decoration: BoxDecoration(
              color: Colors.teal,
            ),
          ),
          ListTile(
            leading: Icon(Icons.home),
            title: Text('Home'),
            onTap: () {
              Navigator.pushNamed(context, '/home');
            },
          ),
          ListTile(
            leading: Icon(Icons.history),
            title: Text('User Activity'),
            onTap: () {
              Navigator.pushNamed(context, '/userActivity');
            },
          ),
          ListTile(
            leading: Icon(Icons.calendar_today),
            title: Text('Calendar'),
            onTap: () {
              Navigator.pushNamed(context, '/calendar');
            },
          ),
          ListTile(
            leading: Icon(Icons.message),
            title: Text('Messages'),
            onTap: () {
              Navigator.pushNamed(context, '/messages');
            },
          ),
          ListTile(
            leading: Icon(Icons.home_work),
            title: Text('Elderly Homes'),
            onTap: () {
              Navigator.pushNamed(context, '/elderlyHomes');
            },
          ),
          ListTile(
            leading: Icon(Icons.people),
            title: Text('Collaboration'),
            onTap: () {
              Navigator.pushNamed(context, '/collaboration');
            },
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Settings'),
            onTap: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text('Logout'),
            onTap: () {
              Navigator.pop(context);
              // Add logout functionality here
            },
          ),
        ],
      ),
    );
  }
}
