import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../models/user_settings.dart';
import '../utils/constants.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _targetController = TextEditingController();
  bool _notificationsEnabled = true;
  int _reminderInterval = 60;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() {
    final settings = context.read<SettingsProvider>().settings;
    _targetController.text = settings.dailyTarget.toInt().toString();
    _notificationsEnabled = settings.notificationsEnabled;
    _reminderInterval = settings.reminderInterval;
  }

  @override
  void dispose() {
    _targetController.dispose();
    super.dispose();
  }

  Future<void> _saveSettings() async {
    final target = double.tryParse(_targetController.text) ?? 2000.0;

    final newSettings = UserSettings(
      dailyTarget: target,
      notificationsEnabled: _notificationsEnabled,
      reminderInterval: _reminderInterval,
    );

    await context.read<SettingsProvider>().updateSettings(newSettings);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pengaturan berhasil disimpan!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Target Harian
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Target Harian',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _targetController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Target (ml)',
                      border: OutlineInputBorder(),
                      suffixText: 'ml',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Rekomendasi: ${AppConstants.defaultTarget.toInt()} ml/hari',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Notifikasi
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Notifikasi',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),

                  SwitchListTile(
                    title: const Text('Aktifkan Pengingat'),
                    subtitle: const Text('Ingatkan saya untuk minum air'),
                    value: _notificationsEnabled,
                    onChanged: (value) {
                      setState(() => _notificationsEnabled = value);
                    },
                  ),

                  if (_notificationsEnabled) ...[
                    const Divider(),
                    ListTile(
                      title: const Text('Interval Pengingat'),
                      subtitle: Text('Setiap $_reminderInterval menit'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () async {
                        final result = await showDialog<int>(
                          context: context,
                          builder: (context) =>
                              _IntervalDialog(initialValue: _reminderInterval),
                        );

                        if (result != null) {
                          setState(() => _reminderInterval = result);
                        }
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Tentang Aplikasi
          Card(
            child: ListTile(
              leading: const Icon(Icons.info),
              title: const Text('Tentang'),
              subtitle: Text(
                '${AppConstants.appName} v${AppConstants.appVersion}',
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Save button
          ElevatedButton(
            onPressed: _saveSettings,
            style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
            child: const Text('Simpan Pengaturan'),
          ),
        ],
      ),
    );
  }
}

// Dialog for selecting interval
class _IntervalDialog extends StatefulWidget {
  final int initialValue;

  const _IntervalDialog({required this.initialValue});

  @override
  State<_IntervalDialog> createState() => _IntervalDialogState();
}

class _IntervalDialogState extends State<_IntervalDialog> {
  late int _selectedInterval;
  final List<int> _intervals = [15, 30, 45, 60, 90, 120];

  @override
  void initState() {
    super.initState();
    _selectedInterval = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Pilih Interval'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: _intervals.map((interval) {
          return RadioListTile<int>(
            title: Text('$interval menit'),
            value: interval,
            groupValue: _selectedInterval,
            onChanged: (value) {
              setState(() => _selectedInterval = value!);
            },
          );
        }).toList(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, _selectedInterval),
          child: const Text('OK'),
        ),
      ],
    );
  }
}
