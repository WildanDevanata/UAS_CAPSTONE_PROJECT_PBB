import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/water_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/chart_widget.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({Key? key}) : super(key: key);

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  Map<DateTime, double> _weeklyData = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final provider = context.read<WaterProvider>();
    final data = await provider.getWeeklyData();

    setState(() {
      _weeklyData = data;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Analitik')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Consumer<SettingsProvider>(
              builder: (context, settings, child) {
                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Chart
                    ChartWidget(
                      data: _weeklyData,
                      target: settings.settings.dailyTarget,
                    ),

                    const SizedBox(height: 24),

                    // Statistics cards
                    _buildStatCard(
                      context,
                      'Total Minggu Ini',
                      '${_calculateTotal()} ml',
                      Icons.water_drop,
                      Colors.blue,
                    ),

                    const SizedBox(height: 12),

                    _buildStatCard(
                      context,
                      'Rata-rata Harian',
                      '${_calculateAverage()} ml',
                      Icons.trending_up,
                      Colors.green,
                    ),

                    const SizedBox(height: 12),

                    _buildStatCard(
                      context,
                      'Hari Target Tercapai',
                      '${_countTargetDays(settings.settings.dailyTarget)}/7 hari',
                      Icons.check_circle,
                      Colors.orange,
                    ),
                  ],
                );
              },
            ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Icon(icon, color: color),
        ),
        title: Text(title),
        trailing: Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  int _calculateTotal() {
    return _weeklyData.values.fold(0, (sum, value) => sum + value.toInt());
  }

  int _calculateAverage() {
    if (_weeklyData.isEmpty) return 0;
    return (_calculateTotal() / 7).round();
  }

  int _countTargetDays(double target) {
    return _weeklyData.values.where((value) => value >= target).length;
  }
}
