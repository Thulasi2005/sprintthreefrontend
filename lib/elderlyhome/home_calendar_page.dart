import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CalendarPage extends StatefulWidget {
  final String username;

  CalendarPage({required this.username});

  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  late DateTime _selectedDate;
  late Map<DateTime, List<bool>> _timeSlots;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _timeSlots = {};
    _loadTimeSlots();
  }

  Future<void> _loadTimeSlots() async {
    final response = await http.get(Uri.parse(
        'http://10.3.1.240/donation_app/get_time_slots.php?username=${widget.username}&date=${_selectedDate.toIso8601String()}'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _timeSlots[_selectedDate] = List<bool>.from(data['slots']);
      });
    } else {
      setState(() {
        _timeSlots[_selectedDate] = List.filled(7, false); // Default to all false if no data
      });
    }
  }

  Future<void> _saveTimeSlots() async {
    final response = await http.post(
      Uri.parse('http://10.3.1.240/donation_app/save_time_slots.php'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: json.encode({
        'username': widget.username,
        'date': _selectedDate.toIso8601String(),
        'slots': _timeSlots[_selectedDate],
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Time slots saved successfully')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save time slots')),
      );
    }
  }

  List<Widget> _buildTimeSlotWidgets() {
    final timeSlotLabels = [
      '9 AM - 10 AM',
      '10 AM - 11 AM',
      '11 AM - 12 PM',
      '12 PM - 1 PM',
      '1 PM - 2 PM',
      '2 PM - 3 PM',
      '3 PM - 4 PM',
    ];

    return List.generate(7, (index) {
      return CheckboxListTile(
        title: Text(timeSlotLabels[index]),
        value: _timeSlots[_selectedDate]?[index] ?? false,
        onChanged: (bool? value) {
          setState(() {
            if (_timeSlots[_selectedDate] == null) {
              _timeSlots[_selectedDate] = List.filled(7, false);
            }
            _timeSlots[_selectedDate]?[index] = value ?? false;
          });
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calendar - ${widget.username}'), // Display username in the AppBar
        backgroundColor: Color(0xFF21B2C5),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveTimeSlots,
          ),
        ],
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _selectedDate,
            selectedDayPredicate: (day) => isSameDay(day, _selectedDate),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDate = selectedDay;
                _loadTimeSlots(); // Load time slots for the selected date
              });
            },
          ),
          Expanded(
            child: ListView(
              children: _buildTimeSlotWidgets(),
            ),
          ),
        ],
      ),
    );
  }
}
