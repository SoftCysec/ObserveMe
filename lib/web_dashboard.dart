import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reminder_app_new/main.dart';
import 'package:reminder_app_new/ReminderProvider.dart' as rp1;

class WebDashboard extends StatefulWidget {
  @override
  _WebDashboardState createState() => _WebDashboardState();
}

class _WebDashboardState extends State<WebDashboard> {
  int _selectedIndex = 0;

  static final List<Widget> _widgetOptions = <Widget>[
    EventsPage(),
    RemindersPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Web Dashboard'),
      ),
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.event),
            label: 'Events',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Reminders',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

class EventsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final reminderProvider = Provider.of<rp1.ReminderProvider>(context);
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Text('Events', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          ...reminderProvider.events.entries.map((entry) {
            final date = entry.key;
            final events = entry.value;
            return ExpansionTile(
              title: Text('${date.year}-${date.month}-${date.day}'),
              children: events.map((event) {
                return ListTile(
                  title: Text(event),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      reminderProvider.deleteEvent(date, event);
                    },
                  ),
                );
              }).toList(),
            );
          }).toList(),
        ],
      ),
    );
  }
}

class RemindersPage extends StatelessWidget {
  final TextEditingController _morningTimeController = TextEditingController();
  final TextEditingController _noonTimeController = TextEditingController();
  final TextEditingController _eveningTimeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final reminderProvider = Provider.of<rp1.ReminderProvider>(context);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Text('Reminders', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          TextField(
            controller: _morningTimeController,
            decoration: InputDecoration(
              labelText: 'Enter morning time (HH:mm)',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 8.0),
          TextField(
            controller: _noonTimeController,
            decoration: InputDecoration(
              labelText: 'Enter noon time (HH:mm)',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 8.0),
          TextField(
            controller: _eveningTimeController,
            decoration: InputDecoration(
              labelText: 'Enter evening time (HH:mm)',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 16.0),
          ElevatedButton(
            onPressed: () {
              reminderProvider.scheduleDailyReminders(
                _morningTimeController.text,
                _noonTimeController.text,
                _eveningTimeController.text,
              );
            },
            child: Text('Schedule Daily Reminders'),
          ),
        ],
      ),
    );
  }
}
