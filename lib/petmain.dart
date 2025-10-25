import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'widgets/button.dart';
import 'object.dart';
import 'petchoose.dart';
import 'petstatus.dart';

// 청소게임
import 'clean_game_screen.dart';
// 장애물달리기게임
import 'run_game_screen.dart';

// 화면 상단 구성
class Mainarea extends StatefulWidget {
  final void Function(int) onNext;
  final Pets? pet;
  final Users user;
  final int pageType;
  const Mainarea({
    required this.onNext,
    required this.pet,
    required this.user,
    required this.pageType,
    super.key,
  });

  @override
  State<Mainarea> createState() => _MainareaState();
}

class _MainareaState extends State<Mainarea> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 미리 이미지 로딩
    precacheImage(const AssetImage('assets/icons/icon-heart.png'), context);
    precacheImage(const AssetImage('assets/icons/icon-heartW.png'), context);
    precacheImage(
      const AssetImage('assets/icons/icon-chickenalt.png'),
      context,
    );
    precacheImage(
      const AssetImage('assets/icons/icon-chickenaltW.png'),
      context,
    );
  }

  @override
  Widget build(BuildContext context) {
    final String placeAsset = (widget.user.setting['placeID'] ?? '') as String;
    print(widget.user.setting['placeID']);
    final String petAsset = widget.pet!.image;

    return Column(
      children: [
        PetStatArea(
          pet: widget.pet,
          user: widget.user,
          pageType: widget.pageType,
        ),
        Expanded(
          child: GestureDetector(
            onLongPress: () async {
              // 펫 선택 화면 → Pets 객체 반환
              final result = await Navigator.push<String>(
                context,
                MaterialPageRoute(
                  builder: (_) => PetChoose(onNext: widget.onNext),
                ),
              );
              if (!mounted || result == null) return;

              // 즉시 반영
            },
            child: AspectRatio(
              aspectRatio: 1 / 1,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final w = constraints.maxWidth;
                  final h = constraints.maxHeight;

                  Widget background;
                  if (placeAsset.isNotEmpty) {
                    background = Image.asset(
                      placeAsset,
                      fit: BoxFit.cover,
                      width: w,
                      height: h,
                    );
                  } else {
                    background = Container(
                      width: w,
                      height: h,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFFEDF2FF), Color(0xFFF8F9FA)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    );
                  }

                  Widget petWidget = const SizedBox.shrink();
                  if (petAsset.isNotEmpty) {
                    petWidget = Positioned(
                      left: w * 0.5,
                      top: h * 0.6,
                      child: Image.asset(
                        key: ValueKey(widget.pet!.name),
                        petAsset,
                        fit: BoxFit.cover,
                        height: h * 0.2,
                        width: w * 0.2,
                      ),
                    );
                  }

                  return Stack(children: [background, petWidget]);
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class Petmain extends StatefulWidget {
  final void Function(int) onNext;
  final Pets? pet;
  final Users user;
  final int pageType;
  final bool soundEffectsOn;
  const Petmain({
    required this.onNext,
    required this.pet,
    required this.user,
    required this.pageType,
    required this.soundEffectsOn,
    super.key,
  });

  @override
  State<Petmain> createState() => _PetmainState();
}

class _PetmainState extends State<Petmain> {
  bool _loadingPet = false;

  @override
  void initState() {
    super.initState();
    _fetchPetIfNeeded(); // 앱 켤 때 nowPet 기준으로 보정
  }

  @override
  void didUpdateWidget(covariant Petmain oldWidget) {
    super.didUpdateWidget(oldWidget);
    // nowPet 값이 바뀌거나(상위 스트림 갱신) 현재 이미지가 비어있으면 다시 로드
    if (oldWidget.user.nowPet != widget.user.nowPet ||
        widget.pet!.image.isEmpty) {
      _fetchPetIfNeeded();
    }
  }

  Future<void> _fetchPetIfNeeded() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final petId = widget.user.nowPet.isNotEmpty ? widget.user.nowPet : 'dragon';

    setState(() => _loadingPet = true);
    try {
      final snap = await FirebaseFirestore.instance
          .collection('Users')
          .doc(uid)
          .collection('pets')
          .doc(petId)
          .get();

      if (!mounted) return;

      if (snap.exists) {
        final data = snap.data() as Map<String, dynamic>;
        final loaded = Pets.fromMap(data);
        setState(() {
          widget.pet!.image = loaded.image;
          widget.pet!.name = loaded.name;
          widget.pet!.hunger = loaded.hunger;
          widget.pet!.happy = loaded.happy;
          widget.pet!.level = loaded.level;
          widget.pet!.currentExp = loaded.currentExp;
          widget.pet!.styleID = loaded.styleID;
        });
      }
    } finally {
      if (mounted) setState(() => _loadingPet = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          Expanded(
            flex: 6,
            child: Container(
              color: Theme.of(context).scaffoldBackgroundColor,
              child: _loadingPet
                  ? const Center(child: CircularProgressIndicator())
                  : Mainarea(
                      key: ValueKey(widget.pet!.name),
                      onNext: widget.onNext,
                      pet: widget.pet,
                      user: widget.user,
                      pageType: widget.pageType,
                    ),
            ),
          ),
          // 화면 하단 구성
          Expanded(
            flex: 4,
            child: Container(
              padding: const EdgeInsets.all(8.0),
              color: Theme.of(context).scaffoldBackgroundColor,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: mainButton(
                            onNext: widget.onNext,
                            buttonName: "창고",
                            icon: "assets/icons/icon-list-alt.png",
                            pageNumber: 1,
                          ),
                        ),
                        const SizedBox(width: 10.0),
                        Expanded(
                          child: mainButton(
                            onNext: widget.onNext,
                            buttonName: "상점",
                            icon: "assets/icons/icon-store.png",
                            pageNumber: 5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  Expanded(
                    child: Row(
                      children: [
                        // 청소
                        Expanded(
                          child: Stack(
                            children: [
                              ElevatedButton(
                                onPressed: () async {
                                  final uid =
                                      FirebaseAuth.instance.currentUser?.uid;
                                  if (uid == null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('로그인이 필요합니다.'),
                                      ),
                                    );
                                    return;
                                  }
                                  final petId = widget.user.nowPet.isNotEmpty
                                      ? widget.user.nowPet
                                      : 'dragon';

                                  final changed = await Navigator.push<bool>(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => CleanGameScreen(
                                        onNext: (int index) {
                                          Navigator.pop(context);
                                          widget.onNext(index);
                                        },
                                        soundEffectsOn: widget.soundEffectsOn,
                                        pet: widget.pet,
                                        uid: uid, // ✅ 하드코딩 제거
                                        petId: petId,
                                      ),
                                    ),
                                  );
                                  if (changed == true) {
                                    setState(() {});
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue[100],
                                ),
                                child: const Center(
                                  child: Text(
                                    "청소",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                              const Positioned(
                                left: 0,
                                top: 0,
                                child: CircleAvatar(
                                  backgroundColor: Colors.blueAccent,
                                  radius: 35,
                                  child: ImageAssetIcon(
                                    "assets/icons/icon-paintbrush.png",
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10.0),
                        // 놀이
                        Expanded(
                          child: Stack(
                            children: [
                              ElevatedButton(
                                onPressed: () async {
                                  final uid =
                                      FirebaseAuth.instance.currentUser?.uid;
                                  if (uid == null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('로그인이 필요합니다.'),
                                      ),
                                    );
                                    return;
                                  }
                                  final petId = widget.user.nowPet.isNotEmpty
                                      ? widget.user.nowPet
                                      : 'dragon';

                                  final changed = await Navigator.push<bool>(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => RunGameScreen(
                                        onNext: (int index) {
                                          Navigator.pop(context);
                                          widget.onNext(index);
                                        },
                                        pet: widget.pet,
                                        soundEffectsOn: widget.soundEffectsOn,
                                        uid: uid, // ✅ 하드코딩 제거
                                        petId: petId,
                                      ),
                                    ),
                                  );
                                  if (changed == true) {
                                    setState(() {});
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue[100],
                                ),
                                child: const Center(
                                  child: Text(
                                    "놀이",
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                              const Positioned(
                                left: 0,
                                top: 0,
                                child: CircleAvatar(
                                  backgroundColor: Colors.blueAccent,
                                  radius: 35,
                                  child: ImageAssetIcon(
                                    "assets/icons/icon-raceflag.png",
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      // 하단 앱바
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
                onPressed: () {}, // 현재 페이지
              ),
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () => widget.onNext(6),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 작은 헬퍼: CircleAvatar 안에서 asset 아이콘 쓰기
class ImageAssetIcon extends StatelessWidget {
  final String path;
  const ImageAssetIcon(this.path, {super.key});

  @override
  Widget build(BuildContext context) {
    return Image.asset(path, fit: BoxFit.fill, width: 50, height: 50);
  }
}
