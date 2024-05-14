Sure, here's a README file for your reminder application in markdown format:

---

# Reminder App

Reminder App is a cross-platform application built with Flutter that reminds users of specific messages when they enter social media platforms, try calling someone, or try to talk to someone. The app also allows users to set daily reminders for the morning, noon, and evening and integrates a calendar for event scheduling, alerts, and task management. It is designed to run on Android, iOS, Web, Linux, macOS, and Windows.

## Features

- Display overlay messages on top of every app on the phone.
- Set custom messages for social media, calls, and conversations.
- Schedule daily reminders for morning, noon, and evening.
- Integrated calendar for event scheduling and task management.
- Web dashboard for managing reminders and calendar events.

## Project Structure

```sh
reminder_app_new/
├── analysis_options.yaml
├── android/
│   ├── app/
│   │   ├── build.gradle
│   │   └── src/
│   │       ├── main/
│   │       │   ├── AndroidManifest.xml
│   │       │   ├── kotlin/
│   │       │   │   └── com/
│   │       │   │       └── example/
│   │       │   │           └── reminder_app_new/
│   │       │   │               ├── MainActivity.kt
│   │       │   │               ├── OverlayService.kt
│   │       │   │               ├── MyWorker.kt
│   │       │   │               └── BootReceiver.kt
│   │       │   └── res/
│   │       │       └── layout/
│   │       │           └── overlay.xml
│   ├── build.gradle
│   ├── gradle/
│   │   └── wrapper/
│   │       ├── gradle-wrapper.jar
│   │       └── gradle-wrapper.properties
│   ├── gradle.properties
│   ├── gradlew
│   ├── gradlew.bat
│   └── settings.gradle
├── ios/
├── lib/
│   ├── main.dart
│   ├── web_dashboard.dart
│   ├── ReminderProvider.dart
│   ├── ScheduledRemindersWidget.dart
│   ├── CustomMessagesWidget.dart
│   ├── CalendarWidget.dart
│   └── overlay.xml
├── linux/
├── macos/
├── pubspec.lock
├── pubspec.yaml
├── README.md
├── test/
│   └── widget_test.dart
├── web/
├── windows/
└── assets/
```

## Getting Started

### Prerequisites

- Flutter SDK: [Install Flutter](https://flutter.dev/docs/get-started/install)
- Android Studio or Visual Studio Code with Flutter extension

### Installation

1. **Clone the repository**:

```sh
git clone https://github.com/your-username/reminder_app_new.git
cd reminder_app_new
```

2. **Install dependencies**:

```sh
flutter pub get
```

3. **Run the app**:

```sh
flutter run
```

## Usage

To start using the Reminder App, follow these steps:

1. **Run the app** on your desired platform using the `flutter run` command.
2. **Set custom messages** for social media, calls, and conversations using the app interface.
3. **Schedule daily reminders** for morning, noon, and evening using the app interface.
4. **Manage your events** and tasks using the integrated calendar.

## Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository.
2. Create a new branch (`git checkout -b feature-branch`).
3. Make your changes and commit them (`git commit -m 'Add some feature'`).
4. Push to the branch (`git push origin feature-branch`).
5. Create a new Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Thanks to the Flutter community for their amazing tools and resources.

---

This README file provides an overview of the application, its features, project structure, installation instructions, and more. Feel free to customize it further based on your project's specifics.