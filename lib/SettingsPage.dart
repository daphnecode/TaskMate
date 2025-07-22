import 'package:flutter/material.dart';
import 'package:taskmate/widgets/settings_widgets.dart';

class SettingsPage extends StatelessWidget {
  final bool isDarkMode; // 다크모드 켜져있는지 여부
  final bool notificationsEnabled; // 알림설정 여부
  final bool soundEffectsEnabled; // 효과음 여부
  final String sortingMethod; // 리스트 정렬 방식 표시 텍스트
  final void Function(int) onNext;

  final void Function(bool)? onDarkModeChanged; // 다크 모드 토글 시 호출
  final void Function(bool)? onNotificationsChanged; // 알림설정 토글 시 호출
  final void Function(bool)? onSoundEffectsChanged; // 효과음 토글 시 호출
  final void Function()? onChangeSortingMethod; // 정렬 방식 항목 클릭 시 실행

  const SettingsPage({
    super.key,
    required this.isDarkMode,
    required this.notificationsEnabled,
    required this.soundEffectsEnabled,
    required this.sortingMethod,
    required this.onNext,
    this.onDarkModeChanged,
    this.onNotificationsChanged,
    this.onSoundEffectsChanged,
    this.onChangeSortingMethod,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
          children: [
            const Text(
              '설정',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),

            buildSwitchTile(
              icon: Icons.dark_mode,
              label: '다크 모드',
              value: isDarkMode,
              onChanged: onDarkModeChanged,
            ),
            const SizedBox(height: 20),

            buildSwitchTile(
              icon: Icons.notifications,
              label: '알림 설정',
              value: notificationsEnabled,
              onChanged: onNotificationsChanged,
            ),
            const SizedBox(height: 20),

            buildListTile(
              icon: Icons.format_list_bulleted,
              label: '리스트 정렬 방식',
              value: sortingMethod,
              onTap: onChangeSortingMethod,
            ),
            const SizedBox(height: 20),

            buildSwitchTile(
              icon: Icons.volume_up,
              label: '효과음',
              value: soundEffectsEnabled,
              onChanged: onSoundEffectsChanged,
            ),
          ],
        ),
      ),

      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: const Icon(Icons.calendar_month),
                onPressed: () => onNext(3),
              ),
              IconButton(
                icon: const Icon(Icons.home),
                onPressed: () => onNext(0),
              ),
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () {}, // 현재 페이지이므로 빈 처리
              ),
            ],
          ),
        ),
      ),
    );
  }

}