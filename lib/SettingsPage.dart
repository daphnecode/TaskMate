import 'package:flutter/material.dart';
import 'package:taskmate/widgets/settings_widgets.dart';

class SettingsPage extends StatefulWidget {
  final bool isDarkMode; // 다크모드 켜져있는지 여부
  final bool notificationsEnabled; // 알림설정 여부
  final bool soundEffectsEnabled; // 효과음 여부
  final String sortingMethod; // 리스트 정렬 방식 표시 텍스트
  final void Function(int) onNext;

  final void Function(bool)? onDarkModeChanged; // 다크 모드 토글 시 호출
  final void Function(bool)? onNotificationsChanged; // 알림설정 토글 시 호출
  final void Function(bool)? onSoundEffectsChanged; // 효과음 토글 시 호출
  final void Function(String)? onChangeSortingMethod; // 정렬 방식 항목 클릭 시 실행

  const SettingsPage({
    super.key,
    required this.isDarkMode,
    required this.notificationsEnabled,
    required this.soundEffectsEnabled,
    required this.sortingMethod,
    required this.onNext,
    required this.onDarkModeChanged,
    required this.onNotificationsChanged,
    required this.onSoundEffectsChanged,
    required this.onChangeSortingMethod,
  });

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final List<String> _sortOptions = ['사전 순', '포인트 순', '등록 순'];

  void onSortingChangedDialog(BuildContext context) async {
    widget.onChangeSortingMethod;
    String? selected = await showDialog<String>(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: Text('정렬 방법 선택'),
          children: _sortOptions.map((option) {
            return SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, option); // 선택한 값을 반환
              },
              child: Text(option),
            );
          }).toList(),
        );
      },
    );
    if (selected != null && selected != widget.sortingMethod) {
      widget.onChangeSortingMethod?.call(selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
          children: [
             Text(
              '설정',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),

            buildSwitchTile(
              context: context,
              icon: Icons.dark_mode,
              label: '다크 모드',
              value: widget.isDarkMode,
              onChanged: widget.onDarkModeChanged,
            ),
            const SizedBox(height: 20),

            buildSwitchTile(
              context: context,
              icon: Icons.notifications,
              label: '알림 설정',
              value: widget.notificationsEnabled,
              onChanged: widget.onNotificationsChanged,
            ),
            const SizedBox(height: 20),

            buildListTile(
              context: context,
              icon: Icons.format_list_bulleted,
              label: '리스트 정렬 방식',
              value: widget.sortingMethod,
              onTap: () => onSortingChangedDialog(context),
            ),
            const SizedBox(height: 20),

            buildSwitchTile(
              context: context,
              icon: Icons.volume_up,
              label: '효과음',
              value: widget.soundEffectsEnabled,
              onChanged: (value) {
                widget.onSoundEffectsChanged?.call(value); // 상태만 바꿈
              },
            ),
            const SizedBox(height: 20),
            buildListTile(
              context: context,
              icon: Icons.volunteer_activism, // 원하는 아이콘으로 변경 가능
              label: '도움을 주신 분들',
              value: '',
              onTap: () {
                // 추후 연결
                Navigator.push(context,MaterialPageRoute(builder: (context) => CreditsPage(),));
              },
            ),
          ],
        ),
      ),

      bottomNavigationBar: BottomAppBar(
        color: Theme.of(context).bottomAppBarTheme.color,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: const Icon(Icons.calendar_month),
                onPressed: () => widget.onNext(3),
              ),
              IconButton(
                icon: const Icon(Icons.home),
                onPressed: () => widget.onNext(0),
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

class CreditsPage extends StatelessWidget {
  const CreditsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("도움을 주신 분")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: const [
            Text(
              "이 앱은 아래 오픈소스 및 자료를 사용하여 제작되었습니다.",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Text(
              "• 아이콘: WebHostingHub Glyphs\n"
              "  출처: https://www.webhostinghub.com/glyphs\n"
              "  라이선스: SIL Open Font License 1.1",
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 20),
            Text(
              "아이콘의 저작권은 WebHostingHub에 있으며, 본 앱은 "
              "SIL Open Font License 1.1에 따라 해당 아이콘을 사용합니다.",
              style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }
}
