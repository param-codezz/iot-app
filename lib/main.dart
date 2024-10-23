import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'logic/connections/connections.dart';
import 'package:my_home_app/ui/app.dart';

void main() {
  runApp(
    ChangeNotifierProvider<WebSocketClient>(
      create: (_) => WebSocketClient('ws://192.168.182.156:8080'),
      child: const MyApp(),
    ),
  );
}