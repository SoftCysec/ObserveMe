import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:workmanager/workmanager.dart';
import 'web_dashboard.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Workmanager().initialize(callbackDispatcher, isInDebugMode: true);
  Workmanager().registerPeriodicTask(
    "1",
    "simplePeriodicTask",
    frequency: Duration(minutes: 15),
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ReminderProvider()),
      ],
      child: OverlaySupport.global(child: MyApp()),
    ),
  );

  if (Platform.isAndroid) {
    requestOverlayPermission();
  }
}

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) {
    final reminderProvider = ReminderProvider();
    reminderProvider.triggerReminder();
    return Future.value(true);
  });
}

void requestOverlayPermission() async {
  const platform = MethodChannel('com.example.reminder_app_new/overlay');
  try {
    await platform.invokeMethod('requestOverlayPermission');
  } on PlatformException catch (e) {
    // Use a logging framework
    debugPrint("Failed to request overlay permission: '${e.message}'.");
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reminder App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => HomeScreen(),
        '/dashboard': (context) => WebDashboard(),
      },
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    Provider.of<ReminderProvider>(context, listen: false).initializeNotifications();
    Provider.of<ReminderProvider>(context, listen: false).loadCalendarEvents();
    startOverlay();
  }

  static const platform = MethodChannel('com.example.reminder_app_new/overlay');

  Future<void> startOverlay() async {
    try {
      await platform.invokeMethod('startOverlay');
    } on PlatformException catch (e) {
      // Use a logging framework
      debugPrint("Failed to start overlay: '${e.message}'.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reminder App'),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 600) {
            return Row(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        CalendarWidget(),
                        CustomMessagesWidget(),
                        ScheduledRemindersWidget(),
                      ],
                    ),
                  ),
                ),
                VerticalDivider(),
                Expanded(
                  child: ReminderListWidget(),
                ),
              ],
            );
          } else {
            return SingleChildScrollView(
              child: Column(
                children: [
                  CalendarWidget(),
                  CustomMessagesWidget(),
                  ScheduledRemindersWidget(),
                  ReminderListWidget(),
                ],
              ),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/dashboard');
        },
        child: const Icon(Icons.dashboard),
      ),
    );
  }
}

class CalendarWidget extends StatefulWidget {
  const CalendarWidget({Key? key}) : super(key: key);

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
    Provider.of<ReminderProvider>(context, listen: false).setCalendarEvents(_events);
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
          },
        ),
      ],
    );
  }
}

class CustomMessagesWidget extends StatefulWidget {
  const CustomMessagesWidget({Key? key}) : super(key: key);

  @override
  _CustomMessagesWidgetState createState() => _CustomMessagesWidgetState();
}

class _CustomMessagesWidgetState extends State<CustomMessagesWidget> {
  final TextEditingController _socialMediaMessageController = TextEditingController();
  final TextEditingController _callMessageController = TextEditingController();
  final TextEditingController _talkMessageController = TextEditingController();

  @override
  void dispose() {
    _socialMediaMessageController.dispose();
    _callMessageController.dispose();
    _talkMessageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: _socialMediaMessageController,
            decoration: InputDecoration(
              labelText: 'Enter message for social media',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8.0),
          TextField(
            controller: _callMessageController,
            decoration: InputDecoration(
              labelText: 'Enter message for calls',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8.0),
          TextField(
            controller: _talkMessageController,
            decoration: InputDecoration(
              labelText: 'Enter message for talking to someone',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16.0),
          ElevatedButton(
            onPressed: () {
              Provider.of<ReminderProvider>(context, listen: false).setCustomMessages(
                _socialMediaMessageController.text,
                _callMessageController.text,
                _talkMessageController.text,
              );
            },
            child: const Text('Set Messages'),
          ),
        ],
      ),
    );
  }
}

class ScheduledRemindersWidget extends StatefulWidget {
  const ScheduledRemindersWidget({Key? key}) : super(key: key);

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
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: _morningTimeController,
            decoration: InputDecoration(
              labelText: 'Enter morning time (HH:mm)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8.0),
          TextField(
            controller: _noonTimeController,
            decoration: InputDecoration(
              labelText: 'Enter noon time (HH:mm)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8.0),
          TextField(
            controller: _eveningTimeController,
            decoration: InputDecoration(
              labelText: 'Enter evening time (HH:mm)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16.0),
          ElevatedButton(
            onPressed: () {
              Provider.of<ReminderProvider>(context, listen: false).scheduleDailyReminders(
                _morningTimeController.text,
                _noonTimeController.text,
                _eveningTimeController.text,
              );
            },
            child: const Text('Schedule Daily Reminders'),
          ),
        ],
      ),
    );
  }
}

class ReminderListWidget extends StatelessWidget {
  const ReminderListWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final reminderProvider = Provider.of<ReminderProvider>(context);
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const SizedBox(height: 8.0),
          Text('Reminders', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ...reminderProvider.events.entries.map((entry) {
            final date = entry.key;
            final events = entry.value;
            return ExpansionTile(
              title: Text('${date.year}-${date.month}-${date.day}'),
              children: events.map((event) {
                return ListTile(
                  title: Text(event),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
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

class ReminderProvider extends ChangeNotifier {
  String _socialMediaMessage = '';
  String _callMessage = '';
  String _talkMessage = '';
  Map<DateTime, List<String>> _events = {};
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  String get socialMediaMessage => _socialMediaMessage;
  String get callMessage => _callMessage;
  String get talkMessage => _talkMessage;
  Map<DateTime, List<String>> get events => _events;

  void setCustomMessages(String socialMediaMessage, String callMessage, String talkMessage) async {
    _socialMediaMessage = socialMediaMessage;
    _callMessage = callMessage;
    _talkMessage = talkMessage;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('socialMediaMessage', socialMediaMessage);
    await prefs.setString('callMessage', callMessage);
    await prefs.setString('talkMessage', talkMessage);
    notifyListeners();
  }

  void setCalendarEvents(Map<DateTime, List<String>> events) async {
    _events = events;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('calendarEvents', jsonEncode(encodeMap(events)));
    notifyListeners();
  }

  void deleteEvent(DateTime date, String event) async {
    if (_events[date] != null) {
      _events[date]!.remove(event);
      if (_events[date]!.isEmpty) {
        _events.remove(date);
      }
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('calendarEvents', jsonEncode(encodeMap(_events)));
      notifyListeners();
    }
  }

  Future<void> loadCalendarEvents() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? events = prefs.getString('calendarEvents');
    if (events != null) {
      _events = decodeMap(jsonDecode(events));
    }
    notifyListeners();
  }

  Map<String, dynamic> encodeMap(Map<DateTime, List<String>> map) {
    Map<String, dynamic> newMap = {};
    map.forEach((key, value) {
      newMap[key.toString()] = value;
    });
    return newMap;
  }

  Map<DateTime, List<String>> decodeMap(Map<String, dynamic> map) {
    Map<DateTime, List<String>> newMap = {};
    map.forEach((key, value) {
      newMap[DateTime.parse(key)] = List<String>.from(value);
    });
    return newMap;
  }

  Future<void> initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    final InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid);
    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> scheduleDailyReminders(String morningTime, String noonTime, String eveningTime) async {
    await scheduleReminder(morningTime, 'Morning Reminder');
    await scheduleReminder(noonTime, 'Noon Reminder');
    await scheduleReminder(eveningTime, 'Evening Reminder');
  }

  Future<void> scheduleReminder(String time, String message) async {
    final timeParts = time.split(':');
    final hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);

    final AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'your channel id',
      'your channel name',
      'your channel description',
      importance: Importance.max,
      priority: Priority.high,
      sound: RawResourceAndroidNotificationSound('custom_sound'),
      vibrationPattern: Int64List.fromList([0, 1000, 500, 1000]),
      playSound: true,
    );
    final NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      'Reminder',
      message,
      _nextInstanceOfTime(hour, minute),
      platformChannelSpecifics,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  // Method to trigger reminders
  void triggerReminder() {
    // Implement your reminder trigger logic here
  }
}
