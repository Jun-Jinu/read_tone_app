import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:read_tone_app/domain/entities/book.dart';

class MonthlyChart extends StatelessWidget {
  final List<Book> completedBooks;

  const MonthlyChart({
    super.key,
    required this.completedBooks,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final monthlyData = List.generate(6, (index) {
      final month = now.month - index;
      final year = now.year - (month <= 0 ? 1 : 0);
      final adjustedMonth = month <= 0 ? month + 12 : month;

      return completedBooks.where((book) {
        final completionDate = book.completedAt;
        return completionDate != null &&
            completionDate.year == year &&
            completionDate.month == adjustedMonth;
      }).length;
    }).reversed.toList();

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: monthlyData.isEmpty
            ? 10
            : monthlyData.reduce((a, b) => a > b ? a : b).toDouble() + 2,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                '${rod.toY.toInt()}권',
                TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.bold,
                ),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final now = DateTime.now();
                final month = now.month - (5 - value.toInt());
                final year = now.year - (month <= 0 ? 1 : 0);
                final adjustedMonth = month <= 0 ? month + 12 : month;
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    '$adjustedMonth월',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
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
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 1,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
              strokeWidth: 1,
            );
          },
        ),
        barGroups: List.generate(
          6,
          (index) => BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: monthlyData[index].toDouble(),
                color: Theme.of(context).colorScheme.primary,
                width: 20,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(4),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
