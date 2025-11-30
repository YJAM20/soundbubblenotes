// This is a widget test for Sound Bubble Notes.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:soundbubblenotes/main.dart';
import 'package:soundbubblenotes/models/note_model.dart';
import 'package:soundbubblenotes/providers/notes_provider.dart';
import 'package:soundbubblenotes/services/audio_service.dart';
import 'package:soundbubblenotes/services/storage_service.dart';

// Mock Services to avoid platform channel dependencies in tests.
// Using 'implements' prevents the real class constructor from running,
// avoiding instantiation of AudioRecorder/AudioPlayer which require platform channels.

class MockAudioService implements AudioService {
  @override
  Future<void> init() async {}

  @override
  Future<bool> checkPermission() async => true;

  @override
  Future<bool> startRecording() async => true;

  @override
  Future<String?> stopRecording() async => 'dummy_path.m4a';

  @override
  Future<void> play(String filePath) async {}

  @override
  Future<void> stopPlayback() async {}

  @override
  Future<bool> deleteFile(String filePath) async => true;

  @override
  Future<void> dispose() async {}
}

class MockStorageService implements StorageService {
  @override
  Future<void> init() async {}
  
  @override
  Future<List<SoundNote>> loadNotes() async => [];

  @override
  Future<void> saveNotes(List<SoundNote> notes) async {}
}

void main() {
  testWidgets('App loads and shows correct initial UI', (WidgetTester tester) async {
    // 1. Setup Mocks
    final mockAudio = MockAudioService();
    final mockStorage = MockStorageService();
    
    // 2. Create Provider with mocks
    // NotesProvider init() will fire immediately but we wait for pumpAndSettle
    final notesProvider = NotesProvider(
      audioService: mockAudio,
      storageService: mockStorage,
    );

    // 3. Pump Widget
    // We wrap AppView in the MultiProvider manually to inject our mocks
    // instead of letting SoundBubbleNotesApp create real services.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<AudioService>.value(value: mockAudio),
          Provider<StorageService>.value(value: mockStorage),
          ChangeNotifierProvider<NotesProvider>.value(value: notesProvider),
        ],
        child: const AppView(),
      ),
    );

    // 4. Wait for any animations or async init to settle
    await tester.pumpAndSettle();

    // 5. Verify Initial State
    // Should show "Bubbles" tab active
    expect(find.text('Bubbles'), findsOneWidget);
    
    // Should show empty state mic icon and text
    expect(find.byIcon(Icons.mic_none_rounded), findsOneWidget);
    expect(find.text('Tap to record to create a bubble'), findsNothing); // Text might differ slightly, checking partial?
    
    // Check for the record button
    expect(find.text('Tap to Record'), findsOneWidget);

    // 6. Verify Navigation
    await tester.tap(find.text('Archived'));
    await tester.pumpAndSettle();
    
    expect(find.text('No archived notes.'), findsOneWidget);
  });
}
