import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';

class StatisticsPage extends StatelessWidget {
  const StatisticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 파이차트 데이터 정의
    final Map<String, double> dataMap = {
      "3/3~3/9": 5,
      "3/10~3/16": 3,
      "3/17~3/23": 8,
      "3/24~3/30": 4,
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('통계'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 상단 카드들 (생략 가능)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                StatCard(title: '총 완료 수', value: '42'),
                StatCard(title: '연속 달성일수', value: '9'),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                StatCard(title: '주간 달성률', value: '85%'),
                StatCard(title: '접속 일수', value: '23'),
              ],
            ),
            const SizedBox(height: 20),

            // ✅ 파이차트 카드
            Expanded(
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("가장 바빴던 주", style: TextStyle(fontSize: 16)),
                      const SizedBox(height: 8),
                      Expanded(
                        child: PieChart(
                          dataMap: dataMap,
                          chartType: ChartType.disc,
                          chartLegendSpacing: 32,
                          baseChartColor: Colors.grey[200]!,
                          legendOptions: const LegendOptions(
                            showLegends: true,
                            legendPosition: LegendPosition.right,
                          ),
                          chartValuesOptions: const ChartValuesOptions(
                            showChartValues: true,
                            showChartValuesInPercentage: false,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 통계 카드 위젯 그대로 유지
class StatCard extends StatelessWidget {
  final String title;
  final String value;

  const StatCard({super.key, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(4),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text(title, style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
