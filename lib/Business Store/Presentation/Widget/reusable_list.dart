import 'package:flutter/material.dart';

class ReusableStepList extends StatelessWidget {
  final List<Map<String, String>> items;
  final IconData icon;
  final Function(int index) onDelete;

  const ReusableStepList({
    super.key,
    required this.items,
    required this.icon,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return items.isNotEmpty
        ? ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return Card(
                child: ListTile(
                  leading: Icon(icon, color: Colors.deepPurple),
                  title: Text(item['name'] ?? ''),
                  subtitle: Text(item['description'] ?? ''),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.deepPurple),
                    onPressed: () => onDelete(index),
                  ),
                ),
              );
            },
          )
        : const Text('No items added yet.');
  }
}
