import 'package:flutter/material.dart';
import 'package:my_home_app/ui/pages/home.dart';
import 'package:my_home_app/ui/pages/login.dart';
import 'package:my_home_app/theme.dart';

// ignore: must_be_immutable
class MyApp extends StatelessWidget {
  const MyApp({super.key});
  final MaterialTheme materialTheme = const MaterialTheme();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'My Home',
      theme: materialTheme.light(),
      darkTheme: materialTheme.dark(),
      // home: const MyHomePage(),
      home: const LoginPage(),
    );
  }
}
