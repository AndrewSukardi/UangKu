import 'package:UangKu/theme/theme_extensions.dart';
import 'package:flutter/material.dart';

class ActionSheetStep {
  final String title;
  final Widget content;

  const ActionSheetStep({required this.title, required this.content});
}

class SourceStep extends StatelessWidget {
  const SourceStep({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey(0),
      children: const [
        Text("Source"),
        SizedBox(height: 16),
        TextField(decoration: InputDecoration(labelText: "Source")),
      ],
    );
  }
}



class TransactionTypeStep extends StatelessWidget {
  const TransactionTypeStep({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Column(
      key: const ValueKey(1),
      children: const [
        Text("Transaction Type"),
        SizedBox(height: 16),
        TextField(decoration: InputDecoration(labelText: "Type")),
      ],
    );
  }
}

class DetailsStep extends StatelessWidget {
  const DetailsStep({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey(2),
      children: const [
        TextField(decoration: InputDecoration(labelText: "Amount")),
        SizedBox(height: 16),
        TextField(decoration: InputDecoration(labelText: "Description")),
      ],
    );
  }
}

class ConfirmationStep extends StatelessWidget {
  const ConfirmationStep({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Icon(Icons.check_circle, color: Colors.green, size: 80),
        SizedBox(height: 12),
        Text("Ready to save!"),
      ],
    );
  }
}
