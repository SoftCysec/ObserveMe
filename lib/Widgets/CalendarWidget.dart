import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:provider/provider.dart';
import 'package:reminder_app_new/main.dart'; // Adjust the import according to your project structure

class CalendarWidget extends StatefulWidget {
  @override
  _CalendarWidgetState createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget> {
  late Map<DateTime, List<String>> _events;
  List<String> _selectedEvents = [];
  DateTime _selectedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    _events = {};
  }

  void _onDaySelected(DateTime day, DateTime focusedDay) {
    setState(() {
      _selectedDay = day;
      _selectedEvents = _events[day] ?? [];
    });
  }

  void _addEvent(String event) {
    setState(() {
      if (_events[_selectedDay] != null) {
        _events[_selectedDay]!.add(event);
      } else {
        _events[_selectedDay] = [event];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TableCalendar(
          firstDay: DateTime.utc(2020, 10, 16),
          lastDay: DateTime.utc(2030, 3, 14),
          focusedDay: _selectedDay,
          calendarFormat: CalendarFormat.month,
          onDaySelected: _onDaySelected,
          selectedDayPredicate: (day) {
            return isSameDay(_selectedDay, day);
          },
          eventLoader: (day) {
            return _events[day] ?? [];
          },
        ),
        const SizedBox(height: 8.0),
        ..._selectedEvents.map((event) => ListTile(title: Text(event))),
        TextField(
          decoration: InputDecoration(labelText: 'Add Event'),
          onSubmitted: (value) {
            _addEvent(value);
            Provider.of<ReminderProvider>(context, listen: false).setCalendarEvents(_events);
          },
        ),
      ],
    );
  }
}
