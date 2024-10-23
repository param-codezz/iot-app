import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:my_home_app/logic/connections/connections.dart';
import 'package:my_home_app/logic/data/store_data.dart';
import 'package:my_home_app/ui/pages/home.dart';
import 'package:my_home_app/ui/pages/login.dart';
import 'package:provider/provider.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';

String generateSha256Hash(String input) {
  var bytes = utf8.encode(input);
  var digest = sha256.convert(bytes);
  return digest.toString();
}

class CreatePage extends StatefulWidget {
  const CreatePage({super.key});

  @override
  State<CreatePage> createState() => _CreatePageState();
}

class _CreatePageState extends State<CreatePage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  String? _emailError;
  String? _usernameError;
  String? _passwordError;
  String? _confirmPasswordError;
  late MyTextFields myTextFields;
  final GlobalKey<_MyTextFieldsState> _myTextFieldsKey =
      GlobalKey<_MyTextFieldsState>();
  String? esp_UID;
  @override
  void initState() {
    super.initState();
    myTextFields = MyTextFields(
      key: _myTextFieldsKey,
    );

    // Add listeners to clear the error message when user types
    _emailController.addListener(() {
      if (_emailController.text.isNotEmpty && _emailError != null) {
        setState(() {
          _emailError = null;
        });
      }
    });

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

    _confirmPasswordController.addListener(() {
      if (_confirmPasswordController.text.isNotEmpty &&
          _confirmPasswordError != null) {
        setState(() {
          _confirmPasswordError = null;
        });
      }
    });
  }

  void create() {
    final client = Provider.of<WebSocketClient>(context, listen: false);
    setState(() {
      final String username = _usernameController.text.trim();
      final String password = _passwordController.text.trim();
      _emailError = username.isEmpty ? 'Email cannot be empty' : null;
      _usernameError = username.isEmpty ? 'Username cannot be empty' : null;
      _passwordError = password.isEmpty ? 'Password cannot be empty' : null;
      _confirmPasswordError =
          password.isEmpty ? 'Password does not match' : null;
      _myTextFieldsKey.currentState?.validate();
    });
    if (client.isConnected()) {
      if (_passwordError == null && _usernameError == null) {
        setState(() {
          esp_UID = _myTextFieldsKey.currentState?.getInput();
        });
        client.sendData({
          'user': 'x64',
          'secret': 'x64secret',
          'event': 'create_account',
          'data': {
            'username': _usernameController.text,
            'password': generateSha256Hash(_passwordController.text),
            'email': _emailController.text,
            'esp_UID': _myTextFieldsKey.currentState?.getInput()
          }
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot Connect'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final client = Provider.of<WebSocketClient>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Create',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
              const SizedBox(height: 40),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9@._-]')),
                ],
                decoration: InputDecoration(
                  filled: false,
                  hintText: 'Email',
                  labelText: 'Email',
                  border: const OutlineInputBorder(),
                  errorText: _emailError,
                ),
              ),
              const SizedBox(height: 18),
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
              TextField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  filled: false,
                  hintText: 'Confirm Password',
                  labelText: 'Confirm Password',
                  border: const OutlineInputBorder(),
                  errorText: _confirmPasswordError,
                ),
              ),
              const Divider(),
              const Text('Enter ESP32 Key'),
              myTextFields,
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  FilledButton(
                    onPressed: create,
                    child: const Text('Create'),
                  ),
                ],
              ),
              ValueListenableBuilder<String?>(
                valueListenable: client.lastReceivedMessage,
                builder: (context, message, child) {
                  if (message != null) {
                    final Map<String, dynamic> messageData =
                        jsonDecode(message);
                    if (messageData['create_account'] == true) {
                      LocalStorage.saveData('esp_UID', esp_UID ?? "");
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                Icon(
                                  Icons.done_rounded,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onInverseSurface,
                                ), // Your icon here
                                const SizedBox(
                                    width: 8), // Space between icon and text
                                Expanded(
                                  child: Text(
                                    'Account Created Successfully',
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onInverseSurface,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginPage(),
                          ),
                        );
                      });
                      return const Text('Account created successfully');
                    } else if (messageData['create_account'] == 'false') {
                      return const Text('Account creation failed');
                    } else {
                      return Text('Message: ${messageData['message']}');
                    }
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
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

class MyTextFields extends StatefulWidget {
  const MyTextFields({Key? key}) : super(key: key);

  @override
  _MyTextFieldsState createState() => _MyTextFieldsState();
}

class _MyTextFieldsState extends State<MyTextFields> {
  final List<TextEditingController> _controllers =
      List.generate(4, (_) => TextEditingController());
  final _formKey = GlobalKey<FormState>();

  void _validateFields() {
    if (_formKey.currentState!.validate()) {}
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Row(
        children: List.generate(4, (index) {
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: TextFormField(
                controller: _controllers[index],
                maxLength: 4, // Limit input to 4 characters
                inputFormatters: [
                  LengthLimitingTextInputFormatter(4),
                ],
                decoration: InputDecoration(
                  counterText: '',
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  hintText: 'XXXX',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Field cannot be empty';
                  }
                  return null;
                },
              ),
            ),
          );
        })
            .expand((widget) => [
                  widget,
                  const Padding(
                    padding: EdgeInsets.all(4.0),
                    child: Text('-'),
                  )
                ])
            .toList()
          ..removeLast(), // Remove the last dash
      ),
    );
  }

  void validate() {
    _validateFields();
  }

  String getInput() {
    return _controllers.map((controller) => controller.text).join('-');
  }
}
