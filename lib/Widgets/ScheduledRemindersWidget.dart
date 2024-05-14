import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reminder_app_new/main.dart'; // Adjust the import according to your project structure

class ScheduledRemindersWidget extends StatefulWidget {
  @override
  _ScheduledRemindersWidgetState createState() => _ScheduledRemindersWidgetState();
}

class _ScheduledRemindersWidgetState extends State<ScheduledRemindersWidget> {
  final TextEditingController _morningTimeController = TextEditingController();
  final TextEditingController _noonTimeController = TextEditingController();
  final TextEditingController _eveningTimeController = TextEditingController();

  @override
  void dispose() {
    _morningTimeController.dispose();
    _noonTimeController.dispose();
    _eveningTimeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _morningTimeController,
          decoration: InputDecoration(
            labelText: 'Enter morning time (HH:mm)',
          ),
        ),
        TextField(
          controller: _noonTimeController,
          decoration: InputDecoration(
            labelText: 'Enter noon time (HH:mm)',
          ),
        ),
        TextField(
          controller: _eveningTimeController,
          decoration: InputDecoration(
            labelText: 'Enter evening time (HH:mm)',
          ),
        ),
        ElevatedButton(
          onPressed: () {
            Provider.of<ReminderProvider>(context, listen: false).scheduleDailyReminders(
              _morningTimeController.text,
              _noonTimeController.text,
              _eveningTimeController.text,
            );
          },
          child: Text('Schedule Daily Reminders'),
        ),
      ],
    );
  }
}
