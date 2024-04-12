import 'package:cultyvate/utils/styles.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

late String durationType;
late String scheduleType;
late Map<String, int> irrigationData1;
double maxValue = 0;

class _BarChart extends StatelessWidget {
  const _BarChart({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        barTouchData: barTouchData,
        titlesData: titlesData,
        borderData: borderData,
        barGroups: barGroups,
        gridData: FlGridData(
            show: false, drawHorizontalLine: true, drawVerticalLine: false),
        alignment: BarChartAlignment.spaceAround,
        maxY: maxValue.toDouble(),
      ),
    );
  }

  BarTouchData get barTouchData => BarTouchData(
        enabled: false,
        touchTooltipData: BarTouchTooltipData(
          tooltipBgColor: Colors.transparent,
          tooltipPadding: const EdgeInsets.all(0),
          tooltipMargin: 8,
          getTooltipItem: (
            BarChartGroupData group,
            int groupIndex,
            BarChartRodData rod,
            int rodIndex,
          ) {
            return BarTooltipItem(
              rod.toY.round().toString(),
              const TextStyle(
                color: cultBlack,
                fontSize: footerFont,
              ),
            );
          },
        ),
      );

  Widget getTitles(double value, TitleMeta meta) {
    const style = TextStyle(color: cultGrey, fontSize: footerFont, fontWeight: FontWeight.bold,);
    print("value is demo :${value}");
    // DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(int.tryParse(value.toInt().toString()) ?? 0);
       print('date and time ${value}');
    String text = '';
    if (durationType == 'W') {
      int? weekday =int.tryParse(value.toInt().toString());
      switch (weekday?.toInt()) {
        case 0:
          text = 'Mon';
          break;
        case 1:
          text = 'Tue';
          break;
        case 2:
          text = 'Wed';
          break;
        case 3:
          text = 'Thu';
          break;
        case 4:
          text = 'Fri';
          break;
        case 5:
          text = 'Sat';
          break;
        case 6:
          text = 'Sun';
          break;
        default:
          text = '';
          break;
      }
    }
    else if (durationType == 'Y') {
      // DateTime dateTime = DateTime.parse(value.toString()); // Parse the date string
      print("date of month ${value}");
      int month = (value.toInt()+1);
      switch (month) {
        case 1:
          text = 'J';
          break;
        case 2:
          text = 'F';
          break;
        case 3:
          text = 'M';
          break;
        case 4:
          text = 'A';
          break;
        case 5:
          text = 'M';
          break;
        case 6:
          text = 'J';
          break;
        case 7:
          text = 'J';
          break;
        case 8:
          text = 'A';
          break;
        case 9:
          text = 'S';
          break;
        case 10:
          text = 'O';
          break;
        case 11:
          text = 'N';
          break;
        case 12:
          text = 'D';
          break;
        default:
          text = '';
          break;
      }
    }
    else if (durationType == 'M') {
      print("manoj title ${value}");
      text =' ${(value.toInt()+1).toString()} week';
    }
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 4.0,
      child: Text(text, style: style),
    );
  }

  FlTitlesData get titlesData => FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            getTitlesWidget: getTitles,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: false,
            reservedSize: 30,
          ),
        ),
        topTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        rightTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      );

  FlBorderData get borderData => FlBorderData(
        show: false,
      );

  final _barsGradient = const LinearGradient(
    colors: [
      Colors.greenAccent,
      cultGreen,
    ],
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
  );

  List<BarChartGroupData> get barGroups {
    List<BarChartGroupData> chartData = [];
    int i = 0;
    irrigationData1.forEach((key, value) {
      BarChartGroupData barChartGroupData = BarChartGroupData(
        x: int.tryParse(key) ?? i,
        barRods: [
          BarChartRodData(
            toY: value + 0,
            gradient: _barsGradient,
          )
        ],
        showingTooltipIndicators: [0],
      );
      chartData.add(barChartGroupData);
      i++;
    });
    return chartData;
  }
}

class WaterflowChart extends StatefulWidget {
  const WaterflowChart(
      {required this.durationType,
      required this.irrigationData,
      required this.scheduleType,
      Key? key})
      : super(key: key);
  final Map<String, int> irrigationData;
  final String durationType;
  final String scheduleType;

  @override
  State<StatefulWidget> createState() => WaterflowChartState();
}

class WaterflowChartState extends State<WaterflowChart> {
  @override
  void initState() {
    maxValue = 0;
    super.initState();
    durationType = widget.durationType;
    scheduleType = widget.scheduleType;
    irrigationData1 = widget.irrigationData;

    // Find the maximum value in irrigationData1
    maxValue = irrigationData1.values.reduce((max, value) {
      print("max: $max, value: $value");
      return max > value ? max : value;
    }).toDouble();

    print("maxValue before multiplication: $maxValue");

    // You may not need to multiply maxValue by 1.2 if it's already an int
    maxValue *= 1.2;

    print("maxValue after multiplication: $maxValue");
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.7,
      child: Card(
        elevation: 10.h,
        color: Colors.white,
        child: const _BarChart(),
      ),
    );
  }
}
// import 'package:cultyvate/utils/styles.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:fl_chart/fl_chart.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
//
// late String durationType;
// late String scheduleType;
// late Map<String, int> irrigationData1;
// double maxValue = 0;
//
// class _BarChart extends StatelessWidget {
//   const _BarChart({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return BarChart(
//       BarChartData(
//         barTouchData: barTouchData,
//         titlesData: titlesData,
//         borderData: borderData,
//         barGroups: barGroups,
//         gridData: FlGridData(
//           show: false,
//           drawHorizontalLine: true,
//           drawVerticalLine: false,
//         ),
//         alignment: BarChartAlignment.spaceAround,
//         maxY: maxValue,
//       ),
//     );
//   }
//
//   BarTouchData get barTouchData => BarTouchData(
//     enabled: false,
//     touchTooltipData: BarTouchTooltipData(
//       tooltipBgColor: Colors.transparent,
//       tooltipPadding: const EdgeInsets.all(0),
//       tooltipMargin: 8,
//       getTooltipItem: (
//           BarChartGroupData group,
//           int groupIndex,
//           BarChartRodData rod,
//           int rodIndex,
//           ) {
//         return BarTooltipItem(
//           rod.toY.round().toString(),
//           const TextStyle(
//             color: cultBlack,
//             fontSize: footerFont,
//           ),
//         );
//       },
//     ),
//   );
//
//   Widget getTitles(double value, TitleMeta meta) {
//     const style = TextStyle(
//       color: cultGrey,
//       fontSize: footerFont,
//       fontWeight: FontWeight.bold,
//     );
//
//     String text = '';
//     if (durationType == 'W') {
//       DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(value.toInt() * 1000);
//       text = DateFormat('EEE').format(dateTime);
//       // switch (dateTime.weekday) {
//       //   case 0:
//       //     text = 'Sun';
//       //     break;
//       //   case 1:
//       //     text = 'Mon';
//       //     break;
//       //   case 2:
//       //     text = 'Tue';
//       //     break;
//       //   case 3:
//       //     text = 'Wed';
//       //     break;
//       //   case 4:
//       //     text = 'Thu';
//       //     break;
//       //   case 5:
//       //     text = 'Fri';
//       //     break;
//       //   case 6:
//       //     text = 'Sat';
//       //     break;
//       //   default:
//       //     text = '';
//       //     break;
//       // }
//     } else if (durationType == 'Y') {
//       // ... Your existing code for 'Y' duration
//     } else if (durationType == 'M') {
//       text = 'Week ${(value.toInt() + 1)}';
//     }
//     return SideTitleWidget(
//       axisSide: meta.axisSide,
//       space: 4.0,
//       child: Text(text, style: style),
//     );
//   }
//
//   FlTitlesData get titlesData => FlTitlesData(
//     show: true,
//     bottomTitles: AxisTitles(
//       sideTitles: SideTitles(
//         showTitles: true,
//         reservedSize: 30,
//         getTitlesWidget: getTitles,
//       ),
//     ),
//     leftTitles: AxisTitles(
//       sideTitles: SideTitles(
//         showTitles: false,
//         reservedSize: 30,
//       ),
//     ),
//     topTitles: AxisTitles(
//       sideTitles: SideTitles(showTitles: false),
//     ),
//     rightTitles: AxisTitles(
//       sideTitles: SideTitles(showTitles: false),
//     ),
//   );
//
//   FlBorderData get borderData => FlBorderData(
//     show: false,
//   );
//
//   final _barsGradient = const LinearGradient(
//     colors: [
//       Colors.greenAccent,
//       cultGreen,
//     ],
//     begin: Alignment.bottomCenter,
//     end: Alignment.topCenter,
//   );
//
//   List<BarChartGroupData> get barGroups {
//     List<BarChartGroupData> chartData = [];
//     int i = 0;
//     irrigationData1.forEach((key, value) {
//       BarChartGroupData barChartGroupData = BarChartGroupData(
//         x: int.tryParse(key) ?? i,
//         barRods: [
//           BarChartRodData(
//             toY: value + 0,
//             gradient: _barsGradient,
//           )
//         ],
//         showingTooltipIndicators: [0],
//       );
//       chartData.add(barChartGroupData);
//       i++;
//     });
//     return chartData;
//   }
// }
//
// class WaterflowChart extends StatefulWidget {
//   const WaterflowChart({
//     required this.durationType,
//     required this.irrigationData,
//     required this.scheduleType,
//     Key? key,
//   }) : super(key: key);
//
//   final Map<String, int> irrigationData;
//   final String durationType;
//   final String scheduleType;
//
//   @override
//   State<StatefulWidget> createState() => WaterflowChartState();
// }
//
// class WaterflowChartState extends State<WaterflowChart> {
//   @override
//   void initState() {
//     maxValue = 0;
//     super.initState();
//     durationType = widget.durationType;
//     scheduleType = widget.scheduleType;
//     irrigationData1 = filterDataByCurrentWeek(widget.irrigationData);
//
//     irrigationData1.forEach((key, value) {
//       print("manoj ${key}");
//       if (value > maxValue) maxValue = value + 0;
//     });
//
//     maxValue *= 1.2;
//   }
//
//   Map<String, int> filterDataByCurrentWeek(Map<String, int> originalData) {
//     DateTime now = DateTime.now();
//     DateTime startOfWeek = now.subtract(Duration(days: now.weekday - 1));
//     DateTime endOfWeek = startOfWeek.add(Duration(days: 6));
//
//
//     return originalData.entries
//         .where((entry) {
//
//       DateTime dateTime = DateFormat('yyyy-MM-dd').parse(entry.key);
//       return dateTime.isAfter(startOfWeek) && dateTime.isBefore(endOfWeek);
//     })
//         .fold({}, (Map<String, int> filteredData, entry) {
//       filteredData[entry.key] = entry.value;
//       return filteredData;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return AspectRatio(
//       aspectRatio: 1.7,
//       child: Card(
//         elevation: 10.h,
//         color: Colors.white,
//         child: const _BarChart(),
//       ),
//     );
//   }
// }
