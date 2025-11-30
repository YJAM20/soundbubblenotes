import 'dart:math';
import 'dart:ui';

class SoundNote {
  final String id;
  final String filePath;
  final double durationSeconds;
  final DateTime createdAt;
  final bool archived;
  final String? label;
  final int colorValue;

  const SoundNote({
    required this.id,
    required this.filePath,
    required this.durationSeconds,
    required this.createdAt,
    required this.archived,
    required this.colorValue,
    this.label,
  });

  Color get color => Color(colorValue);

  String get displayLabel => label ?? _formatTimestamp(createdAt);
  
  Duration get duration => Duration(milliseconds: (durationSeconds * 1000).round());

  SoundNote copyWith({
    String? id,
    String? filePath,
    double? durationSeconds,
    DateTime? createdAt,
    bool? archived,
    String? label,
    int? colorValue,
  }) {
    return SoundNote(
      id: id ?? this.id,
      filePath: filePath ?? this.filePath,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      createdAt: createdAt ?? this.createdAt,
      archived: archived ?? this.archived,
      label: label ?? this.label,
      colorValue: colorValue ?? this.colorValue,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'filePath': filePath,
      'durationSeconds': durationSeconds,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'archived': archived,
      'label': label,
      'colorValue': colorValue,
    };
  }

  factory SoundNote.fromJson(Map<String, dynamic> json) {
    return SoundNote(
      id: json['id'] as String,
      filePath: json['filePath'] as String,
      durationSeconds: (json['durationSeconds'] as num).toDouble(),
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int),
      archived: json['archived'] as bool? ?? false,
      label: json['label'] as String?,
      colorValue: json['colorValue'] as int,
    );
  }

  static String generateId() {
    final millis = DateTime.now().millisecondsSinceEpoch;
    final rand = Random().nextInt(99999);
    return 'note_${millis}_$rand';
  }

  static String _formatTimestamp(DateTime dt) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final h = twoDigits(dt.hour);
    final m = twoDigits(dt.minute);
    return '$h:$m';
  }
}
