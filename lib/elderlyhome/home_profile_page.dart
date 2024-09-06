import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:commercialcomputing/base_scaffold.dart';
import 'sign_in_page.dart';
import 'package:commercialcomputing/help_page.dart';
import 'package:commercialcomputing/about_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:commercialcomputing/user_selectiom_page.dart';

class HomeUserProfilePage extends StatefulWidget {
  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<HomeUserProfilePage> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  File? _image;
  String _name = '';
  String _email = '';
  int _donated = 0;
  int _collaborated = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    fetchUserProfile(); // Fetch profile data when the page initializes
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> fetchUserProfile() async {
    final response = await http.get(Uri.parse('http://10.3.1.240/donation_app/get_donorprofile.php'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success']) {
        setState(() {
          _name = data['user']['name'];
          _email = data['user']['email'];
          _donated = data['user']['donated'];
          _collaborated = data['user']['collaborated'];
          _nameController.text = _name;
          _emailController.text = _email;
        });
      } else {
        Fluttertoast.showToast(
          msg: data['message'],
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    } else {
      Fluttertoast.showToast(
        msg: 'Network error',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  void _logout() {
    Fluttertoast.showToast(
      msg: "User logged out successfully",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.green,
      textColor: Colors.white,
    );
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginSelectionPage()),
    );
  }

  void _showMyAccount() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('My Account'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name: $_name'),
            Text('Email: $_email'),
            Text('No. Donated: $_donated'),
            Text('Collaborated: $_collaborated'),
          ],
        ),
        actions: [
          TextButton(
            child: Text('OK'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      title: 'User Profile',
      body: Container(
        color: Color(0xFF21B2C5),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Stack(
              alignment: Alignment.center,
              children: [
                ScaleTransition(
                  scale: _animation,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: _image == null
                        ? AssetImage('assets/images/avatar.png') // replace with your image asset
                        : FileImage(_image!) as ImageProvider,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: IconButton(
                    icon: Icon(Icons.edit, color: Colors.white),
                    onPressed: _pickImage,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            TextField(
              controller: _nameController,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Enter your name',
                hintStyle: TextStyle(color: Colors.white54),
              ),
            ),
            Text(
              _email,
              style: TextStyle(fontSize: 16, color: Colors.grey[200]),
            ),
            SizedBox(height: 20),
            Card(
              child: ListTile(
                title: Text('No. Donated:'),
                trailing: Text(
                  '$_donated',
                  style: TextStyle(fontSize: 18, color: Colors.red),
                ),
              ),
            ),
            Card(
              child: ListTile(
                title: Text('Collaborated:'),
                trailing: Text(
                  '$_collaborated',
                  style: TextStyle(fontSize: 18, color: Colors.red),
                ),
              ),
            ),
            SizedBox(height: 20),
            ListTile(
              leading: Icon(Icons.account_circle, color: Colors.white),
              title: Text('My Account', style: TextStyle(color: Colors.white)),
              trailing: Icon(Icons.warning, color: Colors.red),
              onTap: _showMyAccount,
            ),
            ListTile(
              leading: Icon(Icons.logout, color: Colors.white),
              title: Text('Log out', style: TextStyle(color: Colors.white)),
              onTap: _logout,
            ),
            ListTile(
              leading: Icon(Icons.help, color: Colors.white),
              title: Text('Help & Support', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HelpPage()), // Navigate to HelpPage
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.info, color: Colors.white),
              title: Text('About App', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AboutPage()), // Navigate to AboutPage
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
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
        currentIndex: 3, // Profile is selected
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white60,
        backgroundColor: Colors.black,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushNamed(context, '/elderlyHomeHomePage');
              break;
            case 1:
              Navigator.pushNamed(context, '/homemanagement');
              break;
            case 2:
              Navigator.pushNamed(context, '/notifications');
              break;
            case 3:
              Navigator.pushNamed(context, '/homeprofile');
              break;
          }
        },
      ),
    );
  }
}
