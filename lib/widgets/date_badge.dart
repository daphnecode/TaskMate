import 'package:flutter/material.dart';

// 날짜 위젯
class DateBadge extends StatelessWidget {
  const DateBadge({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final String formatted = '${now.year}년 ${now.month}월 ${now.day}일';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black26),
      ),
      child: Text(
        formatted,
        style: const TextStyle(color: Colors.blue, fontSize: 16),
      ),
    );
  }
}