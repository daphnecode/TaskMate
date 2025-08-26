import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  bool isLoading = true;

  // 요약값(Users/{uid}/stats/summary)
  int totalCompleted = 0;
  int streakDays = 0;

  // 최근 4주 뷰 지표(Users/{uid}/log)
  double weeklyAchievementRate = 0; // 이번 주 달성률(%)
  int visitedDays = 0;              // 최근 8주 중 방문일수(참고)
  Map<String, double> weeklyData = {}; // 파이차트용(최근 4주만)

  // ── Time helpers (KST 기준)
  DateTime _kstNow() => DateTime.now().toUtc().add(const Duration(hours: 9));
  DateTime _onlyDate(DateTime d) => DateTime(d.year, d.month, d.day);
  String _ymd(DateTime d) => DateFormat('yyyy-MM-dd').format(d);

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    setState(() => isLoading = true);

    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) {
        // 로그인 전 접근 보호
        setState(() => isLoading = false);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('로그인 후 이용할 수 있습니다.')),
        );
        return;
      }

      final userRef = FirebaseFirestore.instance.collection('Users').doc(uid);

      // 1) summary(요약) 값 읽기: totalCompleted, streakDays
      final summarySnap =
      await userRef.collection('stats').doc('summary').get();
      int sumTotal = 0;
      int sumStreak = 0;
      if (summarySnap.exists) {
        final data = summarySnap.data()!;
        sumTotal = (data['totalCompleted'] ?? 0) as int;
        sumStreak = (data['streakDays'] ?? 0) as int;
      }

      // 2) 최근 8주 로그 로드 후 파생지표 계산
      final todayKST = _onlyDate(_kstNow());
      final start = _onlyDate(todayKST.subtract(const Duration(days: 56)));
      final startStr = _ymd(start);
      final endStr = _ymd(todayKST);

      final logsSnap = await userRef
          .collection('log')
          .orderBy(FieldPath.documentId)
          .startAt([startStr])
          .endAt([endStr])
          .get(const GetOptions(source: Source.server));

      int visitedCount = 0;
      int weekCompleted = 0, weekTotal = 0;
      final Map<String, double> weekData = {};

      // 이번 주 범위(Mon~Sun)
      final weekStart =
      _onlyDate(todayKST.subtract(Duration(days: todayKST.weekday - 1)));
      final weekEnd = _onlyDate(weekStart.add(const Duration(days: 6)));

      for (final doc in logsSnap.docs) {
        final data = doc.data();
        // 문서 id = 'YYYY-MM-DD'
        final date = _onlyDate(DateFormat('yyyy-MM-dd').parse(doc.id));

        final completed = (data['completedCount'] ?? 0) as int;
        final total = (data['totalTasks'] ?? 0) as int;
        final visited = (data['visited'] ?? false) as bool;

        if (visited) visitedCount++;

        // 이번 주 달성률 계산용
        if (!date.isBefore(weekStart) && !date.isAfter(weekEnd)) {
          weekCompleted += completed;
          weekTotal += total;
        }

        // 파이차트: 주간 버킷 누적
        final ws = _onlyDate(date.subtract(Duration(days: date.weekday - 1))); // Mon
        final we = _onlyDate(ws.add(const Duration(days: 6)));                 // Sun
        final key =
            "${DateFormat('M/d').format(ws)}~${DateFormat('M/d').format(we)}";
        weekData[key] = (weekData[key] ?? 0) + completed.toDouble();
      }

      // 🔹 파이차트에는 "최근 4주만" 남기기
      // key는 "M/d~M/d" 형식. 시작일 쪽(M/d)을 DateTime으로 변환해 정렬 후 최근 4개만 유지.
      DateTime _parseRangeStart(String k) =>
          DateFormat('M/d').parse(k.split('~').first);
      final sortedKeys = weekData.keys.toList()
        ..sort((a, b) => _parseRangeStart(a).compareTo(_parseRangeStart(b)));
      final last4Keys = sortedKeys.length > 4
          ? sortedKeys.sublist(sortedKeys.length - 4)
          : sortedKeys;
      final Map<String, double> filteredLast4 = {
        for (final k in last4Keys) k: weekData[k]!,
      };

      if (!mounted) return;
      setState(() {
        // summary 우선값
        totalCompleted = sumTotal;
        streakDays = sumStreak;

        // 최근 로그 기반 뷰 값
        visitedDays = visitedCount;
        weeklyAchievementRate =
        weekTotal == 0 ? 0 : (weekCompleted / weekTotal * 100);
        weeklyData = filteredLast4.isEmpty ? {"데이터 없음": 1} : filteredLast4;

        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('통계를 불러오지 못했습니다: $e')),
      );
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
                  title: '이번 주 달성률',
                  value: '${weeklyAchievementRate.toStringAsFixed(1)}%',
                ),
                StatCard(title: '접속 일수(최근 8주)', value: '$visitedDays'),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Card(
                color: Theme.of(context).cardColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("가장 바빴던 주(최근 4주)", // 제목 명확화
                          style: Theme.of(context).textTheme.bodyLarge),
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
                            decimalPlaces: 0,
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
