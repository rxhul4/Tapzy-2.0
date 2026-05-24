import 'package:flutter/material.dart';

class AppColors {
  static const Color colorTransparent = Colors.transparent;
  static const Color colorWhite = Colors.white;
  static const Color colorGrey = Colors.grey;
  static const Color colorBlueAccent = Colors.blueAccent;

  // Brand purples
  static const Color colorPurple = Color(0xFFA64CDF);
  static const Color colorPurpleLight = Color(0xFF774098);
  static const Color colorPurpleDim = Color(0xFF3D2050);

  // Backgrounds
  static const Color colorMainBlack = Color(0xFF0A0A0F);
  static const Color colorSurface = Color(0xFF13131A);
  static const Color colorCard = Color(0xFF1C1C27);
  static const Color colorGreyLatest = Color(0xFF1E2130);
  static const Color colorCardDark = Color(0xFF161622);

  // Text
  static const Color colorOffWhite = Color(0xFFF0F0F8);
  static const Color colorTextMuted = Color(0xFF7A7F94);
  static const Color colorTextSubtle = Color(0xFF4A4F64);

  // Utility
  static const Color colorBorder = Color(0xFF2A2D3E);
  static const Color colorBorderBright = Color(0xFF3D3F55);
  static const Color colorSearchBg = Color(0xFF1A1A26);
  static const Color colorSuccess = Color(0xFF2DD4A0);
  static const Color colorError = Color(0xFFFF5C6A);

  // Gradients
  static const LinearGradient gradientPurple = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF774098), Color(0xFFA64CDF)],
  );

  static const LinearGradient gradientBackground = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF0A0A0F), Color(0xFF0F0D18)],
  );

  static const LinearGradient gradientCard = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1C1C27), Color(0xFF161622)],
  );
}
