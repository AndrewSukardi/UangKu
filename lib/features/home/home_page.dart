import 'package:flutter/material.dart';
import 'package:UangKu/services/notification_service.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const Center(child: Text("Home")),

          ElevatedButton(
            onPressed: () {
              NotificationService.showTestNotification();
            },
            child: const Text('Test Notification'),
          ),
        ],
      ),
    );
  }
}

