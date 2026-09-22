import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'color_library.dart';

class AppTheme {
  static final light = ThemeData(
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF59C7D8),
      primaryContainer: Color(0xFFBCEEF5),

      secondary: Color(0xFF6B8EAE),
      secondaryContainer: Color(0xFFF7F8FC),

      surface: Color(0xFFF1F3F5),
      onSurface: Color(0xFF1A1A1A),

      onPrimary: Colors.white,
      onSecondary: Colors.black87,
    ),

    floatingActionButtonTheme: FloatingActionButtonThemeData(
      elevation: 4,

      backgroundColor: Color(0xFF59C7D8),
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
        grayColor: ColorLibrary.containerDisabledLight,
        grayText: ColorLibrary.n50,
      ),
    ],

    textTheme: const TextTheme(
      displayLarge: TextStyle(fontSize: 57, fontWeight: FontWeight.bold),
      headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
      titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
      titleMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
      titleSmall: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
      bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
      bodySmall: TextStyle(fontSize: 10, fontWeight: FontWeight.w400),
      labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
    ),
  );

  static final dark = ThemeData(
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF59C7D8),
      primaryContainer: Color(0xFF14616F),

      secondary: Color(0xFF9AB7D0),
      secondaryContainer: Color(0xFF17191D),

      surface: Color(0xFF262626),
      onSurface: Colors.white,

      onPrimary: Colors.black,
      onSecondary: Colors.black,

      shadow: Color(0xFF1E1E1E),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      elevation: 4,

      backgroundColor: Color(0xFF59C7D8),
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

      labelTextStyle: WidgetStateProperty.resolveWith<TextStyle?>((states) {
        if (states.contains(WidgetState.selected)) {
          return const TextStyle(fontWeight: FontWeight.bold);
        }

        return const TextStyle(color: Colors.grey);
      }),

      indicatorColor: const Color(0xFFBCEEF5),
    ),

    textTheme: const TextTheme(
      displayLarge: TextStyle(fontSize: 57, fontWeight: FontWeight.bold),
      headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
      titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
      titleMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
      titleSmall: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
      bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
      bodySmall: TextStyle(fontSize: 10, fontWeight: FontWeight.w400),
      labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
    ),
    extensions: const [
      ExtraColors(
        icon: Colors.white,
        iconDisabled: Color(0xFF6B7280),
        success: ColorLibrary.successDark,
        error: ColorLibrary.errorDark,
        warning: ColorLibrary.warningDark,
        grayColor: ColorLibrary.containerDisabledDark,
        grayText: ColorLibrary.n50,
      ),
    ],
  );
}
