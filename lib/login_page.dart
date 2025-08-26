import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _auth = FirebaseAuth.instance;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool isLogin = true;      // true: 로그인, false: 회원가입
  bool isLoading = false;   // 버튼 로딩 스피너
  bool _obscure = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// 최초 로그인한 사용자의 Firestore 문서 초기 세팅 (이메일 인증 완료/익명 로그인 시)
  Future<void> _bootstrapUserDoc(User user, {required String provider}) async {
    final usersDoc = FirebaseFirestore.instance.collection('Users').doc(user.uid);
    final snap = await usersDoc.get().timeout(const Duration(seconds: 10));

    if (!snap.exists) {
      await usersDoc
          .set({
        'email': user.email,
        'provider': provider, // 'password' | 'anonymous'
        'createdAt': FieldValue.serverTimestamp(),
        'currentPoint': 0,
        'currentExp': 0,
        'gotPoint': 0,
        'nowPet': 'dragon',
        // 신규 계정 기본 세팅/통계
        'setting': {
          'darkMode': false,
          'push': false,
          'listSort': 'default',
          'sound': true,
          'placeID': 'assets/images/prairie.png',
        },
        'statistics': {},
        'lastLoginAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true))
          .timeout(const Duration(seconds: 10));

      // ✅ 하위 컬렉션 시드 생성 (없을 때만 생성)
      await _seedUserCollections(user.uid);
      await ensureUserStructure(user.uid);
    } else {
      // 로그인 시 갱신 + 누락 보완
      await usersDoc
          .set({
        'email': user.email,
        'provider': provider,
        'lastLoginAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true))
          .timeout(const Duration(seconds: 10));

      await _seedUserCollections(user.uid);
      await ensureUserStructure(user.uid);
    }
  }

  /// 하위 컬렉션들(예: pets/items/dailyTasks/log) 없으면 기본 문서 만들어줌
  Future<void> _seedUserCollections(String uid) async {
    final fs = FirebaseFirestore.instance;
    final userRef = fs.collection('Users').doc(uid);
    final batch = fs.batch();

    // pets/dragon
    final petRef = userRef.collection('pets').doc('dragon');
    if (!(await petRef.get()).exists) {
      batch.set(petRef, {
        'name': 'Dragon',
        'image': 'assets/images/dragon.png',
        'hunger': 0,
        'happy': 0,
        'level': 1,
        'currentExp': 0,
        'styleID': 'basic',
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    // items/seed
    final itemsRef = userRef.collection('items').doc('seed');
    if (!(await itemsRef.get()).exists) {
      batch.set(itemsRef, {
        'starterPack': true,
        'coins': 0,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    // dailyTasks/yyyy-mm-dd
    final todayId = DateTime.now().toIso8601String().substring(0, 10);
    final dailyRef = userRef.collection('dailyTasks').doc(todayId);
    if (!(await dailyRef.get()).exists) {
      batch.set(dailyRef, {
        'date': todayId,
        'tasks': <dynamic>[], // 빈 리스트
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    // log/first
    final logRef = userRef.collection('log').doc('first');
    if (!(await logRef.get()).exists) {
      batch.set(logRef, {
        'message': 'Welcome!',
        'ts': FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _signInAnonymously() async {
    setState(() => isLoading = true);
    try {
      final cred =
      await _auth.signInAnonymously().timeout(const Duration(seconds: 10));
      final user = cred.user;
      if (user == null) {
        throw FirebaseAuthException(code: 'unknown', message: '익명 로그인 실패');
      }
      await _bootstrapUserDoc(user, provider: 'anonymous')
          .timeout(const Duration(seconds: 10));
      // 화면 전환은 상위(authStateChanges)에서 자동 처리됨
    } on TimeoutException {
      _showError('요청이 지연됩니다. 네트워크를 확인해주세요.');
    } on FirebaseException catch (e) {
      _showError('Firebase 오류: ${e.message ?? e.code}');
    } on FirebaseAuthException catch (e) {
      _showError(e.message ?? '익명 로그인 오류');
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
          throw FirebaseAuthException(code: 'unknown', message: '로그인 실패: 사용자 없음');
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

        await _bootstrapUserDoc(fresh!, provider: 'password')
            .timeout(const Duration(seconds: 10));
      } else {
        // 회원가입
        final cred = await _auth
            .createUserWithEmailAndPassword(email: email, password: password)
            .timeout(const Duration(seconds: 10));

        final user = cred.user;
        if (user == null) {
          throw FirebaseAuthException(code: 'unknown', message: '회원가입 실패: 사용자 없음');
        }

        await _maybeSendVerificationEmail(user);
        await _auth.signOut();
        await _showVerifyDialog(emailSent: true, email: email);
      }
    } on TimeoutException {
      _showError('요청이 지연됩니다. 네트워크를 확인해주세요.');
    } on FirebaseException catch (e) {
      _showError('Firebase 오류: ${e.message ?? e.code}');
    } on FirebaseAuthException catch (e) {
      _showError(e.message ?? '로그인/회원가입 오류');
    } catch (e) {
      _showError('알 수 없는 오류: $e');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  /// 인증 메일(재)발송 시도
  Future<void> _maybeSendVerificationEmail(User? user) async {
    try {
      await user?.sendEmailVerification();
    } catch (_) {}
  }

  /// 인증 안내 다이얼로그
  Future<void> _showVerifyDialog(
      {required bool emailSent, required String email}) async {
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

  // ─ UI 헬퍼
  InputDecoration _inputDeco(String label, {Widget? suffix}) {
    final base = Theme.of(context);
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: base.colorScheme.surface
          .withOpacity(base.brightness == Brightness.dark ? 0.35 : 0.9),
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
      contentPadding:
      const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
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
                                  _obscure ? Icons.visibility_off : Icons.visibility),
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
                                    fontSize: 16, fontWeight: FontWeight.w700),
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
                                  color: base.colorScheme.primary
                                      .withOpacity(0.35),
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


Future<void> ensureUserStructure(String uid) async {
  final users = FirebaseFirestore.instance.collection('Users');
  final userDoc = users.doc(uid);

  // Users/{uid} 기본 필드 보강 (이미 있으면 merge)
  await userDoc.set({
    'currentPoint': 0,
    'currentExp': 0,
    'gotPoint': 0,
    'nowPet': 'dragon',
    'setting': {
      'darkMode': false,
      'push': false,
      'listSort': 'default',
      'sound': true,
      'placeID': 'assets/images/prairie.png'
    },
    'statistics': {},
  }, SetOptions(merge: true));

  final pets = userDoc.collection('pets');
  final dragon = await pets.doc('dragon').get();
  if (!dragon.exists) {
    await pets.doc('dragon').set({
      'image': 'assets/images/dragon.png',
      'name': '드래곤',
      'hunger': 50,
      'happy': 50,
      'level': 1,
      'currentExp': 0,
      'styleID': 'style123',
    });
  }
  final unicon = await pets.doc('unicon').get();
  if (!unicon.exists) {
    await pets.doc('unicon').set({
      'image': 'assets/images/unicon.png',
      'name': '유니콘',
      'hunger': 50,
      'happy': 50,
      'level': 1,
      'currentExp': 0,
      'styleID': 'style123',
    });
  }



  final itemsCol = userDoc.collection('items');
  final cookie = itemsCol.doc('cookie');
  if (!(await cookie.get()).exists) {
    await cookie.set({
      'name': 'cookie',
      'icon': 'assets/icons/icon-chicken.png',
      'category': 1,    // 음식
      'hunger': 15,
      'happy': 4,
      'price': 40,
      'count': 0,
      'itemText': '먹으면 힘이 난다',
    });
  }

  // ✅ 통계 요약(stats/summary) 시드
  final statsSummaryRef = userDoc.collection('stats').doc('summary');
  await statsSummaryRef.set({
    'totalCompleted': 0,
    'streakDays': 0,
    // 처음엔 null 가능. 함수가 첫 제출 시 오늘 날짜로 갱신함
    'lastUpdatedDateStr': null,
    'lastUpdated': FieldValue.serverTimestamp(),
  }, SetOptions(merge: true));

}
