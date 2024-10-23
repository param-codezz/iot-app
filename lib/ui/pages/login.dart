import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:my_home_app/logic/connections/connections.dart';
import 'package:my_home_app/logic/data/store_data.dart';
import 'package:my_home_app/ui/components/snackbar_custom.dart';
import 'package:my_home_app/ui/pages/create.dart';
import 'package:my_home_app/ui/pages/home.dart';
import 'package:provider/provider.dart';
import 'package:crypto/crypto.dart';

String generateSha256Hash(String input) {
  var bytes = utf8.encode(input);
  var digest = sha256.convert(bytes);
  return digest.toString();
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _usernameError;
  String? _passwordError;

  @override
  void initState() {
    super.initState();

    // Add listeners to clear the error message when user types
    _usernameController.addListener(() {
      if (_usernameController.text.isNotEmpty && _usernameError != null) {
        setState(() {
          _usernameError = null;
        });
      }
    });

    _passwordController.addListener(() {
      if (_passwordController.text.isNotEmpty && _passwordError != null) {
        setState(() {
          _passwordError = null;
        });
      }
    });
  }

  void _login() async {
    final client = Provider.of<WebSocketClient>(context, listen: false);
    setState(() {
      final String username = _usernameController.text.trim();
      final String password = _passwordController.text.trim();

      _usernameError = username.isEmpty ? 'Username cannot be empty' : null;
      _passwordError = password.isEmpty ? 'Password cannot be empty' : null;
    });
    String uid = await LocalStorage.retrieveData('esp_UID') ?? "";
    print(uid);
    if (client.isConnected()) {
      if (_passwordError == null && _usernameError == null) {
        client.sendData({
          'user': 'x64',
          'secret': 'x64secret',
          'event': 'login',
          'esp_UID': uid,
          'data': {
            'username': _usernameController.text,
            'password': generateSha256Hash(_passwordController.text),
          },
        });
      }
    } else {
      SnackbarHelper.showTimeoutSnackbar(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final client = Provider.of<WebSocketClient>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [
          PopupMenuButton(
            itemBuilder: (BuildContext context) => <PopupMenuEntry>[
              PopupMenuItem(
                child: const ListTile(
                  leading: Icon(Icons.add_rounded),
                  title: Text('Create Account'),
                ),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreatePage(),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Login',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
            const SizedBox(height: 40),
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                filled: false,
                hintText: 'Username',
                labelText: 'Username',
                border: const OutlineInputBorder(),
                errorText: _usernameError,
              ),
            ),
            const SizedBox(height: 18),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                filled: false,
                hintText: 'Password',
                labelText: 'Password',
                border: const OutlineInputBorder(),
                errorText: _passwordError,
              ),
            ),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                FilledButton(
                  onPressed: _login,
                  child: const Text('Login'),
                ),
              ],
            ),
            ValueListenableBuilder<String?>(
              valueListenable: client.lastReceivedMessage,
              builder: (context, message, child) {
                if (message != null) {
                  final Map<String, dynamic> messageData = jsonDecode(message);
                  if (messageData['login'] == 'true') {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MyHomePage(),
                        ),
                      );
                      SnackbarHelper.showSnackbar(
                          context, 'success', 'Login successfully');
                    });
                  } else if (messageData['login'] == 'false') {
                    return const Text('Login failed');
                  }
                }
                if (!client.isConnected()) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    SnackbarHelper.showTimeoutSnackbar(context);
                  });
                }
                return const SizedBox.shrink();
              },
            )
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
