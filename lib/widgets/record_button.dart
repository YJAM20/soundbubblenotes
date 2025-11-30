import 'package:flutter/material.dart';

class RecordButton extends StatelessWidget {
  final bool isRecording;
  final double progress;
  final VoidCallback onTap;

  const RecordButton({
    super.key,
    required this.isRecording,
    required this.progress,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme.primaryContainer;
    final onColor = theme.colorScheme.onPrimaryContainer;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: EdgeInsets.symmetric(
          horizontal: isRecording ? 32 : 24,
          vertical: 16,
        ),
        decoration: BoxDecoration(
          color: isRecording ? Colors.redAccent.withOpacity(0.2) : Colors.black54,
          borderRadius: BorderRadius.circular(48),
          border: Border.all(
            color: isRecording ? Colors.redAccent : Colors.white24,
            width: 2,
          ),
          boxShadow: isRecording
              ? [
                  BoxShadow(
                    color: Colors.redAccent.withOpacity(0.4),
                    blurRadius: 20,
                    spreadRadius: 2,
                  )
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _RecordingIndicator(
              active: isRecording,
              progress: progress,
              color: isRecording ? Colors.redAccent : onColor,
            ),
            const SizedBox(width: 16),
            Text(
              isRecording ? 'Tap to Stop' : 'Tap to Record',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isRecording ? Colors.redAccent : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecordingIndicator extends StatelessWidget {
  final bool active;
  final double progress;
  final Color color;

  const _RecordingIndicator({
    required this.active,
    required this.progress,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    const size = 24.0;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (active)
            CircularProgressIndicator(
              value: progress,
              strokeWidth: 3,
              color: color,
              backgroundColor: color.withOpacity(0.2),
            ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: active ? 10 : 12,
            height: active ? 10 : 12,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(active ? 2 : 10),
            ),
          ),
        ],
      ),
    );
  }
}
