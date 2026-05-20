import 'package:battery_saver_app/view/battery_saver/battery_saver_screen.dart';
import 'package:battery_saver_app/view/battery_saver_home_screen/battery_saver_home_screen.dart';
import 'package:battery_saver_app/view/battery_saver_home_screen/result_battery_saver_screen.dart';
import 'package:battery_saver_app/view/bottom_nav/home_screen.dart';
import 'package:battery_saver_app/view/cpu_cooler/cpu_cooler.dart';
import 'package:battery_saver_app/view/junk_cleaner/junk_cleaner_screen.dart';
import 'package:battery_saver_app/view/notification_cleaner/notification_cleaner.dart';
import 'package:battery_saver_app/view/phone_boost/phone_boost_screen.dart';
import 'package:battery_saver_app/view/power_boost/power_boost_home_screen.dart';
import 'package:battery_saver_app/view/power_boost/result_power_boost_screen.dart';
import 'package:battery_saver_app/view/security_scan/security_scan_screen.dart';
import 'package:battery_saver_app/view/temperature_control/result_temperature_control_screen.dart';
import 'package:battery_saver_app/view/temperature_control/temperature_control_screen.dart';
import 'package:battery_saver_app/view/tools/tools_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        
        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const ResultTemperatureControlScreen(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          
          mainAxisAlignment: .center,
          children: [
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
