import 'package:flutter/material.dart';
import 'package:UangKu/theme/theme_extensions.dart';

class RouterIcon extends StatelessWidget {
  final String assetPath;
  final Color background;
  const RouterIcon({
    super.key,
    required this.assetPath,
    required this.background,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Center(child: Image.asset(assetPath, width: 30, height: 30)),
    );
  }
}

class RouterIconText extends StatelessWidget {
  final String assetPath;
  final Color background;
  final String label;
  final bool selected;

  const RouterIconText({
    super.key,
    required this.assetPath,
    required this.background,
    required this.label,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 90,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),

      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(14),
        border: selected
            ? Border.all(color: context.colors.primary, width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: context.colors.shadow.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // <-- add this
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(assetPath, width: 30, height: 30),
          const SizedBox(height: 4),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: context.colors.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
