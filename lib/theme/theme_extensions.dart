import 'package:flutter/material.dart';
import 'app_colors.dart';

extension ThemeContext on BuildContext {
  ThemeData get theme => Theme.of(this);

  ColorScheme get colors => theme.colorScheme;

  ExtraColors get extra => theme.extension<ExtraColors>()!;

  TextTheme get text => theme.textTheme;

}