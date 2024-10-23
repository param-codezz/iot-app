// write code that connects to a websocket server and a method that returns the connection object, also make a static method to send data to the websocket server

import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter/foundation.dart';

class WebSocketClient with ChangeNotifier {
  WebSocketChannel? _channel;
  bool _isConnected = false;
  final String url;
  final ValueNotifier<String?> _lastMessage = ValueNotifier<String?>(null);
  final int _reconnectInterval = 5;
  ValueNotifier<String?> get lastReceivedMessage => _lastMessage;

  WebSocketClient(this.url) {
    _connect();
  }

  void _connect() {
    try {
      _channel = WebSocketChannel.connect(Uri.parse(url));
      _setConnectionStatus(true);
      _listenToConnection();
    } catch (e) {
      print("Failed to connect: $e");
      _scheduleReconnect();
    }
  }

  void _scheduleReconnect() {
    print("Attempting to reconnect in $_reconnectInterval seconds...");
    Future.delayed(Duration(seconds: _reconnectInterval), () {
      if (!_isConnected) {
        reconnect();
      }
    });
  }

  void _listenToConnection() {
    _channel!.stream.listen(
      (message) {
        // Handle incoming messages
        print("Received message: $message");
        _lastMessage.value = message;
        notifyListeners();
      },
      onDone: () {
        _setConnectionStatus(false);
        // Optionally handle reconnection logic here
      },
      onError: (error) {
        _setConnectionStatus(false);
        // Optionally handle reconnection logic here
      },
    );
    _setConnectionStatus(true);
  }

  bool isConnected() {
    return _isConnected | (_channel?.closeCode == null);
  }

  void sendData(dynamic data) {
    if (isConnected()) {
      _channel!.sink.add(jsonEncode(data));
    }
  }

  void close() {
    _setConnectionStatus(false);
    _channel?.sink.close();
  }

  void _setConnectionStatus(bool status) {
    _isConnected = status;
    notifyListeners();
  }

  void reconnect() {
    close();
    _connect();
  }
}
