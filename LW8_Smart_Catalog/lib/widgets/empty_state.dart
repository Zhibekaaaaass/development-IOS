import 'package:flutter/material.dart';

class EmptyState extends StatelessWidget {
  final VoidCallback onReset;

  const EmptyState({super.key, required this.onReset});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inbox_outlined, size: 96, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          const Text(
            'Catalog is Empty',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onReset,
            icon: const Icon(Icons.restore),
            label: const Text('Reset Catalog'),
          ),
        ],
      ),
    );
  }
}
