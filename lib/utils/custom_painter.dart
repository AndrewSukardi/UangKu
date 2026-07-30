import 'package:flutter/material.dart';

class BottomBarClipper extends CustomClipper<Path> {
  BottomBarClipper({
    this.notchWidth = 90,
    this.notchDepth = 38,
    this.cornerRadius = 28,
  });

  final double notchWidth;
  final double notchDepth;
  final double cornerRadius;

  @override
  Path getClip(Size size) {
    final path = Path();
    final center = size.width / 2;
    final halfWidth = notchWidth / 2;

    path.moveTo(0, cornerRadius);
    path.quadraticBezierTo(0, 0, cornerRadius, 0);

    path.lineTo(center - halfWidth, 0);

    // left curve down into notch
    path.cubicTo(
      center - halfWidth + (halfWidth * 0.55), 0,
      center - halfWidth * 0.35, notchDepth,
      center, notchDepth,
    );

    // right curve back up out of notch
    path.cubicTo(
      center + halfWidth * 0.35, notchDepth,
      center + halfWidth - (halfWidth * 0.55), 0,
      center + halfWidth, 0,
    );

    path.lineTo(size.width - cornerRadius, 0);
    path.quadraticBezierTo(size.width, 0, size.width, cornerRadius);
    path.lineTo(size.width, size.height - cornerRadius);
    path.quadraticBezierTo(size.width, size.height, size.width - cornerRadius, size.height);
    path.lineTo(cornerRadius, size.height);
    path.quadraticBezierTo(0, size.height, 0, size.height - cornerRadius);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant BottomBarClipper oldClipper) =>
      oldClipper.notchWidth != notchWidth ||
      oldClipper.notchDepth != notchDepth ||
      oldClipper.cornerRadius != cornerRadius;
}