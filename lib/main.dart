import 'package:flutter/material.dart';
import 'utils/bgm_manager.dart';
import 'planner_main.dart';
import 'planner_edit.dart';
import 'itemlist.dart';
import 'petmain.dart';
import 'petchoose.dart';
import 'DBtest/task.dart';
import 'DBtest/task_data.dart';
import 'object.dart';
import 'settingspage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const Root());
}

class Root extends StatefulWidget {
  const Root({super.key});
  @override
  State<Root> createState() => RootState();
}

class RootState extends State<Root> {
  /*
  최초 사용자 정보 생성.
  사용자 ID 저장.
  사용자 로그인, 인증.
  */
  Users user = Users(
      currentPoint: 0,
      gotPoint: 0,
      nowPet: "",
      setting: {},
      statistics: {}
  );

  bool isLoading = true;

  void _onPointsAdded(int delta) {
    setState(() {
      user.currentPoint += delta;
      user.gotPoint += delta;
    });
  }

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  Future<void> loadUser() async {
    // 현재 로그인된 유저가 있으면 그 uid 사용, 없으면 기존 유지
    final String fallbackUid = 'HiHgtVpIvdyCZVtiFCOc';
    final String uid =
        FirebaseAuth.instance.currentUser?.uid ?? fallbackUid;

    DocumentSnapshot doc1 = await FirebaseFirestore.instance
        .collection('Users')
        .doc(uid)
        .get();

    setState(() {
      if (doc1.exists) {
        user = Users.fromMap(doc1.data() as Map<String, dynamic>);
      } else {
        // 문서가 아직 없으면 기본값 유지
        user = Users(
          currentPoint: 0,
          gotPoint: 0,
          nowPet: "",
          setting: {},
          statistics: {},
        );
      }
      isLoading = false; // ✅ 로딩 종료는 여기서 확실히
    });
  }

  void toggleDarkMode(bool value) {
    setState(() => user.setting['darkMode'] = value);
  }

  void togglePushNotification(bool value) {
    setState(() => user.setting['push'] = value);
  }

  void toggleSortingMethod(String value) {
    setState(() => user.setting['listSort'] = value);
  }

  void toggleSoundEffects(bool value) {
    setState(() => user.setting['sound'] = value);
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const MaterialApp(
        home: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }
    return MaterialApp(
      title: 'TaskMate',
      theme: ThemeData.light().copyWith(
        bottomAppBarTheme: const BottomAppBarTheme(color: Colors.white), // 라이트모드 하단바
      ),
      darkTheme: ThemeData.dark().copyWith(
        iconTheme: const IconThemeData(color: Colors.white),
        bottomAppBarTheme: BottomAppBarTheme(color: Colors.grey[900]), // 다크모드 하단바
      ),
      themeMode: (user.setting?['darkMode'] == true) ? ThemeMode.dark : ThemeMode.light,
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          debugPrint('authStateChanges → '
              'state=${snapshot.connectionState}, hasData=${snapshot.hasData}, user=${snapshot.data?.uid}');

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }

          if (snapshot.hasData && snapshot.data != null) {
            // 로그인된 경우: 해당 uid의 사용자 문서를 "실시간" 구독
            final String uid = snapshot.data!.uid;
            final userDocRef = FirebaseFirestore.instance.collection('Users').doc(uid);

            return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              stream: userDocRef.snapshots(),
              builder: (context, uSnap) {
                debugPrint('userDocRef.snapshots → '
                    'state=${uSnap.connectionState}, hasData=${uSnap.hasData}, exists=${uSnap.data?.exists}');
                if (uSnap.hasError) {
                  return Scaffold(
                    body: Center(child: Text('Firestore 오류: ${uSnap.error}')),
                  );
                }

                // 첫 스냅샷 전이거나 문서가 없어도 기본값으로 바로 진입
                if (!uSnap.hasData || !(uSnap.data?.exists ?? false)) {
                  final loadedUser = Users.fromMap({
                    'currentPoint': 0,
                    'gotPoint': 0,
                    'nowPet': '',
                    'setting': {
                      'darkMode': false,
                      'push': false,
                      'listSort': 'default',
                      'sound': true,
                    },
                    'statistics': {},
                  });
                  return MyHomePage(
                    title: 'Virtual Pet',
                    user: loadedUser,
                    onDarkModeChanged: toggleDarkMode,
                    onPushChanged: togglePushNotification,
                    onSortingChanged: toggleSortingMethod,
                    onSoundEffectsChanged: toggleSoundEffects,
                    onPointsAdded: _onPointsAdded,
                  );
                }

                // ✅ fromMap 전에 원본 맵을 안전하게 보정
                final raw = Map<String, dynamic>.from(uSnap.data!.data()!);

                // 최상위 필드 기본값
                raw['currentPoint'] = (raw['currentPoint'] ?? 0) as int;
                raw['gotPoint']     = (raw['gotPoint'] ?? 0) as int;
                raw['nowPet']       = (raw['nowPet'] ?? '') as String;

                // setting 맵 기본값
                raw['setting'] = (raw['setting'] is Map<String, dynamic>)
                    ? Map<String, dynamic>.from(raw['setting'])
                    : <String, dynamic>{};

                raw['setting']['darkMode'] = raw['setting']['darkMode'] ?? false;
                raw['setting']['push']     = raw['setting']['push'] ?? false;
                raw['setting']['listSort'] = raw['setting']['listSort'] ?? 'default';
                raw['setting']['sound']    = raw['setting']['sound'] ?? true;

                // statistics 맵 기본값
                raw['statistics'] = (raw['statistics'] is Map<String, dynamic>)
                    ? Map<String, dynamic>.from(raw['statistics'])
                    : <String, dynamic>{};

                Users loadedUser;
                try {
                  loadedUser = Users.fromMap(raw);
                } catch (e) {
                  debugPrint('Users.fromMap error: $e');
                  loadedUser = Users(
                    currentPoint: 0,
                    gotPoint: 0,
                    nowPet: '',
                    setting: {
                      'darkMode': false,
                      'push': false,
                      'listSort': 'default',
                      'sound': true,
                    },
                    statistics: {},
                  );
                }

                return MyHomePage(
                  title: 'Virtual Pet',
                  user: loadedUser,
                  onDarkModeChanged: toggleDarkMode,
                  onPushChanged: togglePushNotification,
                  onSortingChanged: toggleSortingMethod,
                  onSoundEffectsChanged: toggleSoundEffects,
                  onPointsAdded: _onPointsAdded,
                );
              },
            );
          }

          // 비로그인: 로그인 페이지
          return const LoginPage();
        },
      ),
      // home: MyHomePage(
      //   title: 'Virtual Pet',
      //   user: user,
      //   onDarkModeChanged: toggleDarkMode,
      //   onPushChanged: togglePushNotification,
      //   onSortingChanged: toggleSortingMethod,
      //   onSoundEffectsChanged: toggleSoundEffects,
      //   onPointsAdded:_onPointsAdded,
      // ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final Users user;
  final Function(bool) onDarkModeChanged;
  final Function(bool) onPushChanged;
  final Function(String) onSortingChanged;
  final Function(bool) onSoundEffectsChanged;
  final Function(int) onPointsAdded;

  const MyHomePage({
    required this.title,
    required this.user,
    required this.onDarkModeChanged,
    required this.onPushChanged,
    required this.onSortingChanged,
    required this.onSoundEffectsChanged,
    required this.onPointsAdded,
    super.key,
  });

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 0;

  Pets pet = Pets(
      image: "",
      name: "",
      hunger:0,
      happy: 0,
      level: 0,
      currentExp: 0,
      styleID: ""
  );

  @override
  void initState() {
    super.initState();
    initAsync();
  }

  Future<void> initAsync() async {
    await loadPets();
    await BgmManager.preload('bgm2.wav');
    await BgmManager.preload('bgm1.mp3');
  }

  Future<void> loadPets() async {
    // 현재 로그인 uid 우선, 없으면 으로 호환
    final String fallbackUid = 'HiHgtVpIvdyCZVtiFCOc';
    final String uid =
        FirebaseAuth.instance.currentUser?.uid ?? fallbackUid;

    final String petId =
    (widget.user.nowPet is String && widget.user.nowPet.isNotEmpty)
        ? widget.user.nowPet
        : 'default';

    DocumentSnapshot petDoc = await FirebaseFirestore.instance
        .collection('Users')
        .doc(uid)
        .collection('pets')
        .doc(petId)
        .get();

    final Pets loadedItems2;

    if (petDoc.exists) {
      final data = petDoc.data() as Map<String, dynamic>;
      loadedItems2 = Pets.fromMap(data);
    } else {
      loadedItems2 = Pets(
          image: "",
          name: "",
          hunger:0,
          happy: 0,
          level: 0,
          currentExp: 0,
          styleID: ""
      );
    }

    setState(() {
      pet = loadedItems2;
    });
  }

  Map<String, List<Task>> dailyTaskMap = {};
  DateTime selectedDate = DateTime.now();
  String _dateKey(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  void goNext(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget currentWidget;

    switch (_currentIndex) {
      case 0:
        currentWidget = Petmain(onNext: goNext, pet: pet, user: widget.user, pageType: 0,  soundEffectsOn: widget.user.setting?['sound'] ?? true,);
        break;
      case 1:
        currentWidget = ItemCategory(onNext: goNext, pet: pet, user: widget.user, pageType: 1,);
        break;
      case 2:
        currentWidget = PetChoose(onNext: goNext);
        break;
      case 3:
        currentWidget = PlannerMain(
          onNext: goNext,
          sortingMethod: widget.user.setting?['listSort'] ?? 'default',
          onPointsAdded: widget.onPointsAdded,
        );
        break;
      case 4:
        currentWidget = PlannerEditPage(
          onNext: goNext,
          onBackToMain: () {
            setState(() {
              _currentIndex = 3; //플래너 메인으로 돌아가기
            });
          },

          repeatTaskList: repeatTaskList,
          todayTaskList: todayTaskList,

          onUpdateTasks: (updatedRepeat, updatedToday) {
            setState(() {
              repeatTaskList
                ..clear()
                ..addAll(updatedRepeat);
              todayTaskList
                ..clear()
                ..addAll(updatedToday);

              final key = _dateKey(selectedDate);
              dailyTaskMap[key] = updatedToday;
            });
          },

          dailyTaskMap: dailyTaskMap,
          selectedDate: selectedDate,
          onDailyMapChanged: (newMap) {
            setState(() {
              dailyTaskMap = newMap;
            });
          },
        );
        break;
      case 5:
        currentWidget = ShopCategory(onNext: goNext, pet: pet, user: widget.user,  pageType: 1,);
        break;

      case 6:
        currentWidget = SettingsPage(
          onNext: goNext,
          isDarkMode: widget.user.setting?['darkMode'] ?? false,
          soundEffectsEnabled: widget.user.setting?['sound'] ?? true,
          notificationsEnabled: widget.user.setting?['push'] ?? false,
          sortingMethod: widget.user.setting?['listSort'] ?? 'default',
          onDarkModeChanged: widget.onDarkModeChanged,
          onNotificationsChanged: widget.onPushChanged,
          onChangeSortingMethod: widget.onSortingChanged,
          onSoundEffectsChanged: widget.onSoundEffectsChanged,
        );
        break;

      default:
        currentWidget = const Text('기본');
    }

    return Scaffold(
        body: currentWidget
    );
  }
}
