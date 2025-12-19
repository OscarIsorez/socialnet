import 'package:flutter/material.dart';

/// Central colour palette for the Mapvent application.
///
/// Based on the Figma design tokens extracted from the Mapvent designs.
/// Uses a blue-centered color scheme with warm backgrounds.
class AppColors {
  AppColors._();

  // Primary Mapvent blue color palette
  static const Color primary = Color(0xFF3F88BD); // Main blue from Mapvent text
  static const Color primaryLight = Color(0xFF5C9BD2); // Lighter blue variant
  static const Color primaryDark = Color(0xFF1434B3); // Dark blue for buttons
  static const Color accent = Color(0xFF0088FF); // Bright blue for highlights

  // Background colors from Figma
  static const Color scaffoldBackground = Color(
    0xFFFDF2F2,
  ); // Light pink/beige background
  static const Color cardBackground = Colors.white;
  static const Color surfaceLight = Color(0xFFF5F5F5); // Light surface

  // Status colors
  static const Color error = Color(0xFFEF4444);
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFFACC15);

  // Text colors
  static const Color textPrimary = Color(
    0xFF1D1B20,
  ); // M3/sys/light/on-surface from design
  static const Color textSecondary = Color(0xFF475569);
  static const Color border = Color(
    0xFF262626,
  ); // Dark border as seen in input fields

  // Button colors from Figma
  static const Color buttonPrimary = Color(
    0xFF8390C3,
  ); // Button background gradient
  static const Color buttonSecondary = Color(0xFF3F88BD);
}
