// ignore_for_file: must_be_immutable

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:my_home_app/logic/connections/connections.dart';
import 'package:my_home_app/logic/data/store_data.dart';
import 'package:my_home_app/ui/components/labelled_card.dart';
import 'package:my_home_app/ui/components/padded_divider.dart';
import 'package:provider/provider.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({
    super.key,
  });

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  bool isAlive = false;
  late WebSocketClient webSocketClient;
  Timer? pingTimer;

  @override
  void initState() {
    super.initState();
    webSocketClient = Provider.of<WebSocketClient>(context, listen: false);
    webSocketClient.lastReceivedMessage.addListener(() async {
      if (webSocketClient.lastReceivedMessage.value != null) {
        final jsonData = jsonDecode(webSocketClient.lastReceivedMessage.value!);
        print(jsonData);
        if (jsonData['event'] == 'pong') {
          // Check for the pong response
          setState(() {
            isAlive = true;
          });
        } else if (jsonData['event'] == 'pong') {
          setState(() {
            isAlive = true;
          });
        }
      }
    });
    initAsync();
  }

  Future<void> initAsync() async {
    String uid = await LocalStorage.retrieveData('esp_UID') ?? "";

    // Start sending ping messages periodically
    pingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (webSocketClient.isConnected()) {
        webSocketClient.sendData({
          'user': 'x64',
          'secret': 'x64secret',
          'esp_UID': uid,
          'event': 'ping',
        });
      }
    });
  }

  @override
  void dispose() {
    pingTimer?.cancel(); // Cancel the timer when disposing
    webSocketClient.lastReceivedMessage
        .removeListener(() {}); // Remove the listener
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0),
      child: Column(
        children: <Widget>[
          const TemperatureCard(),
          const PaddedDivider(),
          const ConnectionSection(),
          const PaddedDivider(),
          SensorSection(isConnected: isAlive),
        ],
      ),
    );
  }
}

class SensorSection extends StatelessWidget {
  SensorSection({super.key, required this.isConnected});
  bool isConnected;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(
            'Sensor Status',
            style: Theme.of(context)
                .textTheme
                .headlineMedium
                ?.copyWith(color: Theme.of(context).colorScheme.onSurface),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const RecentStatus(),
              DoorSensorStatus(isConnected: isConnected),
            ],
          ),
          RoomSensors(isConnected: isConnected),
        ],
      ),
    );
  }
}

class RoomSensors extends StatefulWidget {
  RoomSensors({super.key, required this.isConnected});
  bool isConnected;
  @override
  State<RoomSensors> createState() => _RoomSensorsState();
}

class _RoomSensorsState extends State<RoomSensors> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        LabelledCard(
          label: 'PIR_A_0',
          heading: widget.isConnected ? 'Active' : 'Inactive',
          style: widget.isConnected ? 'secondary' : 'disabled',
        ),
        LabelledCard(
          label: 'PIR_A_1',
          heading: widget.isConnected ? 'Active' : 'Inactive',
          style: widget.isConnected ? 'secondary' : 'disabled',
        ),
      ],
    );
  }
}

class DoorSensorStatus extends StatefulWidget {
  DoorSensorStatus({super.key, required this.isConnected});
  bool isConnected;
  @override
  State<DoorSensorStatus> createState() => _DoorSensorStatusState();
}

class _DoorSensorStatusState extends State<DoorSensorStatus> {
  @override
  Widget build(BuildContext context) {
    return LabelledCard(
      label: 'Door',
      heading: widget.isConnected ? 'Active' : 'Inactive',
      style: widget.isConnected ? 'secondary' : 'disabled',
    );
  }
}

class RecentStatus extends StatefulWidget {
  const RecentStatus({super.key});

  @override
  State<RecentStatus> createState() => _RecentStatusState();
}

class _RecentStatusState extends State<RecentStatus> {
  String recentAlertTime = 'No Alerts'; // Default value
  late WebSocketClient webSocketClient;

  @override
  void initState() {
    super.initState();

    // Access the WebSocket client and listen to messages
    webSocketClient = Provider.of<WebSocketClient>(context, listen: false);

    loadPreviousAlert();
    // Listen to the last message received via WebSocket
    webSocketClient.lastReceivedMessage.addListener(() async {
      if (webSocketClient.lastReceivedMessage.value != null) {
        final jsonData = jsonDecode(webSocketClient.lastReceivedMessage.value!);
        if (jsonData['event'] == 'alert') {
          String timeString =
              jsonData["data"]["time"].toString().split(', ')[1];

          // Split the time part to extract hours and minutes
          String timeWithPeriod =
              "${timeString.split(':')[0]}:${timeString.split(':')[1]}";
          print(jsonData);
          print(timeWithPeriod);
          setState(() {
            recentAlertTime = timeWithPeriod;
          });
          await LocalStorage.saveData('recent_alert', recentAlertTime);
        }
      }
    });
  }

  Future<void> loadPreviousAlert() async {
    String? prevAlert = await LocalStorage.retrieveData('recent_alert');
    if (prevAlert != null) {
      setState(() {
        recentAlertTime = prevAlert;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return LabelledCard(
      label: 'Recent Alerts',
      heading: recentAlertTime, // Displays the alert time
      style: 'error',
    );
  }

  @override
  void dispose() {
    // Remove the listener when the widget is disposed
    webSocketClient.lastReceivedMessage.removeListener(() {});
    super.dispose();
  }
}

class ConnectionSection extends StatelessWidget {
  const ConnectionSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Connection Status',
          style: Theme.of(context)
              .textTheme
              .headlineMedium
              ?.copyWith(color: Theme.of(context).colorScheme.onSurface),
        ),
        const SizedBox(
          height: 8,
        ),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            ServerConnection(),
            ESP32Connection(),
          ],
        ),
        const SizedBox(
          height: 8,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            OutlinedButton.icon(
              onPressed: () {
                showModalBottomSheet(
                    context: context,
                    builder: (BuildContext context) {
                      return Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            IconButton.filled(
                              onPressed: () {},
                              icon: const Icon(Icons.chevron_left_rounded),
                              isSelected: false,
                            ),
                            Column(
                              children: [
                                Text(
                                  'Room A',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface,
                                      ),
                                ),
                                Column(
                                  children: [
                                    Container(
                                      width: 160,
                                      height: 150,
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            const BorderRadiusDirectional.only(
                                          topEnd: Radius.circular(16),
                                          topStart: Radius.circular(16),
                                        ),
                                        border: Border.all(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .outline),
                                      ),
                                      child: Center(
                                        child: Text(
                                          'PIR_A_0',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyLarge,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      width: 160,
                                      height: 150,
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            const BorderRadiusDirectional.only(
                                          bottomEnd: Radius.circular(16),
                                          bottomStart: Radius.circular(16),
                                        ),
                                        border: Border.all(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .outline),
                                        color: Theme.of(context)
                                            .colorScheme
                                            .errorContainer,
                                      ),
                                      child: Center(
                                        child: Text(
                                          'PIR_A_1',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyLarge,
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                            IconButton.filled(
                              onPressed: () {},
                              icon: const Icon(Icons.chevron_right_rounded),
                            ),
                          ],
                        ),
                      );
                    });
              },
              label: const Text('View Room'),
              icon: const Icon(Icons.visibility_rounded),
            ),
          ],
        ),
      ],
    );
  }
}

class ServerConnection extends StatefulWidget {
  const ServerConnection({super.key});

  @override
  State<ServerConnection> createState() => _ServerConnectionState();
}

class _ServerConnectionState extends State<ServerConnection> {
  bool isAlive = false;
  late WebSocketClient webSocketClient;

  @override
  void initState() {
    super.initState();

    webSocketClient = Provider.of<WebSocketClient>(context, listen: false);

    if (webSocketClient.isConnected()) {
      setState(() {
        isAlive = true;
      });
    } else {
      setState(() {
        isAlive = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return LabelledCard(
      label: 'Server',
      heading: isAlive ? 'Active' : 'Inactive',
      style: isAlive ? 'secondary' : 'disabled',
    );
  }

  @override
  void dispose() {
    webSocketClient.lastReceivedMessage.removeListener(() {});
    super.dispose();
  }
}

class ESP32Connection extends StatefulWidget {
  const ESP32Connection({super.key});

  @override
  State<ESP32Connection> createState() => _ESP32ConnectionState();
}

class _ESP32ConnectionState extends State<ESP32Connection> {
  bool isAlive = false;
  late WebSocketClient webSocketClient;
  Timer? pingTimer;

  @override
  void initState() {
    super.initState();
    webSocketClient = Provider.of<WebSocketClient>(context, listen: false);
    webSocketClient.lastReceivedMessage.addListener(() async {
      if (webSocketClient.lastReceivedMessage.value != null) {
        final jsonData = jsonDecode(webSocketClient.lastReceivedMessage.value!);
        print(jsonData);
        if (jsonData['event'] == 'pong') {
          // Check for the pong response
          setState(() {
            isAlive = true;
          });
        } else if (jsonData['event'] == 'pong') {
          setState(() {
            isAlive = true;
          });
        }
      }
    });
    initAsync();
  }

  Future<void> initAsync() async {
    String uid = await LocalStorage.retrieveData('esp_UID') ?? "";

    // Start sending ping messages periodically
    pingTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (webSocketClient.isConnected()) {
        webSocketClient.sendData({
          'user': 'x64',
          'secret': 'x64secret',
          'esp_UID': uid,
          'event': 'ping',
        });
      }
    });
  }

  @override
  void dispose() {
    pingTimer?.cancel(); // Cancel the timer when disposing
    webSocketClient.lastReceivedMessage
        .removeListener(() {}); // Remove the listener
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LabelledCard(
      label: 'ESP32',
      heading: isAlive ? 'Active' : 'Inactive',
      style: isAlive ? 'secondary' : 'disabled',
    );
  }
}

class TemperatureCard extends StatefulWidget {
  const TemperatureCard({super.key});

  @override
  State<TemperatureCard> createState() => _TemperatureCardState();
}

class _TemperatureCardState extends State<TemperatureCard> {
  String temperature = '';
  late WebSocketClient webSocketClient;

  @override
  void initState() {
    super.initState();
    webSocketClient = Provider.of<WebSocketClient>(context, listen: false);

    loadLocalTemperature();

    webSocketClient.lastReceivedMessage.addListener(() async {
      if (webSocketClient.lastReceivedMessage.value != null) {
        final jsonData = jsonDecode(webSocketClient.lastReceivedMessage.value!);
        print(jsonData);
        if (jsonData['event'] == 'sensor_data') {
          setState(() {
            temperature =
                '${jsonData['sensor_data']['temperature'].toString().substring(0, 2)} °C'; // Assuming data structure
          });
          await LocalStorage.saveData('temperature', temperature);
        }
      }
    });
  }

  Future<void> loadLocalTemperature() async {
    String? storedTemperature = await LocalStorage.retrieveData('temperature');
    if (storedTemperature != null && storedTemperature.isNotEmpty) {
      setState(() {
        temperature = storedTemperature;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          LabelledCard(
            label: "Room's Temperature",
            heading: temperature,
            style: 'tertiary',
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    webSocketClient.lastReceivedMessage
        .removeListener(() {}); // Remove the listener
    super.dispose();
  }
}

class AnimatedRoom extends StatefulWidget {
  const AnimatedRoom({super.key});

  @override
  State<AnimatedRoom> createState() => _AnimatedRoomState();
}

class _AnimatedRoomState extends State<AnimatedRoom>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _colorAnimation = ColorTween(
      begin: Colors.white.withAlpha(128),
      end: Colors.red,
    ).animate(_controller);

    // Start the animation and reverse it immediately
    _controller.forward().then((_) {
      print("Animation forward completed");
      _controller.reverse();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
      child: Column(
        children: [
          Container(
            width: MediaQuery.of(context).size.width / 1.5,
            height: MediaQuery.of(context).size.height / 3,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(128),
              border: Border.all(
                color: Colors.white.withAlpha(200),
              ),
            ),
          ),
          AnimatedBuilder(
            animation: _colorAnimation,
            builder: (context, child) => Container(
              width: MediaQuery.of(context).size.width / 1.5,
              height: MediaQuery.of(context).size.height / 3,
              decoration: BoxDecoration(
                color: _colorAnimation.value,
                border: Border.all(
                  color: Colors.white.withAlpha(200),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
