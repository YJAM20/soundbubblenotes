import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/note_model.dart';
import '../providers/notes_provider.dart';
import '../widgets/bubble_widget.dart';

class ArchivedScreen extends StatelessWidget {
  const ArchivedScreen({super.key});

  void _showNoteActions(BuildContext context, SoundNote note) {
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
                leading: const Icon(Icons.unarchive),
                title: const Text('Unarchive'),
                onTap: () async {
                  Navigator.of(context).pop();
                  final updated = note.copyWith(archived: false);
                  await context.read<NotesProvider>().updateNote(updated);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: const Text('Delete permanently'),
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

  @override
  Widget build(BuildContext context) {
    // Use selector for better performance
    final notes =
        context.select<NotesProvider, List<SoundNote>>((p) => p.archivedNotes);

    if (notes.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.archive_outlined,
                size: 64, color: Colors.white.withValues(alpha: 0.2)),
            const SizedBox(height: 16),
            Text(
              'No archived notes.',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Dismissible(
            key: ValueKey(note.id),
            direction: DismissDirection.endToStart,
            confirmDismiss: (direction) async {
              // Optional: add confirmation dialog here
              return true;
            },
            onDismissed: (_) async {
              await context.read<NotesProvider>().deleteNote(note);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Note deleted permanently')),
                );
              }
            },
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.delete_outline, color: Colors.white),
            ),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white10),
              ),
              child: ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                leading: SizedBox(
                  width: 48,
                  height: 48,
                  child: BubbleWidget(note: note),
                ),
                title: Text(
                  note.displayLabel,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  '${note.durationSeconds.toStringAsFixed(1)}s • ${_formatDate(note.createdAt)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.more_vert),
                  onPressed: () => _showNoteActions(context, note),
                ),
                onTap: () => context.read<NotesProvider>().playNote(note),
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }
}
