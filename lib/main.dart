import 'package:flutter/material.dart';
import 'package:workmanager/workmanager.dart';
import 'dart:io';
const simpleTaskKey = "sampleBackgroundTask";

void main() {
  Workmanager().initialize(
		callbackDispatcher,
		isInDebugMode: true,
	);
  runApp(const MainApp());
}

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    print(taskName);
    switch (taskName) {
      case Workmanager.iOSBackgroundTask:
        stderr.writeln("The iOS background fetch was triggered");
        break;
    }
    bool success = true;
    return Future.value(success);
  });
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('Hello World!'),
        ),
      ),
    );
  }
}
