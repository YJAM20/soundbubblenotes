import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

/// Handles recording and playback using `record` (v6+) and `just_audio`.
class AudioService {
  // Singleton pattern for service access if not using DI
  // But since we'll use Provider, we just keep it a clean class.
  
  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _player = AudioPlayer();

  Directory? _notesDir;
  String? _currentRecordingPath;

  Future<void> init() async {
    if (_notesDir != null) return; // Already initialized
    
    try {
      final docs = await getApplicationDocumentsDirectory();
      _notesDir = Directory('${docs.path}/sound_bubble_notes');
      if (!(await _notesDir!.exists())) {
        await _notesDir!.create(recursive: true);
      }
    } catch (e) {
      debugPrint('AudioService: Initialization failed: $e');
    }
  }

  Future<bool> checkPermission() async {
    return await _recorder.hasPermission();
  }

  Future<bool> startRecording() async {
    if (!await checkPermission()) return false;
    
    await init();
    if (_notesDir == null) return false;

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final path = '${_notesDir!.path}/note_$timestamp.m4a';
    _currentRecordingPath = path;

    try {
      // Stop playback if any before recording
      if (_player.playing) {
        await _player.stop();
      }

      const config = RecordConfig(
        encoder: AudioEncoder.aacLc,
        bitRate: 128000,
        sampleRate: 44100,
      );

      await _recorder.start(config, path: path);
      return true;
    } catch (e) {
      debugPrint('AudioService: Start recording failed: $e');
      return false;
    }
  }

  Future<String?> stopRecording() async {
    try {
      if (!await _recorder.isRecording()) return null;
      
      final path = await _recorder.stop();
      return path ?? _currentRecordingPath;
    } catch (e) {
      debugPrint('AudioService: Stop recording failed: $e');
      return null;
    }
  }

  Future<void> play(String filePath) async {
    try {
      // If we are already playing this file, maybe toggle pause/play?
      // For now, just restart it or play new one.
      if (_player.playing) {
        await _player.stop();
      }
      await _player.setFilePath(filePath);
      await _player.play();
    } catch (e) {
      debugPrint('AudioService: Playback failed: $e');
    }
  }

  Future<void> stopPlayback() async {
    try {
      await _player.stop();
    } catch (e) {
      debugPrint('AudioService: Stop playback failed: $e');
    }
  }

  Future<bool> deleteFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('AudioService: Delete file failed: $e');
      return false;
    }
  }

  Future<void> dispose() async {
    await _player.dispose();
    await _recorder.dispose();
  }
}
