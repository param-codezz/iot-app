import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:my_home_app/logic/connections/connections.dart';
import 'package:provider/provider.dart';

class DataTab extends StatelessWidget {
  const DataTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Data(),
    );
  }
}

class Data extends StatefulWidget {
  const Data({super.key});

  @override
  State<Data> createState() => _DataState();
}

class _DataState extends State<Data> {
  String data = '';
  late WebSocketClient webSocketClient;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    webSocketClient = Provider.of<WebSocketClient>(context, listen: false);
    webSocketClient.lastReceivedMessage.addListener(() async {
      if (webSocketClient.lastReceivedMessage.value != null) {
        final jsonData = jsonDecode(webSocketClient.lastReceivedMessage.value!);
        if (jsonData['event'] == 'sensor_data') {
          setState(() {
            data = jsonData['sensor_data'].toString();
          });
        }
      }
    });
  }
  @override
  void dispose() {
    webSocketClient.lastReceivedMessage
        .removeListener(() {}); // Remove the listener
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(data, style: TextStyle(color: Theme.of(context).colorScheme.onSurface),);
    // return Text('test', style: TextStyle(color: Theme.of(context).colorScheme.onSurface),);
  }
}
