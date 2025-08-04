import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  final String userId = "HiHgtVpIvdyCZVtiFCOc"; // TODO: Firebase Auth 연동 시 교체
  bool isLoading = true;

  int totalCompleted = 0;
  int streakDays = 0;
  double weeklyAchievementRate = 0;
  int visitedDays = 0;
  Map<String, double> weeklyData = {};

  // 날짜를 '자정 00:00:00'으로 맞추는 함수
  DateTime onlyDate(DateTime d) => DateTime(d.year, d.month, d.day);

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadStatistics(); // 페이지 다시 올 때마다 최신 데이터 로드
  }

  Future<void> _loadStatistics() async {
    final logsRef = FirebaseFirestore.instance
        .collection('Users')
        .doc(userId)
        .collection('log');

    final logsSnap = await logsRef.get();
    if (logsSnap.docs.isEmpty) {
      setState(() => isLoading = false);
      return;
    }

    // 오늘 날짜 / 이번 주 시작 날짜 계산
    final today = onlyDate(DateTime.now());
    final weekStart = onlyDate(today.subtract(Duration(days: today.weekday - 1)));
    final weekEnd = onlyDate(weekStart.add(const Duration(days: 6)));

    int completedSum = 0;
    int visitedCount = 0;
    int weekCompleted = 0;
    int weekTotal = 0;

    // streak 계산용
    List<DateTime> submittedDates = [];

    for (var doc in logsSnap.docs) {
      final data = doc.data();
      final date = onlyDate(DateFormat('yyyy-MM-dd').parse(doc.id));

      final completed = (data['completedCount'] ?? 0) as int;
      final total = (data['totalTasks'] ?? 0) as int;
      final visited = (data['visited'] ?? false) as bool;
      final submitted = (data['submitted'] ?? false) as bool;

      // 총 완료
      completedSum += completed;
      // 접속일
      if (visited) visitedCount++;
      // 주간 데이터
      if (!date.isBefore(weekStart) && !date.isAfter(weekEnd)) {
        weekCompleted += completed;
        weekTotal += total;
      }
      // streak용
      if (submitted) {
        submittedDates.add(date);
      }
    }

    // streak 계산
    submittedDates.sort((a, b) => b.compareTo(a)); // 최신순
    int streak = 0;
    DateTime current = today;
    for (var d in submittedDates) {
      if (d.isAtSameMomentAs(current)) {
        streak++;
        current = current.subtract(const Duration(days: 1));
      } else if (d.isBefore(current)) {
        break;
      }
    }

    // PieChart 데이터 (주간별 완료 수)
    Map<String, double> weekData = {};
    for (var doc in logsSnap.docs) {
      final data = doc.data();
      final date = onlyDate(DateFormat('yyyy-MM-dd').parse(doc.id));
      final weekStart = onlyDate(date.subtract(Duration(days: date.weekday - 1)));
      final weekEnd = onlyDate(weekStart.add(const Duration(days: 6)));
      final weekKey =
          "${DateFormat('M/d').format(weekStart)}~${DateFormat('M/d').format(weekEnd)}";
      weekData[weekKey] = (weekData[weekKey] ?? 0) + (data['completedCount'] ?? 0);
    }

    setState(() {
      totalCompleted = completedSum;
      visitedDays = visitedCount;
      streakDays = streak;
      weeklyAchievementRate = weekTotal == 0 ? 0 : (weekCompleted / weekTotal * 100);
      weeklyData = weekData;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('통계'),
        centerTitle: true,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                StatCard(title: '총 완료 수', value: '$totalCompleted'),
                StatCard(title: '연속 달성일수', value: '$streakDays'),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                StatCard(title: '주간 달성률', value: '${weeklyAchievementRate.toStringAsFixed(1)}%'),
                StatCard(title: '접속 일수', value: '$visitedDays'),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Card(
                color: Theme.of(context).cardColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("가장 바빴던 주", style: Theme.of(context).textTheme.bodyLarge),
                      const SizedBox(height: 8),
                      Expanded(
                        child: PieChart(
                          dataMap: weeklyData.isEmpty ? {"데이터 없음": 1} : weeklyData,
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
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text(title, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 8),
            Text(value, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
