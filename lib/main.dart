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
  // 🔸 탭 인덱스를 상위에서 관리
  int _currentIndex = 0;

  Users user = Users(
    currentPoint: 0,
    gotPoint: 0,
    nowPet: "",
    setting: {},
    statistics: {},
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
    final String fallbackUid = 'HiHgtVpIvdyCZVtiFCOc';
    final String uid = FirebaseAuth.instance.currentUser?.uid ?? fallbackUid;

    final doc1 =
    await FirebaseFirestore.instance.collection('Users').doc(uid).get();

    setState(() {
      if (doc1.exists) {
        user = Users.fromMap(doc1.data() as Map<String, dynamic>);
      } else {
        user = Users(
          currentPoint: 0,
          gotPoint: 0,
          nowPet: "",
          setting: {},
          statistics: {},
        );
      }
      isLoading = false;
    });
  }

  // ---------- 설정 저장(로컬 즉시 + Firestore merge) ----------
  Future<void> _setUserSetting(String key, dynamic value) async {
    setState(() {
      user.setting[key] = value;
    });
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    await FirebaseFirestore.instance
        .collection('Users')
        .doc(uid)
        .set({'setting': {key: value}}, SetOptions(merge: true));
  }

  void toggleDarkMode(bool v) => _setUserSetting('darkMode', v);
  void togglePushNotification(bool v) => _setUserSetting('push', v);
  void toggleSortingMethod(String v) => _setUserSetting('listSort', v);
  void toggleSoundEffects(bool v) => _setUserSetting('sound', v);
  // -----------------------------------------------------------

  // 🔸 하위 페이지들이 사용할 네비게이션 콜백
  void _setIndex(int i) {
    if (_currentIndex == i) return;
    setState(() {
      _currentIndex = i;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const MaterialApp(
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }
    return MaterialApp(
      title: 'TaskMate',
      theme: ThemeData.light().copyWith(
        bottomAppBarTheme: const BottomAppBarTheme(color: Colors.white),
      ),
      darkTheme: ThemeData.dark().copyWith(
        iconTheme: const IconThemeData(color: Colors.white),
        bottomAppBarTheme: BottomAppBarTheme(color: Colors.grey[900]),
      ),
      themeMode:
      (user.setting['darkMode'] == true) ? ThemeMode.dark : ThemeMode.light,
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
                body: Center(child: CircularProgressIndicator()));
          }

          if (snapshot.hasData && snapshot.data != null) {
            final String uid = snapshot.data!.uid;
            final userDocRef =
            FirebaseFirestore.instance.collection('Users').doc(uid);

            // Users/{uid} 변경 시에도 MyHomePage는 유지, props만 업데이트
            return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              stream: userDocRef.snapshots(),
              builder: (context, uSnap) {
                if (uSnap.hasError) {
                  return Scaffold(
                    body: Center(
                        child: Text('Firestore 오류: ${uSnap.error}')),
                  );
                }

                Users loadedUser;
                if (!uSnap.hasData || !(uSnap.data?.exists ?? false)) {
                  loadedUser = Users.fromMap({
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
                } else {
                  final raw = Map<String, dynamic>.from(uSnap.data!.data()!);
                  raw['currentPoint'] = (raw['currentPoint'] ?? 0) as int;
                  raw['gotPoint'] = (raw['gotPoint'] ?? 0) as int;
                  raw['nowPet'] = (raw['nowPet'] ?? '') as String;
                  raw['setting'] = (raw['setting'] is Map<String, dynamic>)
                      ? Map<String, dynamic>.from(raw['setting'])
                      : <String, dynamic>{};
                  raw['setting']['darkMode'] =
                      raw['setting']['darkMode'] ?? false;
                  raw['setting']['push'] = raw['setting']['push'] ?? false;
                  raw['setting']['listSort'] =
                      raw['setting']['listSort'] ?? 'default';
                  raw['setting']['sound'] = raw['setting']['sound'] ?? true;
                  raw['statistics'] =
                  (raw['statistics'] is Map<String, dynamic>)
                      ? Map<String, dynamic>.from(raw['statistics'])
                      : <String, dynamic>{};
                  try {
                    loadedUser = Users.fromMap(raw);
                  } catch (_) {
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
                }

                final nowPetId = loadedUser.nowPet;
                final petDocRef = userDocRef.collection("Pets").doc(nowPetId);
                print("pet id is ${nowPetId}");
                
                return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                  stream: petDocRef.snapshots(),
                  builder: (context, petSnap) {
                    if (!petSnap.hasData) {
                      return const Scaffold(body: Center(child: CircularProgressIndicator()));
                    }

                    final petData = petSnap.data!.data();
                    Pets pet = Pets.fromMap(petData!);

                    return MyHomePage(
                      title: "Virtual Pet",
                      user: user,
                      pet: pet,
                      currentIndex: _currentIndex,   // 🔸 상위에서 관리
                      setIndex: _setIndex,           // 🔸 콜백
                      onDarkModeChanged: toggleDarkMode,
                      onPushChanged: togglePushNotification,
                      onSortingChanged: toggleSortingMethod,
                      onSoundEffectsChanged: toggleSoundEffects,
                      onPointsAdded: _onPointsAdded,
                    );
                  },
                );

                // return MyHomePage(
                //   title: 'Virtual Pet',
                //   user: loadedUser,
                //   currentIndex: _currentIndex,   // 🔸 상위에서 관리
                //   setIndex: _setIndex,           // 🔸 콜백
                //   onDarkModeChanged: toggleDarkMode,
                //   onPushChanged: togglePushNotification,
                //   onSortingChanged: toggleSortingMethod,
                //   onSoundEffectsChanged: toggleSoundEffects,
                //   onPointsAdded: _onPointsAdded,
                // );
              },
            );
          }

          return const LoginPage();
        },
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final Users user;
  final Pets pet;
  final int currentIndex;              // 🔸 외부에서 전달
  final void Function(int) setIndex;   // 🔸 외부 콜백

  final Function(bool) onDarkModeChanged;
  final Function(bool) onPushChanged;
  final Function(String) onSortingChanged;
  final Function(bool) onSoundEffectsChanged;
  final Function(int) onPointsAdded;

  const MyHomePage({
    required this.title,
    required this.user,
    required this.pet,
    required this.currentIndex,
    required this.setIndex,
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
  // Pets pet = Pets(
  //   image: "",
  //   name: "",
  //   hunger: 0,
  //   happy: 0,
  //   level: 0,
  //   currentExp: 0,
  //   styleID: "",
  // );

  @override
  void initState() {
    super.initState();
    initAsync();
  }

  Future<void> initAsync() async {
    // await loadPets();
    await BgmManager.preload('bgm2.wav');
    await BgmManager.preload('bgm1.mp3');
  }

  // Future<void> loadPets() async {
  //   final String fallbackUid = 'HiHgtVpIvdyCZVtiFCOc';
  //   final String uid = FirebaseAuth.instance.currentUser?.uid ?? fallbackUid;

  //   final String petId =
  //   (widget.user.nowPet.isNotEmpty)
  //       ? widget.user.nowPet
  //       : 'default';

  //   final petDoc = await FirebaseFirestore.instance
  //       .collection('Users')
  //       .doc(uid)
  //       .collection('pets')
  //       .doc(petId)
  //       .get();

  //   final Pets loadedItems2;
  //   if (petDoc.exists) {
  //     final data = petDoc.data() as Map<String, dynamic>;
  //     loadedItems2 = Pets.fromMap(data);
  //   } else {
  //     loadedItems2 = Pets(
  //       image: "",
  //       name: "",
  //       hunger: 0,
  //       happy: 0,
  //       level: 100,
  //       currentExp: 0,
  //       styleID: "",
  //     );
  //   }

  //   setState(() => pet = loadedItems2);
  // }

  Map<String, List<Task>> dailyTaskMap = {};
  DateTime selectedDate = DateTime.now();
  String _dateKey(DateTime date) =>
      "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

  void goNext(int index) => widget.setIndex(index); // 🔸 상위 콜백 사용

  @override
  Widget build(BuildContext context) {
    final idx = widget.currentIndex; // 🔸 로컬 state 대신 props 사용
    Widget currentWidget;


    print("pet in myhomepage: ${widget.pet.toMap()}");
    switch (idx) {
      case 0:
        currentWidget = Petmain(
          onNext: goNext,
          pet: widget.pet,
          user: widget.user,
          pageType: 0,
          soundEffectsOn: widget.user.setting['sound'] ?? true,
        );
        break;
      case 1:
        currentWidget =
            ItemCategory(onNext: goNext, pet: widget.pet, user: widget.user, pageType: 1);
        break;
      case 2:
        currentWidget = PetChoose(onNext: goNext);
        break;
      case 3:
        currentWidget = PlannerMain(
          onNext: goNext,
          sortingMethod: widget.user.setting['listSort'] ?? 'default',
          onPointsAdded: widget.onPointsAdded,
        );
        break;
      case 4:
        currentWidget = PlannerEditPage(
          onNext: goNext,
          onBackToMain: () => goNext(3),
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
        currentWidget =
            ShopCategory(onNext: goNext, pet: widget.pet, user: widget.user, pageType: 1);
        break;
      case 6:
        currentWidget = SettingsPage(
          onNext: goNext,
          isDarkMode: widget.user.setting['darkMode'] ?? false,
          soundEffectsEnabled: widget.user.setting['sound'] ?? true,
          notificationsEnabled: widget.user.setting['push'] ?? false,
          sortingMethod: widget.user.setting['listSort'] ?? 'default',
          onDarkModeChanged: widget.onDarkModeChanged,
          onNotificationsChanged: widget.onPushChanged,
          onChangeSortingMethod: widget.onSortingChanged,
          onSoundEffectsChanged: widget.onSoundEffectsChanged,
        );
        break;
      default:
        currentWidget = const Text('기본');
    }

    return Scaffold(body: currentWidget);
  }
}
