import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'color_library.dart';

class AppTheme {
  static final light = ThemeData(
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF59C7D8),
      primaryContainer: Color(0xFFBCEEF5),

      secondary: Color(0xFFBCEEF5),
      secondaryContainer: Color(0xFFFFF3C4),

      surface: Color(0xFFF1F3F5),
      onSurface: Color(0xFF1A1A1A),

      onPrimary: Colors.white,
      onSecondary: Colors.black87,
    ),

    floatingActionButtonTheme: FloatingActionButtonThemeData(
      elevation: 4,
    ),

    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Colors.white,
      shadowColor: const Color(0xFF1A1A1A),
      elevation: 4,

      labelTextStyle: WidgetStateProperty.resolveWith<TextStyle?>((states) {
        if (states.contains(WidgetState.selected)) {
          return const TextStyle(fontWeight: FontWeight.bold);
        }

        return const TextStyle(color: Colors.grey);
      }),


      iconTheme: WidgetStateProperty.resolveWith<IconThemeData?>((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: Colors.white);
        }

        return const IconThemeData(color: Colors.grey);
      }),

      indicatorColor: const Color(0xFFBCEEF5),
    ),

    extensions: const [
      ExtraColors(
        icon: Color(0xFF4B3428),
        iconDisabled: Colors.grey,
        success: ColorLibrary.successLight,
        error: ColorLibrary.errorLight,
        warning: ColorLibrary.warningLight,
      ),
    ],
  );

  static final dark = ThemeData(
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF59C7D8),
      primaryContainer: Color(0xFF14616F),

      secondary: Color(0xFFF5C84C),
      secondaryContainer: Color(0xFF7A6112),

      surface: Color(0xFF15181B),
      onSurface: Colors.white,

      onPrimary: Colors.black,
      onSecondary: Colors.black,
    ),

    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: const Color(0xFF181A1E),

      shadowColor: Colors.white,
      elevation: 4,
      iconTheme: WidgetStateProperty.resolveWith<IconThemeData?>((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: Colors.black);
        }

        return const IconThemeData(color: Colors.grey);
      }),

      

      
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const TextStyle(
            color: Color(0xFF59C7D8),
            fontWeight: FontWeight.bold,
          );
        }

        return const TextStyle(color: Colors.white);
      }),
      indicatorColor: const Color(0xFFBCEEF5),
    ),

    extensions: const [
      ExtraColors(
        icon: Colors.white,
        iconDisabled: Color(0xFF6B7280),
        success: ColorLibrary.successDark,
        error: ColorLibrary.errorDark,
        warning: ColorLibrary.warningDark,
      ),
    ],
  );
}
