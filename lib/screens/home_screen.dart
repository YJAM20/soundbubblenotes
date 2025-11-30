import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/note_model.dart';
import '../providers/notes_provider.dart';
import '../services/audio_service.dart';
import '../utils/app_colors.dart';
import '../widgets/bubble_widget.dart';
import '../widgets/record_button.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  static const Duration _maxDuration = Duration(seconds: 15);
  
  bool _isRecording = false;
  DateTime? _recordStart;
  Timer? _timer;
  double _recordProgress = 0.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Stop recording if app goes to background
    if (state == AppLifecycleState.paused || state == AppLifecycleState.detached) {
      if (_isRecording) {
        _stopRecording(save: false); // Discard if interrupted unexpectedly
      }
    }
  }

  Future<void> _startRecording() async {
    final audioService = context.read<AudioService>();
    
    // Stop playback to avoid feedback
    await audioService.stopPlayback();

    final started = await audioService.startRecording();
    if (!started) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Microphone permission is required.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    setState(() {
      _isRecording = true;
      _recordStart = DateTime.now();
      _recordProgress = 0.0;
    });

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (!_isRecording || _recordStart == null) return;
      
      final elapsed = DateTime.now().difference(_recordStart!);
      final t = (elapsed.inMilliseconds / _maxDuration.inMilliseconds)
          .clamp(0.0, 1.0);
      
      setState(() {
        _recordProgress = t;
      });

      if (elapsed >= _maxDuration) {
        _stopRecording(save: true);
      }
    });
  }

  Future<void> _stopRecording({bool save = true}) async {
    _timer?.cancel();
    if (!_isRecording) return; // Already stopped

    final start = _recordStart;
    final audioService = context.read<AudioService>();
    
    setState(() {
      _isRecording = false;
      _recordStart = null;
      _recordProgress = 0.0;
    });

    final path = await audioService.stopRecording();
    
    if (!save || path == null || start == null) {
      if (path != null) await audioService.deleteFile(path);
      return;
    }

    final elapsed = DateTime.now().difference(start);
    if (elapsed.inMilliseconds < 500) {
      await audioService.deleteFile(path);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Note too short, discarded.')),
        );
      }
      return;
    }

    final seconds = elapsed.inMilliseconds / 1000.0;
    final note = SoundNote(
      id: SoundNote.generateId(),
      filePath: path,
      durationSeconds: seconds,
      createdAt: DateTime.now(),
      archived: false,
      colorValue: pickRandomBubbleColor().value,
    );

    if (mounted) {
      context.read<NotesProvider>().addNote(note);
    }
  }

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      await _stopRecording(save: true);
    } else {
      await _startRecording();
    }
  }

  void _onBubbleTap(SoundNote note) {
    context.read<NotesProvider>().playNote(note);
  }

  Future<void> _onBubbleDismissed(DismissDirection direction, SoundNote note) async {
    final provider = context.read<NotesProvider>();
    
    if (direction == DismissDirection.startToEnd) {
      // Delete
      await provider.deleteNote(note);
      if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Note deleted')));
      }
    } else if (direction == DismissDirection.endToStart) {
      // Archive
      final updated = note.copyWith(archived: true);
      await provider.updateNote(updated);
       if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Note archived')));
      }
    }
  }

  void _showNoteActions(SoundNote note) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.play_arrow_rounded),
                title: const Text('Play'),
                onTap: () {
                  Navigator.of(context).pop();
                  context.read<NotesProvider>().playNote(note);
                },
              ),
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Rename'),
                onTap: () async {
                  Navigator.of(context).pop();
                  await _showRenameDialog(note);
                },
              ),
              ListTile(
                leading: const Icon(Icons.archive_outlined),
                title: const Text('Archive'),
                onTap: () async {
                  Navigator.of(context).pop();
                  final updated = note.copyWith(archived: true);
                  await context.read<NotesProvider>().updateNote(updated);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: const Text('Delete'),
                textColor: Theme.of(context).colorScheme.error,
                iconColor: Theme.of(context).colorScheme.error,
                onTap: () async {
                  Navigator.of(context).pop();
                  await context.read<NotesProvider>().deleteNote(note);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showRenameDialog(SoundNote note) async {
    final controller = TextEditingController(text: note.label ?? '');
    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Rename note'),
          content: TextField(
            controller: controller,
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
            maxLength: 20,
            decoration: const InputDecoration(
              hintText: 'Enter a short label',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(null),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(controller.text.trim()),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (result != null && mounted) {
      final updated = note.copyWith(label: result.isEmpty ? null : result);
      await context.read<NotesProvider>().updateNote(updated);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use selector to rebuild ONLY when activeNotes changes.
    // This prevents the entire screen from rebuilding unnecessarily.
    final notes = context.select<NotesProvider, List<SoundNote>>(
        (p) => p.activeNotes
    );

    if (notes.isEmpty) {
      return Stack(
        fit: StackFit.expand,
        children: [
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.mic_none_rounded, size: 48, color: Colors.white.withOpacity(0.3)),
                const SizedBox(height: 16),
                Text(
                  'Tap record to create a bubble',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
           Positioned(
            left: 0,
            right: 0,
            bottom: 32,
            child: Center(
                child: RecordButton(
                  isRecording: _isRecording,
                  progress: _recordProgress,
                  onTap: _toggleRecording,
                )
            ),
          ),
        ],
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 100, 16, 150),
          child: Center(
            child: Wrap(
              spacing: 20,
              runSpacing: 20,
              alignment: WrapAlignment.center,
              children: notes.map((note) {
                // Key is crucial for correct state preservation in lists
                return Dismissible(
                  key: ValueKey(note.id),
                  direction: DismissDirection.horizontal,
                  onDismissed: (direction) => _onBubbleDismissed(direction, note),
                  background: _buildDismissBackground(
                    alignment: Alignment.centerLeft,
                    icon: Icons.delete_outline,
                    color: Colors.red.withOpacity(0.8),
                  ),
                  secondaryBackground: _buildDismissBackground(
                    alignment: Alignment.centerRight,
                    icon: Icons.archive_outlined,
                    color: Colors.blueGrey.withOpacity(0.8),
                  ),
                  child: GestureDetector(
                    onTap: () => _onBubbleTap(note),
                    onLongPress: () => _showNoteActions(note),
                    child: BubbleWidget(note: note),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 32,
          child: Center(
              child: RecordButton(
                isRecording: _isRecording,
                progress: _recordProgress,
                onTap: _toggleRecording,
              )
          ),
        ),
      ],
    );
  }

  Widget _buildDismissBackground({
    required Alignment alignment,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Icon(icon, color: Colors.white, size: 28),
    );
  }
}
