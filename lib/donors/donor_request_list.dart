import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RequestListPage extends StatefulWidget {
  @override
  _RequestListPageState createState() => _RequestListPageState();
}

class _RequestListPageState extends State<RequestListPage> {
  List<dynamic> requests = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchRequests();
  }

  Future<void> _fetchRequests() async {
    final url = 'http://10.3.1.240/donation_app/get_requests.php'; // Update with your actual backend URL
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final fetchedRequests = json.decode(response.body);
        print(fetchedRequests); // Log the fetched data for debugging
        setState(() {
          requests = fetchedRequests;
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load requests';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'An error occurred: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('Request List'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        color: Color(0xFF21B2C5),
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : errorMessage.isNotEmpty
            ? Center(child: Text(errorMessage))
            : ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final request = requests[index];
            int totalQuantity = 0;

            // Calculate the total quantity of items in the request
            for (var item in request['items']) {
              print('Item: ${item['item']}, Quantity: ${item['quantity']}'); // Debug each item
              totalQuantity += (item['quantity'] as num).toInt(); // Convert num to int
            }

            return Column(
              children: [
                _buildRequestCard(
                  context,
                  request['name'],
                  'Location: ${request['address']}',
                  'Total Items Requested: $totalQuantity',
                  'assets/images/profile${index % 3 + 1}.png', // Placeholder image path
                  request['is_emergency'] == '1',
                  request['request_id'],
                ),
                SizedBox(height: 20),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildRequestCard(BuildContext context, String title, String location, String itemsRequested, String profileImagePath, bool isEmergency, String requestId) {
    return Card(
      color: Colors.grey,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: isEmergency ? Colors.red : Colors.black, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: AssetImage(profileImagePath), // Profile image
                  radius: 30,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Request List $requestId',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        title,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        location,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        itemsRequested,
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (isEmergency)
              Align(
                alignment: Alignment.topRight,
                child: Text(
                  'Emergency',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            SizedBox(height: 10),
            Align(
              alignment: Alignment.bottomRight,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/requestview', arguments: requestId);
                },
                child: Text('VIEW LIST', style: TextStyle(color: Colors.white, fontSize: 18)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  side: BorderSide(color: Colors.black, width: 2),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
