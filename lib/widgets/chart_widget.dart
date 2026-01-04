import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
// Removed: import '../utils/helpers.dart'; ← FIXED: Unused import

class ChartWidget extends StatelessWidget {
  final Map<DateTime, double> data;
  final double target;

  const ChartWidget({
    super.key, // ← FIXED: use super parameter
    required this.data,
    required this.target,
  });

  @override
  Widget build(BuildContext context) {
    // Prepare data for chart (last 7 days)
    final now = DateTime.now();
    final List<FlSpot> spots = [];

    for (int i = 6; i >= 0; i--) {
      final date = DateTime(now.year, now.month, now.day - i);
      final amount = data[date] ?? 0;
      spots.add(FlSpot(6 - i.toDouble(), amount));
    }

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Grafik 7 Hari Terakhir',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 24),

            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text('${value.toInt()}');
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final date = DateTime(
                            now.year,
                            now.month,
                            now.day - (6 - value.toInt()),
                          );
                          return Text(
                            '${date.day}',
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 3,
                      dotData: FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.blue.withValues(
                          alpha: 0.3,
                        ), // ← FIXED: withOpacity
                      ),
                    ),
                  ],
                  extraLinesData: ExtraLinesData(
                    horizontalLines: [
                      HorizontalLine(
                        y: target,
                        color: Colors.green,
                        strokeWidth: 2,
                        dashArray: [5, 5],
                        label: HorizontalLineLabel(
                          show: true,
                          labelResolver: (line) => 'Target',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Legend
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegend(Colors.blue, 'Konsumsi'),
                const SizedBox(width: 16),
                _buildLegend(Colors.green, 'Target'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend(Color color, String label) {
    return Row(
      children: [
        Container(width: 16, height: 16, color: color),
        const SizedBox(width: 4),
        Text(label),
      ],
    );
  }
}
