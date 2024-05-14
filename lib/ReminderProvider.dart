import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'dart:convert';

class ReminderProvider extends ChangeNotifier {
  String _socialMediaMessage = '';
  String _callMessage = '';
  String _talkMessage = '';
  Map<DateTime, List<String>> _events = {};
  FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

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
}
