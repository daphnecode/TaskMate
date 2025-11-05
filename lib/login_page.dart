// lib/login_page.dart
import 'dart:async';
import 'dart:math'; // 🔵 deviceId 생성용
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart'; // 🔵 acquire/heartbeat 호출
import 'package:shared_preferences/shared_preferences.dart'; // 🔵 deviceId 저장

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with WidgetsBindingObserver {
  final _auth = FirebaseAuth.instance;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool isLogin = true; // true: 로그인, false: 회원가입
  bool isLoading = false;
  bool _obscure = true;

  // 🔵 Functions 인스턴스 (배포 리전과 동일해야 함)
  final _func = FirebaseFunctions.instanceFor(region: 'asia-northeast3');

  // 🔵 세션 관리 상태
  String? _sessionId;
  Timer? _hbTimer;
  StreamSubscription? _sessSub;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _stopHeartbeat();
    _cancelSessionListen();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // 🔵 앱 라이프사이클 따라 하트비트 일시 중지/재개
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // 복귀 시 하트비트 즉시 1회 갱신
      _sendHeartbeatOnce();
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 초기 부트스트랩(기존 코드 유지)
  // ─────────────────────────────────────────────────────────────────────────

  /// 최초 로그인/회원가입 이후 사용자 문서 초기화
  /// - 신규 계정: 기본 문서/컬렉션 시드 생성
  /// - 기존 계정: lastLoginAt 갱신 + 누락 필드만 보완(덮어쓰기 금지)
  Future<void> _bootstrapUserDoc(User user, {required String provider}) async {
    final usersDoc = FirebaseFirestore.instance.collection('Users').doc(user.uid);
    final snap = await usersDoc.get().timeout(const Duration(seconds: 10));

    if (!snap.exists) {
      // ✅ 신규 계정 → 기본 필드 세팅 (최초 1회)
      await usersDoc.set({
        'email': user.email,
        'lastLoginAt': FieldValue.serverTimestamp(),
        // 상위 기본
        'currentPoint': 0,
        'gotPoint': 0,
        'nowPet': 'dragon',
        'setting': {
          'darkMode': false,
          'push': false,
          'listSort': 'default',
          'sound': true,
          'placeID': 'assets/images/prairie.png',
        },
      }, SetOptions(merge: true));

      // 하위 컬렉션 시드(없을 때만 생성)
      await _seedUserCollections(user.uid);

      // 누락 필드만 보완(중복 안전)
      await ensureUserStructureSafe(user.uid);

      // ✅ summary 누락 필드 + foodCount 시드 (신규)
      await ensureStatsAndFoodCount(user.uid);
    } else {
      // ✅ 기존 계정 → 덮어쓰기 금지(숫자 필드 절대 건드리지 않음). 메타만 갱신.
      await usersDoc.set({
        'email': user.email,
        'lastLoginAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // “없을 때만” 생성하는 시드 & 안전 보강
      await _seedUserCollections(user.uid);
      await ensureUserStructureSafe(user.uid);

      // ✅ summary 누락 필드 + foodCount 시드 (기존)
      await ensureStatsAndFoodCount(user.uid);
    }
  }

  /// 하위 컬렉션 시드 (없을 때만 생성)
  Future<void> _seedUserCollections(String uid) async {
    final fs = FirebaseFirestore.instance;
    final userRef = fs.collection('Users').doc(uid);

    // pets/dragon
    final dragon = userRef.collection('pets').doc('dragon');
    if (!(await dragon.get()).exists) {
      await dragon.set({
        'image': 'assets/images/dragon.png',
        'name': '드래곤',
        'hunger': 50,
        'happy': 50,
        'level': 1,
        'currentExp': 0,
        'styleID': 'basic',
      });
    }

    // pets/unicon
    final unicon = userRef.collection('pets').doc('unicon');
    if (!(await unicon.get()).exists) {
      await unicon.set({
        'image': 'assets/images/unicon.png',
        'name': '유니콘',
        'hunger': 50,
        'happy': 50,
        'level': 1,
        'currentExp': 0,
        'styleID': 'basic',
      });
    }

    // dailyTasks/yyyy-mm-dd (선택 시드)
    final todayId = DateTime.now().toIso8601String().substring(0, 10);
    final daily = userRef.collection('dailyTasks').doc(todayId);
    if (!(await daily.get()).exists) {
      await daily.set({'tasks': <dynamic>[]});
    }

    // log/first (선택)
    final logFirst = userRef.collection('log').doc('first');
    if (!(await logFirst.get()).exists) {
      await logFirst.set({
        'message': 'Welcome!',
        'ts': FieldValue.serverTimestamp(),
      });
    }

    // stats/summary (없을 때만) — 기본틀만, 상세 보강은 ensureStatsAndFoodCount가 담당
    final statsSummary = userRef.collection('stats').doc('summary');
    if (!(await statsSummary.get()).exists) {
      await statsSummary.set({
        'totalCompleted': 0,
        'streakDays': 0,
        'lastUpdatedDateStr': null, // 첫 제출 시 함수가 채움
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    }
  }

  /// 누락된 키만 “보완” (덮어쓰지 않음)
  Future<void> ensureUserStructureSafe(String uid) async {
    final users = FirebaseFirestore.instance.collection('Users');
    final userDoc = users.doc(uid);
    final snap = await userDoc.get();
    final data = snap.data() ?? {};

    final Map<String, dynamic> patch = {};
    if (!data.containsKey('currentPoint')) patch['currentPoint'] = 0;
    if (!data.containsKey('gotPoint')) patch['gotPoint'] = 0;
    if (!data.containsKey('nowPet')) patch['nowPet'] = 'dragon';

    final setting = Map<String, dynamic>.from(data['setting'] ?? {});
    final Map<String, dynamic> settingPatch = {};
    if (!setting.containsKey('darkMode')) settingPatch['darkMode'] = false;
    if (!setting.containsKey('push')) settingPatch['push'] = false;
    if (!setting.containsKey('listSort')) settingPatch['listSort'] = 'default';
    if (!setting.containsKey('sound')) settingPatch['sound'] = true;
    if (!setting.containsKey('placeID')) {
      settingPatch['placeID'] = 'assets/images/prairie.png';
    }
    if (settingPatch.isNotEmpty) {
      patch['setting'] = {...setting, ...settingPatch};
    }

    if (patch.isNotEmpty) {
      await userDoc.set(patch, SetOptions(merge: true));
    }

    // stats/summary 생성은 여기서 최소만 — 상세 필드 보강은 ensureStatsAndFoodCount가 전담
    final statsSummary = userDoc.collection('stats').doc('summary');
    if (!(await statsSummary.get()).exists) {
      await statsSummary.set({
        'totalCompleted': 0,
        'streakDays': 0,
        'lastUpdatedDateStr': null,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    }
  }

  /// ✅ 핵심: 기존/신규 모두에 대해
  /// - stats/summary의 누락 필드(feeding/moreHappy/runningDistance 등)만 안전 보완
  /// - stats/summary/foodCount/{itemId} 없으면 {name, count:0}로 시드
  Future<void> ensureStatsAndFoodCount(String uid) async {
    final fs = FirebaseFirestore.instance;
    final summaryRef =
    fs.collection('Users').doc(uid).collection('stats').doc('summary');

    final snap = await summaryRef.get();

    if (!snap.exists) {
      // 신규: summary 생성 + 기본 키들 세팅
      await summaryRef.set({
        'feeding': 0,
        'moreHappy': 0,
        'runningDistance': 0,
        'totalCompleted': 0,
        'streakDays': 0,
        'lastUpdatedDateStr': null,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } else {
      // 기존: 누락된 숫자 3종은 increment(0)으로 안전 생성
      await summaryRef.set({
        'feeding': FieldValue.increment(0),
        'moreHappy': FieldValue.increment(0),
        'runningDistance': FieldValue.increment(0),
      }, SetOptions(merge: true));

      // 그 외 누락 키만 보완
      final d = snap.data() ?? <String, dynamic>{};
      final patch = <String, dynamic>{};
      if (!d.containsKey('totalCompleted')) patch['totalCompleted'] = 0;
      if (!d.containsKey('streakDays')) patch['streakDays'] = 0;
      if (!d.containsKey('lastUpdatedDateStr')) patch['lastUpdatedDateStr'] = null;
      if (!d.containsKey('lastUpdated')) {
        patch['lastUpdated'] = FieldValue.serverTimestamp();
      }
      if (patch.isNotEmpty) {
        await summaryRef.set(patch, SetOptions(merge: true));
      }
    }

    // foodCount 하위 문서들: 없으면 {name, count:0}로 생성
    await _ensureFoodCountDocs(uid, const [
      'cookie',
      'mushroomStew',
      'pudding',
      'strawberry',
      'tuna',
    ]);
  }

  Future<void> _ensureFoodCountDocs(String uid, List<String> itemIds) async {
    final fs = FirebaseFirestore.instance;
    final col = fs
        .collection('Users')
        .doc(uid)
        .collection('stats')
        .doc('summary')
        .collection('foodCount'); // /Users/{uid}/stats/summary/foodCount

    final batch = fs.batch();
    for (final id in itemIds) {
      final ref = col.doc(id); // /foodCount/{itemId}
      if (!(await ref.get()).exists) {
        batch.set(ref, {'name': id, 'count': 0}); // 새로 생성 (덮어쓰기 없음)
      }
    }
    await batch.commit();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 🔵 동시 로그인 방지: 세션 점유/하트비트/문서 감시
  // ─────────────────────────────────────────────────────────────────────────

  Future<String> _getOrCreateDeviceId() async {
    final p = await SharedPreferences.getInstance();
    var id = p.getString('deviceId');
    if (id == null) {
      const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
      final r = Random();
      id = List.generate(20, (_) => chars[r.nextInt(chars.length)]).join();
      await p.setString('deviceId', id);
    }
    return id;
  }

  Future<bool> _acquireSession({required bool force}) async {
    final deviceId = await _getOrCreateDeviceId();
    final res = await _func.httpsCallable('acquireSession').call({
      'deviceId': deviceId,
      'deviceName': 'flutter-app',
      'ttlSec': 45,
      'force': force,
    });
    final data = Map<String, dynamic>.from(res.data);
    if (data['ok'] == true) {
      _sessionId = data['sessionId'] as String;
      _startHeartbeat();
      final uid = _auth.currentUser?.uid;
      if (uid != null) _listenSessionDoc(uid);
      return true;
    }
    return false;
  }

  void _startHeartbeat() {
    _hbTimer?.cancel();
    _hbTimer = Timer.periodic(const Duration(seconds: 25), (_) => _sendHeartbeatOnce());
  }

  void _stopHeartbeat() {
    _hbTimer?.cancel();
    _hbTimer = null;
  }

  Future<void> _sendHeartbeatOnce() async {
    if (_sessionId == null) return;
    try {
      final res = await _func.httpsCallable('heartbeatSession').call({
        'sessionId': _sessionId,
      });
      final data = Map<String, dynamic>.from(res.data);
      if (data['ok'] != true) {
        // taken/expired 등 → 강제 로그아웃
        await FirebaseAuth.instance.signOut();
      }
    } catch (_) {
      // 네트워크 오류 등은 다음 주기에 재시도
    }
  }

  void _listenSessionDoc(String uid) {
    final doc = FirebaseFirestore.instance
        .collection('Users')
        .doc(uid)
        .collection('auth')
        .doc('session');

    _sessSub?.cancel();
    _sessSub = doc.snapshots().listen((snap) async {
      if (!snap.exists) return;
      final serverId = snap.data()?['sessionId'] as String?;
      if (_sessionId != null && serverId != _sessionId) {
        await FirebaseAuth.instance.signOut(); // 내 세션이 탈취됨
      }
    });
  }

  void _cancelSessionListen() {
    _sessSub?.cancel();
    _sessSub = null;
  }

  // 🔵 로그인 직후: 세션 점유 시도 → 실패 시 전환 다이얼로그
  Future<void> _ensureSingleSessionOrSignOut() async {
    final ok = await _acquireSession(force: false);
    if (ok) return;

    final wantForce = await _askSwitchDialog(); // 전환 여부
    if (!wantForce) {
      await FirebaseAuth.instance.signOut();
      return;
    }

    final ok2 = await _acquireSession(force: true);
    if (!ok2) {
      await FirebaseAuth.instance.signOut();
      await _showConcurrentLoginDialog();
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // UI 헬퍼/다이얼로그
  // ─────────────────────────────────────────────────────────────────────────

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  /// 동시 로그인 안내 다이얼로그(정보용)
  Future<void> _showConcurrentLoginDialog() async {
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('동시 로그인 감지'),
        content: const Text('다른 기기에서 이미 로그인 중이에요.\n그 기기에서 로그아웃한 뒤 다시 시도해주세요.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  /// 전환(이 기기로 사용) 선택 다이얼로그
  Future<bool> _askSwitchDialog() async {
    if (!mounted) return false;
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('다른 기기에서 사용 중'),
        content: const Text('현재 계정이 다른 기기에서 사용 중입니다.\n이 기기로 전환하시겠어요? (다른 기기는 즉시 로그아웃됩니다)'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('취소'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('이 기기로 전환'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 로그인/회원가입 플로우 (기존 + 세션 점유 호출 추가)
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _signInAnonymously() async {
    setState(() => isLoading = true);
    try {
      final cred = await _auth.signInAnonymously().timeout(const Duration(seconds: 10));
      final user = cred.user;
      if (user == null) {
        throw FirebaseAuthException(code: 'unknown', message: '익명 로그인 실패');
      }
      await _bootstrapUserDoc(user, provider: 'anonymous');

      // 🔵 로그인 성공 직후: 세션 점유/감시 시작
      await _ensureSingleSessionOrSignOut();
      // 화면 전환은 상위(authStateChanges)에서 처리
    } on TimeoutException {
      _showError('요청이 지연됩니다. 네트워크를 확인해주세요.');
    } on FirebaseAuthException catch (e) {
      final msg = (e.message ?? '').toUpperCase();
      final code = (e.code).toUpperCase();
      if (msg.contains('ALREADY_ACTIVE_SESSION') || code.contains('ALREADY_ACTIVE_SESSION')) {
        await _showConcurrentLoginDialog();
      } else {
        _showError(e.message ?? '익명 로그인 오류');
      }
    } on FirebaseException catch (e) {
      _showError('Firebase 오류: ${e.message ?? e.code}');
    } catch (e) {
      _showError('알 수 없는 오류: $e');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _submitEmail() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showError('이메일과 비밀번호를 입력하세요');
      return;
    }
    if (!isLogin && password.length < 6) {
      _showError('비밀번호는 6자 이상이어야 합니다');
      return;
    }

    setState(() => isLoading = true);
    try {
      if (isLogin) {
        // 로그인
        final cred = await _auth
            .signInWithEmailAndPassword(email: email, password: password)
            .timeout(const Duration(seconds: 10));

        final user = cred.user;
        if (user == null) {
          throw FirebaseAuthException(
            code: 'unknown',
            message: '로그인 실패: 사용자 없음',
          );
        }

        await user.reload().timeout(const Duration(seconds: 10));
        final fresh = _auth.currentUser;
        final verified = fresh?.emailVerified ?? false;

        if (!verified) {
          await _maybeSendVerificationEmail(fresh);
          await _auth.signOut();
          await _showVerifyDialog(emailSent: true, email: email);
          return;
        }

        await _bootstrapUserDoc(fresh!, provider: 'password');

        // 🔵 로그인 성공 직후: 세션 점유/감시 시작
        await _ensureSingleSessionOrSignOut();
      } else {
        // 회원가입
        final cred = await _auth
            .createUserWithEmailAndPassword(email: email, password: password)
            .timeout(const Duration(seconds: 10));

        final user = cred.user;
        if (user == null) {
          throw FirebaseAuthException(
            code: 'unknown',
            message: '회원가입 실패: 사용자 없음',
          );
        }

        await _maybeSendVerificationEmail(user);
        await _auth.signOut();
        await _showVerifyDialog(emailSent: true, email: email);
      }
    } on TimeoutException {
      _showError('요청이 지연됩니다. 네트워크를 확인해주세요.');
    } on FirebaseAuthException catch (e) {
      // beforeSignIn 차단(동시 로그인)의 표준 에러 문자열 감지 (GCIP 미사용 시엔 거의 안옴)
      final msg = (e.message ?? '').toUpperCase();
      final code = (e.code).toUpperCase();
      if (msg.contains('ALREADY_ACTIVE_SESSION') || code.contains('ALREADY_ACTIVE_SESSION')) {
        await _showConcurrentLoginDialog();
      } else {
        _showError(e.message ?? '로그인/회원가입 오류');
      }
    } on FirebaseException catch (e) {
      _showError('Firebase 오류: ${e.message ?? e.code}');
    } catch (e) {
      _showError('알 수 없는 오류: $e');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _maybeSendVerificationEmail(User? user) async {
    try {
      await user?.sendEmailVerification();
    } catch (_) {}
  }

  Future<void> _showVerifyDialog({
    required bool emailSent,
    required String email,
  }) async {
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('이메일 인증이 필요합니다'),
          content: Text(
            emailSent
                ? '입력한 주소($email)로 인증 메일을 보냈어요.\n메일함(스팸함 포함)을 확인한 뒤, 인증을 완료하고 다시 로그인 해주세요.'
                : '이메일 인증이 아직 완료되지 않았습니다.\n메일함을 확인한 뒤, 인증을 완료하고 다시 로그인 해주세요.',
          ),
          actions: [
            TextButton(
              onPressed: () async {
                final current = _auth.currentUser;
                if (current != null && !current.emailVerified) {
                  await _maybeSendVerificationEmail(current);
                  if (mounted) {
                    Navigator.of(ctx).pop();
                    _showError('인증 메일을 다시 보냈습니다.');
                  }
                } else {
                  Navigator.of(ctx).pop();
                }
              },
              child: const Text('인증 메일 다시 보내기'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('확인'),
            ),
          ],
        );
      },
    );
  }

  InputDecoration _inputDeco(String label, {Widget? suffix}) {
    final base = Theme.of(context);
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: base.colorScheme.surface.withOpacity(
        base.brightness == Brightness.dark ? 0.35 : 0.9,
      ),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: base.colorScheme.primary.withOpacity(0.7),
          width: 2,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      suffixIcon: suffix,
    );
  }

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context);
    final title = isLogin ? '로그인' : '회원가입';
    final submitText = isLogin ? '로그인' : '회원가입';
    final toggleText = isLogin ? '회원가입으로 전환' : '로그인으로 전환';
    final bg = base.brightness == Brightness.dark
        ? const Color(0xFF121214)
        : const Color(0xFFF7F3FF);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 26),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: base.colorScheme.onSurface.withOpacity(0.9),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: base.colorScheme.surface,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        TextField(
                          controller: _emailController,
                          decoration: _inputDeco('이메일'),
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _passwordController,
                          decoration: _inputDeco(
                            '비밀번호',
                            suffix: IconButton(
                              icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                              onPressed: () => setState(() => _obscure = !_obscure),
                              tooltip: _obscure ? '표시' : '숨기기',
                            ),
                          ),
                          obscureText: _obscure,
                          onSubmitted: (_) => _submitEmail(),
                        ),
                        const SizedBox(height: 16),
                        if (isLoading) const CircularProgressIndicator(),
                        if (!isLoading) ...[
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              onPressed: _submitEmail,
                              style: ElevatedButton.styleFrom(
                                elevation: 0,
                                backgroundColor: base.colorScheme.primary,
                                foregroundColor: base.colorScheme.onPrimary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: Text(
                                submitText,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: OutlinedButton(
                              onPressed: () => setState(() => isLogin = !isLogin),
                              style: OutlinedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                side: BorderSide(
                                  color: base.colorScheme.primary.withOpacity(0.35),
                                ),
                              ),
                              child: Text(
                                toggleText,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: base.colorScheme.primary,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Opacity(
                            opacity: 0.5,
                            child: Divider(color: base.dividerColor),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            height: 46,
                            child: TextButton.icon(
                              onPressed: _signInAnonymously,
                              icon: const Icon(Icons.flash_on),
                              label: const Text('익명(게스트)으로 시작'),
                              style: TextButton.styleFrom(
                                foregroundColor: base.colorScheme.primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    '회원가입 시 인증 메일을 확인해 주세요. 인증 완료 후 다시 로그인하면 시작할 수 있어요.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: base.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
