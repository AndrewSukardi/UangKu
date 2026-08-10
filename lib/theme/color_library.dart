import 'package:flutter/material.dart';

class ColorLibrary {
  ColorLibrary._();
  static const Color purple80 = Color(0xFFD0BCFF);
  static const Color purpleGrey80 = Color(0xFFCCC2DC);
  static const Color pink80 = Color(0xFFEFB8C8);

  static const Color purple40 = Color(0xFF6650A4);
  static const Color pink40 = Color(0xFF7D5260);
  static const Color purpleGrey40 = Color(0xFF625B71);

  // primary dark
  static const Color blue80 = Color(0xFFB3CFFF); // soft blue
  // secondary dark
  static const Color blueGrey80 = Color(0xFFBFCEDC); // harmonized grey-blue
  // tertiary dark
  static const Color cyan80 = Color(0xFFB8EAFF); // soft light cyan

  // primary light
  static const Color blue40 = Color(0xFF3867C8); // deep blue
  // secondary light
  static const Color blueGrey40 = Color(0xFF546575); // muted dark blue-grey
  // tertiary light
  static const Color cyan40 = Color(0xFF2F5E6E); // deep cyan-teal

  // primary light (icon-safe yellow)
  static const Color yellow40 = Color(0xFFF5C84C); // warm golden yellow

  // secondary light (balanced grey-yellow)
  static const Color yellowGrey40 = Color(0xFFCDBF9A); // muted beige-yellow

  // tertiary light (accent, replaces cyan)
  static const Color amber40 = Color(
    0xFFE0A93B,
  ); // soft amber, visible but not harsh

  // primary dark
  static const Color yellow80 = Color(0xFFD2B95B); // deep mustard yellow

  // secondary dark
  static const Color yellowGrey80 = Color(0xFF6A624D); // muted dark yellow-grey

  // tertiary dark
  static const Color amber80 = Color(0xFF8A6A2D); // deep amber-brown

  static const Color n0 = Color(0xFFFFFFFF); // Pure White
  static const Color n5 = Color(0xFFFAFAFA);
  static const Color n10 = Color(0xFFF5F5F5);
  static const Color n15 = Color(0xFFEDEDED);
  static const Color n20 = Color(0xFFE5E5E5);
  static const Color n30 = Color(0xFFD4D4D4);
  static const Color n40 = Color(0xFFBFBFBF);
  static const Color n50 = Color(0xFFA6A6A6);
  static const Color n60 = Color(0xFF8C8C8C);
  static const Color n70 = Color(0xFF737373);
  static const Color n80 = Color(0xFF595959);
  static const Color n90 = Color(0xFF404040);
  static const Color n95 = Color(0xFF262626);
  static const Color n100 = Color(0xFF000000); // Pure Black


  // --- Light Theme Mobile Palette ---
  static const Color containerDefaultLight = Color(0xFFE2E8F0); // Slate 200
  static const Color containerPressedLight = Color(0xFFCBD5E1); // Slate 300
  static const Color containerDisabledLight = Color(0xFFE5EAF0); // Soft blue-grey

  // --- Dark Theme Mobile Palette ---
  static const Color containerDefaultDark = Color(0xFF303946);
  static const Color containerPressedDark = Color(0xFF3B4655);
  static const Color containerDisabledDark = Color(0xFF202832); // Muted blue-grey
  // Success
  static const Color successLight = Color(0xFF2E7D32);
  static const Color successContainerLight = Color(0xFFC8E6C9);
  static const Color onSuccessLight = Color(0xFFFFFFFF);
  static const Color onSuccessContainerLight = Color(0xFF1B5E20);

  static const Color successDark = Color(0xFF81C784);
  static const Color successContainerDark = Color(0xFF1B4721);
  static const Color onSuccessDark = Color(0xFF1B4721);
  static const Color onSuccessContainerDark = Color(0xFFC8E6C9);

  // Warning
  static const Color warningLight = Color(0xFFF9A825);
  static const Color warningContainerLight = Color(0xFFFFF3CD);
  static const Color onWarningLight = Color(0xFFFFFFFF);
  static const Color onWarningContainerLight = Color(0xFF8A6D3B);

  static const Color warningDark = Color(0xFFFFCC80);
  static const Color warningContainerDark = Color(0xFF5C461A);
  static const Color onWarningDark = Color(0xFF5C461A);
  static const Color onWarningContainerDark = Color(0xFFFFF3CD);

  // Error
  static const Color errorLight = Color(0xFFB3261E);
  static const Color errorContainerLight = Color(0xFFF9DEDC);
  static const Color onErrorLight = Color(0xFFFFFFFF);
  static const Color onErrorContainerLight = Color(0xFF410E0B);

  static const Color errorDark = Color(0xFFE57373);
  static const Color errorContainerDark = Color(0xFF601410);
  static const Color onErrorDark = Color(0xFF601410);
  static const Color onErrorContainerDark = Color(0xFFF9DEDC);

  static const Color lightSurface100 = Color(
    0xFFFFFFFF,
  ); // Pure white – top surface
  static const Color lightSurface200 = Color(
    0xFFF8FAFF,
  ); // Soft blue-tint white
  static const Color lightSurface300 = Color(
    0xFFF1F5FF,
  ); // Slight tone, good for cards
  static const Color lightSurface400 = Color(0xFFE4EBF7); // Panel backgrounds
  static const Color lightSurface500 = Color(
    0xFFD6DFEC,
  ); // Low-priority sections
  static const Color darkSurface100 = Color(
    0xFF121212,
  ); // App background (Material-standard)
  static const Color darkSurface200 = Color(0xFF1A1A1A); // Default surface
  static const Color darkSurface300 = Color(0xFF222222); // Cards
  static const Color darkSurface400 = Color(0xFF2A2A2A); // Elevated surfaces
  static const Color darkSurface500 = Color(0xFF323232); // High elevation
}
