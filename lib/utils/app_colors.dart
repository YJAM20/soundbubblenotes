import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Small palette of playful colors used for the bubbles.
const List<Color> kBubblePalette = [
  Color(0xFFEF5350), // red
  Color(0xFFAB47BC), // purple
  Color(0xFF5C6BC0), // indigo
  Color(0xFF26A69A), // teal
  Color(0xFFFFCA28), // amber
  Color(0xFFFF7043), // deep orange
];

Color pickRandomBubbleColor() {
  final random = math.Random();
  return kBubblePalette[random.nextInt(kBubblePalette.length)];
}
