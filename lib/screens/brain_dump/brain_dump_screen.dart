import 'package:flutter/material.dart';
import '../../core/services/storage_service.dart';
import '../../core/models/models.dart';
import '../../core/constants/app_constants.dart';
import '../../widgets/glass_card.dart';

class BrainDumpScreen extends StatefulWidget {
  final StorageService storage;

  const BrainDumpScreen({
    super.key,
    required this.storage,
  });

  @override
  State<BrainDumpScreen> createState() => _BrainDumpScreenState();
}

class _BrainDumpScreenState extends State<BrainDumpScreen> {
  final TextEditingController _thoughtController = TextEditingController();
  List<ThoughtEntry> _thoughts = [];

  @override
  void initState() {
    super.initState();
    _loadThoughts();
  }

  void _loadThoughts() {
    setState(() {
      _thoughts = widget.storage.getThoughts();
    });
  }

  @override
  void dispose() {
    _thoughtController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Overthinking Dump Zone'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Description
              GlassCard(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Icon(Icons.psychology, size: 48, color: Colors.purple),
                      const SizedBox(height: 12),
                      Text(
                        'Clear Your Mental RAM',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Write down intrusive thoughts. They\'ll be locked here until your break.',
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Input area
              GlassCard(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(
                        controller: _thoughtController,
                        maxLength: AppConstants.maxThoughtLength,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: 'What\'s on your mind?',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: _addThought,
                        icon: const Icon(Icons.lock),
                        label: const Text('Lock Thought'),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Saved thoughts
              Text(
                'Locked Thoughts',
                style: Theme.of(context).textTheme.headlineMedium,
              ),

              const SizedBox(height: 12),

              Expanded(
                child: _thoughts.isEmpty
                    ? Center(
                        child: Text(
                          'No thoughts dumped yet',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      )
                    : ListView.builder(
                        itemCount: _thoughts.length,
                        itemBuilder: (context, index) {
                          final thought = _thoughts[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _buildThoughtCard(thought),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThoughtCard(ThoughtEntry thought) {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  thought.isLocked ? Icons.lock : Icons.lock_open,
                  size: 16,
                  color: thought.isLocked ? Colors.orange : Colors.grey,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _formatTime(thought.timestamp),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, size: 20),
                  onPressed: () => _deleteThought(thought),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              thought.thought,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  void _addThought() {
    final text = _thoughtController.text.trim();
    if (text.isEmpty) return;

    final thought = ThoughtEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      thought: text,
      timestamp: DateTime.now(),
      isLocked: true,
    );

    widget.storage.addThought(thought);
    _thoughtController.clear();
    _loadThoughts();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Thought locked. Focus on your work now.'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _deleteThought(ThoughtEntry thought) {
    setState(() {
      _thoughts.removeWhere((t) => t.id == thought.id);
    });
    widget.storage.saveThoughts(_thoughts);
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}

