import 'package:flutter/material.dart';


class ActionSheet extends StatelessWidget {
  final Widget child;

  const ActionSheet({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        24, // left
        12, // top
        24, // right
        60, // bottom
      ),
      child: child,
    );
  }
}

