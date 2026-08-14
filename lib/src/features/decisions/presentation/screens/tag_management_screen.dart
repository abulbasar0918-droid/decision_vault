import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/decision_provider.dart';

class TagManagementScreen extends StatefulWidget {
  const TagManagementScreen({super.key});

  @override
  State<TagManagementScreen> createState() => _TagManagementScreenState();
}

class _TagManagementScreenState extends State<TagManagementScreen> {
  @override
  Widget build(BuildContext context) {
    final decisionProvider = context.watch<DecisionProvider>();
    final tags = decisionProvider.tags;

    return Scaffold(
      appBar: AppBar(title: const Text('Tags')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: tags.length,
        itemBuilder: (context, index) {
          final tag = tags[index];
          return ListTile(
            title: Text(tag),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () async {
                    final provider = context.read<DecisionProvider>();
                    final newName = await showDialog<String>(
                      context: context,
                      builder: (ctx) {
                        final controller = TextEditingController(text: tag);
                        return AlertDialog(
                          title: const Text('Rename tag'),
                          content: TextField(controller: controller, decoration: const InputDecoration(labelText: 'Name')),
                          actions: [
                            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
                            ElevatedButton(onPressed: () => Navigator.of(ctx).pop(controller.text.trim()), child: const Text('Save')),
                          ],
                        );
                      },
                    );

                    if (newName != null && mounted) {
                      await provider.renameTag(tag, newName);
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () async {
                    final provider = context.read<DecisionProvider>();
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Delete tag'),
                        content: const Text('This will remove the tag from all decisions.'),
                        actions: [
                          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
                          ElevatedButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Delete')),
                        ],
                      ),
                    );
                    if (confirmed == true && mounted) {
                      await provider.deleteTag(tag);
                    }
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
