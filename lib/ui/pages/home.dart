import 'package:flutter/material.dart';
import 'package:my_home_app/ui/components/padded_divider.dart';
import 'package:my_home_app/ui/components/tabs/control.dart';
import 'package:my_home_app/ui/components/tabs/data.dart';
import 'package:my_home_app/ui/components/tabs/home.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 0;
  List<Widget> body = const [
    HomeTab(),
    ControlTab(),
    DataTab(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          "My Home",
          style: Theme.of(context).textTheme.titleLarge,
        ),
        actions: [
          PopupMenuButton(
            itemBuilder: (BuildContext context) => <PopupMenuEntry>[
              PopupMenuItem(
                child: const ListTile(
                  leading: Icon(Icons.info_rounded),
                  title: Text('About ESP32'),
                ),
                onTap: () {},
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                child: ListTile(
                  leading: Icon(
                    Icons.logout_rounded,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  textColor: Theme.of(context).colorScheme.error,
                  title: const Text('Logout'),
                ),
              ),
            ],
          ),
        ],
        centerTitle: true,
        elevation: 10,
      ),
      body: SingleChildScrollView(child: body[_currentIndex]),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (int newIndex) => setState(() {
          _currentIndex = newIndex;
        }),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Home',
            tooltip: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.control_camera_rounded),
            label: 'Control',
            tooltip: 'Control Sensor',
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.data_array_rounded),
              label: 'Data',
              tooltip: 'Sensor Data'),
        ],
      ),
    );
  }
}
