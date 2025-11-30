import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/note_model.dart';

class StorageService {
  static const String _notesKey = 'sound_bubble_notes_v1';
  
  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<List<SoundNote>> loadNotes() async {
    if (_prefs == null) await init();
    
    try {
      final rawList = _prefs!.getStringList(_notesKey) ?? [];
      // Heavy parsing offloaded to background isolate to prevent UI jank on startup
      return await compute(_parseNotes, rawList);
    } catch (e) {
      debugPrint('StorageService: load failed: $e');
      return [];
    }
  }

  Future<void> saveNotes(List<SoundNote> notes) async {
    if (_prefs == null) await init();
    
    try {
      // Encoding large lists can frame-drop, so we assume potential growth and offload it
      final rawList = await compute(_encodeNotes, notes);
      await _prefs!.setStringList(_notesKey, rawList);
    } catch (e) {
      debugPrint('StorageService: save failed: $e');
    }
  }
}

// Top-level functions required for compute (isolates)

List<SoundNote> _parseNotes(List<String> rawList) {
  return rawList.map((raw) {
    try {
      return SoundNote.fromJson(json.decode(raw));
    } catch (e) {
      return null;
    }
  }).whereType<SoundNote>().toList();
}

List<String> _encodeNotes(List<SoundNote> notes) {
  return notes.map((n) => json.encode(n.toJson())).toList();
}
