// lib/login_page.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'features/notifications/fcm_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _auth = FirebaseAuth.instance;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool isLogin = true; // true: 로그인, false: 회원가입
  bool isLoading = false;
  bool _obscure = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// 최초 로그인/회원가입 이후 사용자 문서 초기화
  /// - 신규 계정: 기본 문서/컬렉션 시드 생성
  /// - 기존 계정: lastLoginAt 갱신 + 누락 필드만 보완(덮어쓰기 금지)
  Future<void> _bootstrapUserDoc(User user, {required String provider}) async {
    final usersDoc = FirebaseFirestore.instance
        .collection('Users')
        .doc(user.uid);
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
    } else {
      // ✅ 기존 계정 → 덮어쓰기 금지(숫자 필드 절대 건드리지 않음). 메타만 갱신.
      await usersDoc.set({
        'email': user.email,
        'lastLoginAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // “없을 때만” 생성하는 시드 & 안전 보강
      await _seedUserCollections(user.uid);
      await ensureUserStructureSafe(user.uid);
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

    // stats/summary (없을 때만)
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
    if (!setting.containsKey('placeID'))
      settingPatch['placeID'] = 'assets/images/prairie.png';
    if (settingPatch.isNotEmpty)
      patch['setting'] = {...setting, ...settingPatch};

    if (patch.isNotEmpty) {
      await userDoc.set(patch, SetOptions(merge: true));
    }

    // stats/summary는 “없을 때만” 시드. 기존이면 건드리지 않음.
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

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _signInAnonymously() async {
    setState(() => isLoading = true);
    try {
      final cred = await _auth.signInAnonymously().timeout(
        const Duration(seconds: 10),
      );
      final user = cred.user;
      if (user == null) {
        throw FirebaseAuthException(code: 'unknown', message: '익명 로그인 실패');
      }
      await _bootstrapUserDoc(user, provider: 'anonymous');
      // 화면 전환은 상위(authStateChanges)에서 처리
    } on TimeoutException {
      _showError('요청이 지연됩니다. 네트워크를 확인해주세요.');
    } on FirebaseAuthException catch (e) {
      _showError(e.message ?? '익명 로그인 오류');
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

        final uid = cred.user?.uid;
        if (uid != null) {
          await FcmService().init(uid: uid);
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
      _showError(e.message ?? '로그인/회원가입 오류');
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
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
                              icon: Icon(
                                _obscure
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () =>
                                  setState(() => _obscure = !_obscure),
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
                              onPressed: () =>
                                  setState(() => isLogin = !isLogin),
                              style: OutlinedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                side: BorderSide(
                                  color: base.colorScheme.primary.withOpacity(
                                    0.35,
                                  ),
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
