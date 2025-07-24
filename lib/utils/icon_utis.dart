import 'package:flutter/material.dart';

/// 다크모드일 때 아이콘 색 반전 적용해서 반환
Widget getThemedIcon(BuildContext context, String assetPath,
    {double width = 30, double height = 30}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;

  return isDark
      ? ColorFiltered(
    colorFilter: const ColorFilter.matrix([
      -1, 0, 0, 0, 255,
      0, -1, 0, 0, 255,
      0, 0, -1, 0, 255,
      0, 0, 0, 1, 0,
    ]),
    child: Image.asset(assetPath, width: width, height: height),
  )
      : Image.asset(assetPath, width: width, height: height);
}
