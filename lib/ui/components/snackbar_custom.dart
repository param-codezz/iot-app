import 'package:flutter/material.dart';
import 'package:my_home_app/logic/connections/connections.dart';
import 'package:provider/provider.dart';

class SnackbarHelper {
  static void showSnackbar(BuildContext context, String type, String message) {
    bool isDark = MediaQuery.platformBrightnessOf(context) == Brightness.dark;
    Color foregroundColor;
    Color backgroundColor;
    IconData icon = type == 'success'
        ? Icons.done_rounded
        : type == 'error'
            ? Icons.error_rounded
            : Icons.warning_rounded;
    if (isDark) {
      backgroundColor = type == 'success'
          ? Colors.green.shade800
          : type == 'error'
              ? Colors.red.shade800
              : Colors.yellow.shade800;
      foregroundColor = type == 'success'
          ? Colors.green.shade100
          : type == 'error'
              ? Colors.red.shade100
              : Colors.yellow.shade100;
    } else {
      backgroundColor = type == 'success'
          ? Colors.green.shade100
          : type == 'error'
              ? Colors.red.shade100
              : Colors.yellow.shade100;
      foregroundColor = type == 'success'
          ? Colors.green.shade800
          : type == 'error'
              ? Colors.red.shade800
              : Colors.yellow.shade800;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon,
                color: foregroundColor), // Icon displayed in the Snackbar
            const SizedBox(width: 10), // Space between icon and message
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: foregroundColor,
                ), // Message text color
              ),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: backgroundColor,
      ),
    );
  }

  static void showTimeoutSnackbar(BuildContext context) {
    bool isDark = MediaQuery.platformBrightnessOf(context) == Brightness.dark;
    Color backgroundColor =
        isDark ? Colors.orange.shade800 : Colors.orange.shade100;
    Color foregroundColor =
        isDark ? Colors.orange.shade100 : Colors.orange.shade800;
    final webSocketClient =
        Provider.of<WebSocketClient>(context, listen: false);

    void reconnect() {
      webSocketClient.reconnect();
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.signal_wifi_statusbar_connected_no_internet_4_rounded,
                color: foregroundColor), // Icon displayed in the Snackbar
            const SizedBox(width: 10), // Space between icon and message
            Expanded(
              child: Text(
                'Cannot connect to server',
                style: TextStyle(
                  color: foregroundColor,
                ), // Message text color
              ),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Retry',
          onPressed: reconnect,
          textColor: isDark ? Colors.black87 : Colors.black54,
        ),
        backgroundColor: backgroundColor,
      ),
    );
  }
}
