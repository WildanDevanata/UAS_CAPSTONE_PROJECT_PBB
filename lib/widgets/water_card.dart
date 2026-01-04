import 'dart:io';
import 'package:flutter/material.dart';
import '../models/water_log.dart';
import '../utils/helpers.dart';

class WaterCard extends StatelessWidget {
  final WaterLog log;
  final VoidCallback? onDelete;

  const WaterCard({Key? key, required this.log, this.onDelete})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        // Photo preview
        leading: log.photoPath != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  File(log.photoPath!),
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
              )
            : const Icon(Icons.water_drop, size: 40, color: Colors.blue),

        // Amount
        title: Text(
          '${log.amount.toInt()} ml',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),

        // Time
        subtitle: Text(
          Helpers.formatTime(log.dateTime),
          style: TextStyle(color: Colors.grey[600]),
        ),

        // Delete button
        trailing: onDelete != null
            ? IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  // Confirm dialog
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Hapus Data'),
                      content: const Text('Yakin ingin menghapus data ini?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Batal'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            onDelete!();
                          },
                          child: const Text(
                            'Hapus',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              )
            : null,
      ),
    );
  }
}
