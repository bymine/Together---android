import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

TextStyle appBarStyle = TextStyle(
  color: Colors.black,
);

Color titleColor = Colors.green.withOpacity(0.5);

class GradientColors {
  final List<Color> colors;
  GradientColors(this.colors);

  static List<Color> sky = [Color(0xFF6448FE), Color(0xFF5FC6FF)];
  static List<Color> sunset = [Color(0xFFFE6197), Color(0xFFFFB463)];
  static List<Color> sea = [Color(0xFF61A3FE), Color(0xFFBB7AF2)];
  static List<Color> mango = [Color(0xFFF4AE64), Color(0xFFFFE130)];
  static List<Color> fire = [Color(0xFFEB638A), Color(0xFFFF8484)];
}

class GradientTemplate {
  static List<GradientColors> gradientTemplate = [
    GradientColors(GradientColors.sky),
    GradientColors(GradientColors.sunset),
    GradientColors(GradientColors.sea),
    GradientColors(GradientColors.mango),
    GradientColors(GradientColors.fire),
  ];
}
