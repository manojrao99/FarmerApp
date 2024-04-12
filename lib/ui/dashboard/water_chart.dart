import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class SimpleTimeSeriesChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        height: 300,
        width: 400,
        padding: EdgeInsets.all(16),
        child: LineChart(
          LineChartData(
            gridData: FlGridData(show: false),
            titlesData: FlTitlesData(show: false),
            borderData: FlBorderData(
              show: true,
              border: Border.all(
                color: const Color(0xff37434d),
                width: 1,
              ),
            ),
            minX: 0,
            maxX: 6,
            minY: 0,
            maxY: 150,
            lineBarsData: [
              LineChartBarData(
                spots: [
                  FlSpot(0, 25),
                  FlSpot(1, 40),
                  FlSpot(2, 35),
                  FlSpot(3, 69),
                  FlSpot(4, 105),
                  FlSpot(5, 120),
                  FlSpot(6, 110),
                ],
                isCurved: true,
                color: Colors.blue,
                dotData: FlDotData(show: false),
                belowBarData: BarAreaData(show: false),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
