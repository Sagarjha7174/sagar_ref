import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class ApplianceDistributionChart extends StatelessWidget {
  const ApplianceDistributionChart({
    super.key,
    required this.distribution,
  });

  final Map<String, int> distribution;

  static const _colors = {
    'AC': AppTheme.acColor,
    'Fridge': AppTheme.fridgeColor,
    'Washing Machine': AppTheme.washingMachineColor,
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final total = distribution.values.fold(0, (a, b) => a + b);

    if (total == 0) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: SizedBox(
            height: 200,
            child: Center(child: Text('No completed complaints yet')),
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Appliance Distribution',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: distribution.entries.map((entry) {
                    final color = _colors[entry.key] ?? Colors.grey;
                    final percentage = (entry.value / total * 100).toStringAsFixed(0);
                    return PieChartSectionData(
                      value: entry.value.toDouble(),
                      color: color,
                      title: '$percentage%',
                      titleStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                      radius: 80,
                    );
                  }).toList(),
                  sectionsSpace: 2,
                  centerSpaceRadius: 30,
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Legend
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: distribution.entries.map((entry) {
                final color = _colors[entry.key] ?? Colors.grey;
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${entry.key} (${entry.value})',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
