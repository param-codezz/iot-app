// ignore_for_file: must_be_immutable

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:my_home_app/logic/connections/connections.dart';
import 'package:my_home_app/logic/data/store_data.dart';
import 'package:my_home_app/ui/components/authenticate_dialog.dart';
import 'package:my_home_app/ui/components/padded_divider.dart';
import 'package:my_home_app/ui/components/snackbar_custom.dart';
import 'package:provider/provider.dart';

class ControlTab extends StatefulWidget {
  const ControlTab({super.key});

  @override
  State<ControlTab> createState() => _ControlTabState();
}

class _ControlTabState extends State<ControlTab> {
  Future<void> _refreshConnection() async {
    final client = Provider.of<WebSocketClient>(context, listen: false);

    if (client.isConnected()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Already connected'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      client.reconnect();
      if (client.isConnected()) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reconnected Successfully'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _closeConnection() async {
    final client = Provider.of<WebSocketClient>(context, listen: false);
    if (!client.isConnected()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Already disconnected'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      client.close();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Disconnected Successfully'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
  

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.symmetric(vertical: 24, horizontal: 18.0),
          child: MasterSecurityToggleCard(),
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 18.0),
          child: ConnectionStatusCard(),
        ),
        // Padding(
        //   padding: EdgeInsets.symmetric(horizontal: 18.0),
        //   child: PaddedDivider(),
        // ),
        // Padding(
        //   padding: EdgeInsets.symmetric(horizontal: 18.0),
        //   child: ControlSection(),
        // ),
      ],
    );
  }
}

class MasterSecurityToggleCard extends StatefulWidget {
  const MasterSecurityToggleCard({super.key});

  @override
  State<MasterSecurityToggleCard> createState() =>
      _MasterSecurityToggleCardState();
}

class _MasterSecurityToggleCardState extends State<MasterSecurityToggleCard> {
  bool isSwitchOn = false;
  late AuthenticateDialog authenticateDialog;
  @override
  void initState() {
    super.initState();
    authenticateDialog = const AuthenticateDialog();
    loadMasterKey();
  }

  void toggleSwitch() async {
    bool authenticated = await showDialog(
          context: context,
          builder: (BuildContext context) {
            return const AuthenticateDialog();
          },
        ) ??
        false; // Defaults to false if dialog returns null

    // If authenticated, toggle the switch state
    if (authenticated && isSwitchOn) {
      LocalStorage.saveData('masterkey', 'false');
      setState(() {
        isSwitchOn = false; // Toggle the switch state
      });
    } else if (authenticated && !isSwitchOn) {
      LocalStorage.saveData('masterkey', 'true');
      setState(() {
        isSwitchOn = true; // Toggle the switch state
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> loadMasterKey() async {
    String masterkeyState =
        await LocalStorage.retrieveData('masterkey') ?? "false";
    bool key = bool.parse(masterkeyState);
    setState(() {
      isSwitchOn = key; // Load the saved state of the switch
    });
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: toggleSwitch,
      radius: 1000,
      borderRadius: BorderRadius.circular(16),
      splashColor: Theme.of(context).colorScheme.primaryContainer,
      focusColor: Theme.of(context).colorScheme.primaryContainer,
      highlightColor: Theme.of(context).colorScheme.primaryContainer,
      hoverColor: Theme.of(context).colorScheme.primaryContainer,
      splashFactory: InkRipple.splashFactory,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: Theme.of(context).colorScheme.primaryContainer,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                'Home Security',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
              ),
              Switch(
                value: isSwitchOn,
                onChanged: (value) {
                  toggleSwitch();
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}

class ConnectionStatusCard extends StatefulWidget {
  const ConnectionStatusCard({super.key});

  @override
  State<ConnectionStatusCard> createState() => _ConnectionStatusCardState();
}

class _ConnectionStatusCardState extends State<ConnectionStatusCard> {
  bool isConnected = false;
  late WebSocketClient webSocketClient;
  @override
  void initState() {
    super.initState();
    webSocketClient = Provider.of<WebSocketClient>(context, listen: false);
    webSocketClient.lastReceivedMessage.addListener(() async {
      if (webSocketClient.lastReceivedMessage.value != null) {
        final jsonData = jsonDecode(webSocketClient.lastReceivedMessage.value!);
        jsonData['event'] == 'hidden_pong'
            ? SnackbarHelper.showSnackbar(context, 'success', 'Pong from ESP32')
            : '';
      }
    });
    if (webSocketClient.isConnected()) {
      setState(() {
        isConnected = true;
      });
    }
  }

  void _reconnect() {
    if (!webSocketClient.isConnected()) {
      webSocketClient.reconnect();
      _reconnect();
    } else if (webSocketClient.isConnected()) {
      SnackbarHelper.showSnackbar(
          context, 'success', 'Connected successfully!');
      setState(() {
        isConnected = true;
      });
    }
  }

  void _ping() {
    Navigator.pop(context);
    webSocketClient.isConnected()
        ? SnackbarHelper.showSnackbar(context, 'success', 'Pong')
        : SnackbarHelper.showSnackbar(context, 'error', 'Failed to connect');
  }

  Future<void> _pingESP() async {
    String uid = await LocalStorage.retrieveData('esp_UID') ?? "";
    if (webSocketClient.isConnected()) {
      webSocketClient.sendData({
        'user': 'x64',
        'secret': 'x64secret',
        'esp_UID': uid,
        'event': 'hidden_ping',
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: MediaQuery.of(context).size.width * 0.68,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          decoration: BoxDecoration(
            color: isConnected
                ? Theme.of(context).colorScheme.secondaryContainer
                : Theme.of(context).colorScheme.errorContainer,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        isConnected ? Icons.done_rounded : Icons.error_rounded,
                        size: 30,
                        color: isConnected
                            ? Theme.of(context).colorScheme.onSecondaryContainer
                            : Theme.of(context).colorScheme.onErrorContainer,
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      Text(
                        isConnected ? 'Active' : 'Inactive',
                        style:
                            Theme.of(context).textTheme.headlineLarge?.copyWith(
                                  color: isConnected
                                      ? Theme.of(context)
                                          .colorScheme
                                          .onSecondaryContainer
                                      : Theme.of(context)
                                          .colorScheme
                                          .onErrorContainer,
                                ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  Text(
                    'Connection Status',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: isConnected
                              ? Theme.of(context)
                                  .colorScheme
                                  .onSecondaryContainer
                              : Theme.of(context).colorScheme.onErrorContainer,
                        ),
                  ),
                ],
              ),
              PopupMenuButton(
                itemBuilder: (context) => <PopupMenuEntry<int>>[
                  PopupMenuItem(
                    onTap: _reconnect,
                    child: const ListTile(
                      leading: Icon(Icons.refresh_rounded),
                      title: Text('Reconnect'),
                    ),
                  ),
                  PopupMenuItem(
                    child: PopupMenuButton(
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          onTap: _ping,
                          child: const ListTile(
                            leading: Icon(Icons.dns_rounded),
                            title: Text('Server'),
                          ),
                        ),
                        PopupMenuItem(
                          onTap: _pingESP,
                          child: const ListTile(
                            leading: Icon(Icons.memory_rounded),
                            title: Text('ESP32'),
                          ),
                        ),
                      ],
                      child: const ListTile(
                        leading: Icon(Icons.network_ping_rounded),
                        title: Text('Ping'),
                        trailing: Icon(Icons.arrow_right_rounded),
                      ),
                    ),
                  ),
                  const PopupMenuDivider(),
                  const PopupMenuItem(
                    child: ListTile(
                      leading: Icon(Icons.restart_alt_rounded),
                      title: Text('Restart ESP32'),
                    ),
                  ),
                ],
                icon: const Icon(Icons.more_vert_rounded),
              )
            ],
          ),
        ),
      ],
    );
  }
}

class ControlSection extends StatefulWidget {
  const ControlSection({super.key});

  @override
  State<ControlSection> createState() => _ControlSectionState();
}

class _ControlSectionState extends State<ControlSection> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      mainAxisSize: MainAxisSize.max,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
          child: Text(
            'Control Room Sensors',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
          ),
        ),
        ToggleCard(
          label: 'PIR_A_0',
          id: 'PIR_A_0',
        ),
        ToggleCard(
          label: 'PIR_A_1',
          id: 'PIR_A_1',
        ),
        ToggleCard(
          label: 'Door',
          id: 'Door',
        ),
        ToggleCard(
          label: 'Temperature',
          id: 'Temperature',
        ),
      ],
    );
  }
}

class ToggleCard extends StatefulWidget {
  ToggleCard(
      {super.key,
      required this.label,
      this.style = 'secondary',
      required this.id});
  String label, style, id;
  @override
  State<ToggleCard> createState() => _ToggleCardState();
}

class _ToggleCardState extends State<ToggleCard> {
  bool isSwitchOn = false;
  late AuthenticateDialog authenticateDialog;
  @override
  void initState() {
    super.initState();
    loadState();
    authenticateDialog = const AuthenticateDialog();
  }

  Future<void> toggleSwitch() async {
    bool authenticated = await showDialog(
          context: context,
          builder: (BuildContext context) {
            return const AuthenticateDialog();
          },
        ) ??
        false;
    if (authenticated && isSwitchOn) {
      LocalStorage.saveData(widget.id, 'false');
      setState(() {
        isSwitchOn = false; // Toggle the switch state
      });
    } else if (authenticated && !isSwitchOn) {
      LocalStorage.saveData(widget.id, 'true');
      setState(() {
        isSwitchOn = true; // Toggle the switch state
      });
    }
  }

  Future<void> loadState() async {
    String keyState = await LocalStorage.retrieveData(widget.id) ?? "false";
    bool key = bool.parse(keyState);
    setState(() {
      isSwitchOn = key; // Load the saved state of the switch
    });
  }

  @override
  Widget build(BuildContext context) {
    Color container = widget.style == 'secondary'
        ? Theme.of(context).colorScheme.secondaryContainer
        : widget.style == 'disabled'
            ? Theme.of(context).colorScheme.surfaceContainer
            : Theme.of(context).colorScheme.surfaceContainer;
    Color onContainer = widget.style == 'secondary'
        ? Theme.of(context).colorScheme.onSecondaryContainer
        : widget.style == 'disabled'
            ? Theme.of(context).colorScheme.onSurfaceVariant
            : Theme.of(context).colorScheme.onSurfaceVariant;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: InkWell(
        onTap: toggleSwitch,
        borderRadius: BorderRadius.circular(24),
        radius: 1000,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: isSwitchOn
                ? container
                : Theme.of(context).colorScheme.errorContainer,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.label,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: isSwitchOn
                          ? onContainer
                          : Theme.of(context).colorScheme.onErrorContainer,
                    ),
              ),
              Switch(
                value: isSwitchOn,
                onChanged: (value) {
                  toggleSwitch();
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
