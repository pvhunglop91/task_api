import 'package:flutter/material.dart';
import 'package:task_api_flutter/components/button/td_elevated_button.dart';
import 'package:task_api_flutter/pages/auth/login_page.dart';
import 'package:task_api_flutter/services/local/shared_prefs.dart';

class DrawerPage extends StatefulWidget {
  const DrawerPage({super.key});

  @override
  State<DrawerPage> createState() => _DrawerPageState();
}

class _DrawerPageState extends State<DrawerPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const SizedBox(height: 40),
          const Text('Drawer Pahe'),
          const SizedBox(height: 40),
          TdElevatedButton.outline(
              onPressed: () {
                SharedPrefs.removeSeason();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => LoginPage(),
                  ),
                  (Route<dynamic> route) => false,
                );
              },
              text: 'Logout')
        ],
      ),
    );
  }
}
