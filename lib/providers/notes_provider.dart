import 'package:flutter/foundation.dart';
import '../models/note_model.dart';
import '../services/audio_service.dart';
import '../services/storage_service.dart';

/// Manages the state of notes (active and archived) and interacts with services.
/// Acts as the ViewModel for the application.
class NotesProvider extends ChangeNotifier {
  final StorageService _storageService;
  final AudioService _audioService;

  List<SoundNote> _notes = [];
  bool _isLoading = true;
  String? _error;

  NotesProvider({
    required StorageService storageService,
    required AudioService audioService,
  })  : _storageService = storageService,
        _audioService = audioService {
    _init();
  }

  List<SoundNote> get notes => List.unmodifiable(_notes);
  List<SoundNote> get activeNotes => _notes.where((n) => !n.archived).toList();
  List<SoundNote> get archivedNotes => _notes.where((n) => n.archived).toList();
  
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> _init() async {
    try {
      await _audioService.init();
      // Storage service init is lazy/implicit in some implementations, 
      // but if it has an init, call it. The current one has lazy init.
      // But let's ensure we load data.
      await loadNotes();
    } catch (e) {
      _error = 'Failed to initialize app: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadNotes() async {
    _isLoading = true;
    notifyListeners();

    try {
      _notes = await _storageService.loadNotes();
      _error = null;
    } catch (e) {
      _error = 'Failed to load notes';
      debugPrint(e.toString());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addNote(SoundNote note) async {
    _notes = [..._notes, note];
    notifyListeners(); // Optimistic update
    
    try {
      await _storageService.saveNotes(_notes);
    } catch (e) {
      _error = 'Failed to save note';
      // Revert if needed, or just notify error
      notifyListeners();
    }
  }

  Future<void> updateNote(SoundNote updatedNote) async {
    final index = _notes.indexWhere((n) => n.id == updatedNote.id);
    if (index == -1) return;

    final oldNote = _notes[index];
    _notes[index] = updatedNote;
    notifyListeners();

    try {
      await _storageService.saveNotes(_notes);
    } catch (e) {
      _notes[index] = oldNote; // Revert
      _error = 'Failed to update note';
      notifyListeners();
    }
  }

  Future<void> deleteNote(SoundNote note) async {
    final index = _notes.indexWhere((n) => n.id == note.id);
    if (index == -1) return;

    _notes.removeAt(index);
    notifyListeners();

    // Fire and forget file deletion, or await it if critical
    _audioService.deleteFile(note.filePath).then((_) {
      debugPrint('Deleted file: ${note.filePath}');
    });

    try {
      await _storageService.saveNotes(_notes);
    } catch (e) {
      _notes.insert(index, note); // Revert
      _error = 'Failed to delete note';
      notifyListeners();
    }
  }
  
  // Proxy audio methods to keep UI decoupled from AudioService directly if preferred,
  // or expose AudioService. For simple apps, exposing AudioService is fine, 
  // but let's wrap playing to handle UI state if we wanted to track "currently playing note".
  
  void playNote(SoundNote note) {
    _audioService.play(note.filePath);
  }
}
