import 'package:flutter/material.dart';

@immutable
class ExtraColors extends ThemeExtension<ExtraColors> {
  final Color icon;
  final Color iconDisabled;
  final Color success;
  final Color error;
  final Color warning;
  final Color grayColor;

  const ExtraColors({
    required this.icon,
    required this.iconDisabled,
    required this.success,
    required this.error,
    required this.warning,
    required this.grayColor,
  });

  @override
  ExtraColors copyWith({
    Color? icon,
    Color? iconDisabled,
    Color? success,
    Color? error,
    Color? warning,
    Color? grayColor,
  }) {
    return ExtraColors(
      icon: icon ?? this.icon,
      iconDisabled: iconDisabled ?? this.iconDisabled,
      success: success ?? this.success,
      error: error ?? this.error,
      warning: warning ?? this.warning,
      grayColor: grayColor ?? this.grayColor
    );
  }

  @override
  ExtraColors lerp(ThemeExtension<ExtraColors>? other, double t) {
    if (other is! ExtraColors) return this;

    return ExtraColors(
      icon: Color.lerp(icon, other.icon, t)!,
      iconDisabled: Color.lerp(iconDisabled, other.iconDisabled, t)!,
      success: Color.lerp(success, other.success, t)!,
      error: Color.lerp(error, other.error, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      grayColor: Color.lerp(grayColor, other.grayColor, t)!,
    );
  }
}