import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/note_model.dart';

/// A single animated bubble representing one note.
class BubbleWidget extends StatefulWidget {
  final SoundNote note;

  const BubbleWidget({
    super.key,
    required this.note,
  });

  @override
  State<BubbleWidget> createState() => _BubbleWidgetState();
}

class _BubbleWidgetState extends State<BubbleWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final double _phaseShift;

  @override
  void initState() {
    super.initState();
    _phaseShift = math.Random().nextDouble() * 2 * math.pi;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double _bubbleDiameterForDuration(double seconds) {
    final clamped = seconds.clamp(2.0, 15.0);
    const minSize = 70.0;
    const maxSize = 130.0;
    final t = (clamped - 2.0) / (15.0 - 2.0);
    return minSize + (maxSize - minSize) * t;
  }

  @override
  Widget build(BuildContext context) {
    final diameter = _bubbleDiameterForDuration(widget.note.durationSeconds);
    final color = widget.note.color;

    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final sway =
              math.sin(_controller.value * 2 * math.pi + _phaseShift) * 6.0;
          return Transform.translate(
            offset: Offset(0, sway),
            child: child,
          );
        },
        child: Container(
          width: diameter,
          height: diameter,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                color.withValues(alpha: 0.8),
                color.withValues(alpha: 0.95),
              ],
              center: const Alignment(-0.3, -0.3),
              radius: 0.8,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.3),
                blurRadius: 12,
                spreadRadius: 2,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Shine effect
              Positioned(
                top: diameter * 0.15,
                right: diameter * 0.2,
                child: Container(
                  width: diameter * 0.15,
                  height: diameter * 0.1,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Icon(
                Icons.play_arrow_rounded,
                size: diameter * 0.35,
                color: Colors.white.withValues(alpha: 0.9),
              ),
              Positioned(
                bottom: diameter * 0.2,
                child: Container(
                  constraints: BoxConstraints(maxWidth: diameter * 0.85),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    widget.note.displayLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
