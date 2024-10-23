import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:my_home_app/logic/connections/connections.dart';
import 'package:my_home_app/ui/components/snackbar_custom.dart';
import 'package:provider/provider.dart';
import 'package:crypto/crypto.dart'; // For the SHA-256 algorithm

// class AuthenticateDialog extends StatefulWidget {
//   const AuthenticateDialog({super.key});

//   Future<void> show(BuildContext context) {
//     return showDialog(
//       context: context,
//       builder: (BuildContext context) => const AuthenticateDialog(),
//     );
//   }

//   bool getAuthenticationStatus(BuildContext context) {
//     final state = context.findAncestorStateOfType<_AuthenticateDialogState>();
//     return state?.getAuthenticationStatus() ?? false;
//   }

//   @override
//   State<AuthenticateDialog> createState() => _AuthenticateDialogState();
// }

// class _AuthenticateDialogState extends State<AuthenticateDialog> {
//   late WebSocketClient webSocketClient;
//   TextEditingController username = TextEditingController();
//   TextEditingController password = TextEditingController();
//   bool usernameError = false;
//   bool passwordError = false;
//   bool isAuthenticated = false;
//   String convertToSha256(String text) {
//     var bytes = utf8.encode(text); // Convert text to UTF-8 bytes
//     var digest = sha256.convert(bytes); // Hash using SHA-256
//     return digest.toString(); // Return hash as a hexadecimal string
//   }

//   @override
//   void initState() {
//     super.initState();
//     webSocketClient = Provider.of<WebSocketClient>(context, listen: false);
//     webSocketClient.lastReceivedMessage.addListener(() async {
//       if (webSocketClient.lastReceivedMessage.value != null) {
//         final jsonData = jsonDecode(webSocketClient.lastReceivedMessage.value!);
//         if (webSocketClient.isConnected()) {
//           if (jsonData['authenticate'] == true) {
//             SnackbarHelper.showSnackbar(
//                 context, 'success', 'Authenticated Succesfully');
//             Navigator.pop(context);
//             setState(() {
//               isAuthenticated = true;
//             });
//           } else {
//             SnackbarHelper.showSnackbar(
//                 context, 'error', 'Authentication failed');
//             Navigator.pop(context);
//             setState(() {
//               isAuthenticated = false;
//             });
//           }
//         } else {
//           SnackbarHelper.showSnackbar(
//               context, 'warning', 'Cannot contact server');
//         }
//       }
//     });
//   }

//   void _handleClick() {
//     String usernameText = username.text;
//     String passwordText = password.text;

//     if (usernameText.isEmpty) {
//       setState(() {
//         usernameError = true;
//       });
//     }
//     if (passwordText.isEmpty) {
//       setState(() {
//         passwordError = true;
//       });
//     }

//     if (usernameText.isNotEmpty && passwordText.isNotEmpty) {
//       webSocketClient.sendData({
//         'event': 'authenticate',
//         'user': 'x64',
//         'secret': 'x64secret',
//         'data': {'username': usernameText, 'password': convertToSha256(passwordText)}
//       });
//       print({
//         'event': 'authenticate',
//         'user': 'x64',
//         'secret': 'x64secret',
//         'data': {'username': usernameText, 'password': passwordText}
//       });
//     }
//   }

//   bool getAuthenticationStatus() {
//     return isAuthenticated;
//   }

//   @override
//   void dispose() {
//     webSocketClient.lastReceivedMessage
//         .removeListener(() {}); // Remove the listener
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AlertDialog(
//       icon: const Icon(Icons.mobile_friendly_rounded),
//       title: const Text('Authenticate'),
//       semanticLabel: 'Authenticate to continue',
//       content: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Text(
//             'Enter username and password to perform the action. This dialog ensures the security and prevents unauthorized access to your Home System',
//             style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                   color: Theme.of(context).colorScheme.onSurfaceVariant,
//                 ),
//           ),
//           const SizedBox(
//             height: 16,
//           ),
//           TextField(
//             controller: username,
//             decoration: InputDecoration(
//               filled: false,
//               border: OutlineInputBorder(
//                 borderSide:
//                     BorderSide(color: Theme.of(context).colorScheme.primary),
//               ),
//               fillColor: Colors.transparent,
//               labelText: 'Username',
//               errorText: usernameError ? 'Enter username' : null,
//             ),
//           ),
//           const SizedBox(
//             height: 12,
//           ),
//           TextField(
//             controller: password,
//             decoration: InputDecoration(
//               filled: false,
//               border: OutlineInputBorder(
//                 borderSide:
//                     BorderSide(color: Theme.of(context).colorScheme.primary),
//               ),
//               fillColor: Colors.transparent,
//               labelText: 'Password',
//               errorBorder: OutlineInputBorder(
//                 borderSide:
//                     BorderSide(color: Theme.of(context).colorScheme.error),
//               ),
//               errorText: passwordError ? 'Enter username' : null,
//             ),
//             obscureText: true,
//           ),
//           const SizedBox(
//             height: 16,
//           ),
//         ],
//       ),
//       actions: [
//         OutlinedButton(
//           onPressed: () => Navigator.pop(context),
//           child: const Text('Cancel'),
//         ),
//         FilledButton(
//           onPressed: _handleClick,
//           child: const Text('Continue'),
//         ),
//       ],
//     );
//   }
// }
class AuthenticateDialog extends StatefulWidget {
  const AuthenticateDialog({super.key});

  @override
  State<AuthenticateDialog> createState() => _AuthenticateDialogState();

  static Future<bool> show(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        final webSocketClient =
            Provider.of<WebSocketClient>(context, listen: false);
        webSocketClient.lastReceivedMessage.value = null;
        return const AuthenticateDialog();
      },
    ).then((value) => value ?? false); // Default to false if null
  }
}

class _AuthenticateDialogState extends State<AuthenticateDialog> {
  late WebSocketClient webSocketClient;
  final TextEditingController username = TextEditingController();
  final TextEditingController password = TextEditingController();
  bool usernameError = false;
  bool passwordError = false;
  bool isAuthenticated = false;

  String convertToSha256(String text) {
    var bytes = utf8.encode(text); // Convert text to UTF-8 bytes
    var digest = sha256.convert(bytes); // Hash using SHA-256
    return digest.toString(); // Return hash as a hexadecimal string
  }

  @override
  void initState() {
    super.initState();
    webSocketClient = Provider.of<WebSocketClient>(context, listen: false);
    webSocketClient.lastReceivedMessage.value = null;
    webSocketClient.lastReceivedMessage.addListener(_handleWebSocketMessage);
  }

  void _handleWebSocketMessage() {
    if (webSocketClient.lastReceivedMessage.value != null) {
      final jsonData = jsonDecode(webSocketClient.lastReceivedMessage.value!);
      if (webSocketClient.isConnected()) {
        if (jsonData['authenticate'] == true) {
          SnackbarHelper.showSnackbar(
              context, 'success', 'Authenticated Successfully');
          setState(() {
            isAuthenticated = true;
          });
          Navigator.pop(context, true); // Pass success back to the caller
        } else {
          SnackbarHelper.showSnackbar(
              context, 'error', 'Authentication failed');
          setState(() {
            isAuthenticated = false;
          });
          Navigator.pop(context, false); // Pass failure back to the caller
        }
      } else {
        SnackbarHelper.showSnackbar(
            context, 'warning', 'Cannot contact server');
      }
    }
  }

  void _handleClick() {
    String usernameText = username.text;
    String passwordText = password.text;

    // Reset error states
    setState(() {
      usernameError = false;
      passwordError = false;
    });

    if (usernameText.isEmpty) {
      setState(() {
        usernameError = true;
      });
    }
    if (passwordText.isEmpty) {
      setState(() {
        passwordError = true;
      });
    }

    if (usernameText.isNotEmpty && passwordText.isNotEmpty) {
      webSocketClient.sendData({
        'event': 'authenticate',
        'user': 'x64',
        'secret': 'x64secret',
        'data': {
          'username': usernameText,
          'password': convertToSha256(passwordText)
        }
      });
      print({
        'event': 'authenticate',
        'user': 'x64',
        'secret': 'x64secret',
        'data': {'username': usernameText, 'password': passwordText}
      });
    }
  }

  @override
  void dispose() {
    webSocketClient.lastReceivedMessage
        .removeListener(() {}); // Remove the listener
    webSocketClient.lastReceivedMessage.removeListener(_handleWebSocketMessage);
    username.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      icon: const Icon(Icons.mobile_friendly_rounded),
      title: const Text('Authenticate'),
      semanticLabel: 'Authenticate to continue',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Enter username and password to perform the action. This dialog ensures the security and prevents unauthorized access to your Home System',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: username,
            decoration: InputDecoration(
              filled: false,
              border: OutlineInputBorder(
                borderSide:
                    BorderSide(color: Theme.of(context).colorScheme.primary),
              ),
              fillColor: Colors.transparent,
              labelText: 'Username',
              errorText: usernameError ? 'Enter username' : null,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: password,
            decoration: InputDecoration(
              filled: false,
              border: OutlineInputBorder(
                borderSide:
                    BorderSide(color: Theme.of(context).colorScheme.primary),
              ),
              fillColor: Colors.transparent,
              labelText: 'Password',
              errorBorder: OutlineInputBorder(
                borderSide:
                    BorderSide(color: Theme.of(context).colorScheme.error),
              ),
              errorText: passwordError ? 'Enter password' : null,
            ),
            obscureText: true,
          ),
          const SizedBox(height: 16),
        ],
      ),
      actions: [
        OutlinedButton(
          onPressed: () =>
              Navigator.pop(context, false), // Cancel returns false
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _handleClick,
          child: const Text('Continue'),
        ),
      ],
    );
  }
}
