// lib/settingspage.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  bool _signingOut = false;

  Future<void> _confirmAndSignOut() async {
    if (_signingOut) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('로그아웃'),
        content: const Text('정말 로그아웃하시겠습니까?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('취소')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('로그아웃')),
        ],
      ),
    );
    if (ok != true) return;

    setState(() => _signingOut = true);
    try {
      await FirebaseAuth.instance.signOut();
      // 루트에서 authStateChanges()가 LoginPage를 띄움.
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('로그아웃되었습니다.')),
        );
        // 네비게이션 스택 정리(선택): 뒤로 가기 시 로그인으로 남도록
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } finally {
      if (mounted) setState(() => _signingOut = false);
    }
  }

  void onSortingChangedDialog(BuildContext context) async {
    String? selected = await showDialog<String>(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: const Text('정렬 방법 선택'),
          children: _sortOptions.map((option) {
            return SimpleDialogOption(
              onPressed: () => Navigator.pop(context, option),
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
              onChanged: (value) => widget.onSoundEffectsChanged?.call(value),
            ),

            const SizedBox(height: 20),
            buildListTile(
              context: context,
              icon: Icons.volunteer_activism,
              label: '도움을 주신 분들',
              value: '',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) =>  CreditsPage()),
                );
              },
            ),

            const SizedBox(height: 30),
            const Divider(),

            // 로그아웃
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: Text(
                _signingOut ? '로그아웃 중…' : '로그아웃',
                style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600),
              ),
              onTap: _signingOut ? null : _confirmAndSignOut,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              tileColor: Theme.of(context).cardColor,
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
                onPressed: () {}, // 현재 페이지
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CreditsPage extends StatelessWidget {
  CreditsPage({super.key}); // const 제거

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
