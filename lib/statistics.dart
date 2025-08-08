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

  int totalCompleted = 0;              // ✅ stats/summary에서 읽음
  int streakDays = 0;                  // ✅ stats/summary에서 읽음
  double weeklyAchievementRate = 0;    // ✅ 최근 8주 로그로 계산
  int visitedDays = 0;                 // ✅ 최근 8주 로그로 계산
  Map<String, double> weeklyData = {}; // ✅ 최근 8주 로그로 계산

  // 날짜 헬퍼
  DateTime onlyDate(DateTime d) => DateTime(d.year, d.month, d.day);
  String ymd(DateTime d) => DateFormat('yyyy-MM-dd').format(d);

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  // didChangeDependencies()는 중복 호출 될 수 있어 제거

  Future<void> _loadStatistics() async {
    setState(() => isLoading = true);

    try {
      final userRef = FirebaseFirestore.instance.collection('Users').doc(userId);

      // 1) summary에서 핵심 값(총 완료 수, 스트릭) 먼저 로드
      final summaryRef = userRef.collection('stats').doc('summary');
      final summarySnap = await summaryRef.get();
      int sumTotal = 0;
      int sumStreak = 0;
      if (summarySnap.exists) {
        final data = summarySnap.data()!;
        sumTotal = (data['totalCompleted'] ?? 0) as int;
        sumStreak = (data['streakDays'] ?? 0) as int;
      }

      // 2) 최근 8주 로그만 로드해서 뷰 지표 계산
      final today = onlyDate(DateTime.now());
      final start = onlyDate(today.subtract(const Duration(days: 56)));
      final startStr = ymd(start);
      final endStr = ymd(today);

      // 문서 ID가 'YYYY-MM-DD' 형식이라는 전제
      final logsSnap = await userRef
          .collection('log')
          .orderBy(FieldPath.documentId)
          .startAt([startStr])
          .endAt([endStr])
          .get();

      int visitedCount = 0;
      int weekCompleted = 0, weekTotal = 0;
      Map<String, double> weekData = {};

      // 이번 주 범위
      final weekStart = onlyDate(today.subtract(Duration(days: today.weekday - 1)));
      final weekEnd = onlyDate(weekStart.add(const Duration(days: 6)));

      for (final doc in logsSnap.docs) {
        final data = doc.data();
        final date = onlyDate(DateFormat('yyyy-MM-dd').parse(doc.id));

        final completed = (data['completedCount'] ?? 0) as int;
        final total = (data['totalTasks'] ?? 0) as int;
        final visited = (data['visited'] ?? false) as bool;

        if (visited) visitedCount++;

        if (!date.isBefore(weekStart) && !date.isAfter(weekEnd)) {
          weekCompleted += completed;
          weekTotal += total;
        }

        // 파이차트용 주간 버킷
        final ws = onlyDate(date.subtract(Duration(days: date.weekday - 1)));
        final we = onlyDate(ws.add(const Duration(days: 6)));
        final key = "${DateFormat('M/d').format(ws)}~${DateFormat('M/d').format(we)}";
        weekData[key] = (weekData[key] ?? 0) + completed.toDouble();
      }

      if (!mounted) return;
      setState(() {
        // ✅ 요약값은 summary 우선
        totalCompleted = sumTotal;
        streakDays = sumStreak;

        // ✅ 최근 8주 기반 뷰 지표
        visitedDays = visitedCount;
        weeklyAchievementRate = weekTotal == 0 ? 0 : (weekCompleted / weekTotal * 100);
        weeklyData = weekData.isEmpty ? {"데이터 없음": 1} : weekData;

        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      
    }
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
                StatCard(
                  title: '주간 달성률',
                  value: '${weeklyAchievementRate.toStringAsFixed(1)}%',
                ),
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
                          dataMap: weeklyData,
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
            Text(
              value,
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
