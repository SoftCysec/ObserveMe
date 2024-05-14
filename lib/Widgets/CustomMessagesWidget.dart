import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reminder_app_new/main.dart'; // Adjust the import according to your project structure

class CustomMessagesWidget extends StatefulWidget {
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
          SizedBox(height: 8.0),
          TextField(
            controller: _callMessageController,
            decoration: InputDecoration(
              labelText: 'Enter message for calls',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 8.0),
          TextField(
            controller: _talkMessageController,
            decoration: InputDecoration(
              labelText: 'Enter message for talking to someone',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 16.0),
          ElevatedButton(
            onPressed: () {
              Provider.of<ReminderProvider>(context, listen: false).setCustomMessages(
                _socialMediaMessageController.text,
                _callMessageController.text,
                _talkMessageController.text,
              );
            },
            child: Text('Set Messages'),
          ),
        ],
      ),
    );
  }
}