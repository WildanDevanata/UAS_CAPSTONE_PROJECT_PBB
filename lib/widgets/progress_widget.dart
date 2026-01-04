import 'package:flutter/material.dart';
import '../utils/helpers.dart';

class ProgressWidget extends StatelessWidget {
  final double current;
  final double target;

  const ProgressWidget({Key? key, required this.current, required this.target})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final progress = Helpers.calculateProgress(current, target);
    final percentage = progress.toStringAsFixed(0);

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Progress Hari Ini',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),

            // Circular progress
            SizedBox(
              height: 120,
              width: 120,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CircularProgressIndicator(
                    value: progress / 100,
                    strokeWidth: 12,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      progress >= 100 ? Colors.green : Colors.blue,
                    ),
                  ),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$percentage%',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${current.toInt()}/${target.toInt()}ml',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Linear progress
            LinearProgressIndicator(
              value: progress / 100,
              minHeight: 8,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                progress >= 100 ? Colors.green : Colors.blue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
