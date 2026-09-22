import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:UangKu/services/notification_service.dart';
import 'package:UangKu/core/providers/database_providers.dart'; // appDatabaseProvider

// CHANGED: StatelessWidget -> ConsumerWidget, so we get `ref`.
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  // NEW: reads every wallet row straight from the DB and prints it.
  Future<void> _checkWallets(WidgetRef ref) async {
    final db = ref.read(appDatabaseProvider);
    final rows = await db.select(db.wallets).get();
    debugPrint('Wallets in DB: ${rows.length}');
    for (final w in rows) {
      debugPrint(
        '${w.id} | ${w.name} | ${w.type} | last4=${w.lastFour} | balance=${w.balance}',
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // CHANGED: build now takes `ref` too.
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

          // NEW: tap this after saving a wallet, then check your console.
          ElevatedButton(
            onPressed: () => _checkWallets(ref),
            child: const Text('Check Wallets in DB'),
          ),
        ],
      ),
    );
  }
}