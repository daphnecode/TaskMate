import 'package:flutter/material.dart';
import 'DBtest/api_service.dart';
import 'petmain.dart';
import 'object.dart';
import 'package:taskmate/utils/icon_utis.dart';
import 'package:firebase_auth/firebase_auth.dart';

String nameChange(String name) {
  String result;
  switch (name) {
    case "assets/images/prairie.png":
      result = "prairie";
    case "assets/images/beach.png":
      result = "beach";
    case "assets/images/forest.png":
      result = "forest";
    case "assets/images/cloud.png":
      result = "cloud";
    case "assets/images/volcano.png":
      result = "volcano";
    case "assets/images/nightcity.png":
      result = "nightcity";
    default:
      result = "assets/images/prairie.png";
  }
  return result;
}

class ItemlistPage1 extends StatefulWidget {
  final void Function(int) onNext;
  final Pets? pet;
  final Users user;
  final int pageType;
  const ItemlistPage1({
    required this.onNext,
    required this.pet,
    required this.user,
    required this.pageType,
    super.key,
  });

  @override
  State<ItemlistPage1> createState() => _ItemlistPage1State();
}

class _ItemlistPage1State extends State<ItemlistPage1> {
  List<Item>? inventory; // null이면 아직 로딩 중

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    final result = await readItemList(1);
    setState(() {
      inventory = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (inventory == null) {
      return Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          Expanded(
            flex: 6,
            child: Container(
              color: Theme.of(context).scaffoldBackgroundColor,
              child: Mainarea(
                key: ValueKey(widget.pet!.name),
                onNext: widget.onNext,
                pet: widget.pet,
                user: widget.user,
                pageType: widget.pageType,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.all(8.0),
              color: Colors.blue,
              child: Row(
                children: [
                  Image.asset(
                    "assets/icons/icon-list-alt.png",
                    width: 30,
                    height: 30,
                  ),
                  SizedBox(width: 10.0),
                  Text(
                    "창고 - 음식",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Container(
              padding: EdgeInsets.all(8.0),
              color: Theme.of(context).scaffoldBackgroundColor,
              child: (inventory == null)
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: inventory!.length,
                      itemBuilder: (context, index) {
                        final item = inventory![index];
                        return ListTile(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: Center(child: Text(item.name)),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    getThemedIcon(
                                      context,
                                      item.icon,
                                      width: 100,
                                      height: 100,
                                    ),
                                    SizedBox(height: 10),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            "포만도 +${item.hunger}",
                                            style: TextStyle(fontSize: 16),
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            "행복도 +${item.happy}",
                                            style: TextStyle(fontSize: 16),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 10),
                                    Text(
                                      item.itemText,
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    child: Text('취소'),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                  ),
                                  TextButton(
                                    child: Text('사용'),
                                    onPressed: () async {
                                      if (item.count > 0) {
                                        setState(() {
                                          item.count--;
                                          widget.pet!.hunger += item.hunger;
                                          widget.pet!.happy += item.happy;
                                        });
                                        // ✅ 현재 로그인한 사용자 uid 사용
                                        final uid = FirebaseAuth
                                            .instance
                                            .currentUser
                                            ?.uid;
                                        if (uid != null) {
                                          await useItem(item.name);
                                        }
                                      }
                                      Navigator.pop(context);
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                          leading: getThemedIcon(
                            context,
                            item.icon,
                            width: 30,
                            height: 30,
                          ),
                          title: Text(
                            item.name,
                            style: TextStyle(fontSize: 18),
                          ),
                          trailing: Text(
                            '${item.count}개',
                            style: TextStyle(fontSize: 16),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
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
                onPressed: () {
                  Navigator.pop(context);
                  widget.onNext(3); // Navigate to PlannerMain
                },
              ),

              IconButton(
                icon: Icon(Icons.home),
                onPressed: () {
                  Navigator.pop(context);
                  widget.onNext(0);
                },
              ),
              IconButton(
                icon: Icon(Icons.settings),
                onPressed: () {
                  Navigator.pop(context);
                  widget.onNext(6);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ShoplistPage1 extends StatefulWidget {
  final void Function(int) onNext;
  final Pets? pet;
  final Users user;
  final int pageType;
  const ShoplistPage1({
    required this.onNext,
    required this.pet,
    required this.user,
    required this.pageType,
    super.key,
  });

  @override
  State<ShoplistPage1> createState() => _ShoplistPage1State();
}

class _ShoplistPage1State extends State<ShoplistPage1> {
  List<Item>? inventory; // null이면 아직 로딩 중

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    final result = await readShopList(1);
    setState(() {
      inventory = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (inventory == null) {
      return Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          Expanded(
            flex: 6,
            child: Container(
              color: Theme.of(context).scaffoldBackgroundColor,
              child: Mainarea(
                key: ValueKey(widget.pet!.name),
                onNext: widget.onNext,
                pet: widget.pet,
                user: widget.user,
                pageType: widget.pageType,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.all(8.0),
              color: Colors.blue,
              child: Row(
                children: [
                  Image.asset(
                    "assets/icons/icon-store.png",
                    width: 30,
                    height: 30,
                  ),
                  SizedBox(width: 10.0),
                  Text(
                    "상점 - 음식",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Expanded(
                    child: Container(
                      alignment: Alignment.centerRight,
                      child: Text(
                        "${widget.user.currentPoint}pt",
                        style: TextStyle(
                          fontSize: 24,
                          color: Colors.yellowAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Container(
              padding: EdgeInsets.all(8.0),
              color: Theme.of(context).scaffoldBackgroundColor,
              child: (inventory == null)
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: inventory!.length,
                      itemBuilder: (context, index) {
                        final item = inventory![index];
                        return ListTile(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: Center(child: Text(item.name)),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    getThemedIcon(
                                      context,
                                      item.icon,
                                      width: 100,
                                      height: 100,
                                    ),
                                    SizedBox(height: 10),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            "포만도 +${item.hunger}",
                                            style: TextStyle(fontSize: 16),
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            "행복도 +${item.happy}",
                                            style: TextStyle(fontSize: 16),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 10),
                                    Text(
                                      '가격은 ${item.price}pt입니다.',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    child: Text('취소'),
                                    onPressed: () => Navigator.pop(context),
                                  ),
                                  TextButton(
                                    child: Text('구매'),
                                    onPressed: () async {
                                      if (item.price <
                                          widget.user.currentPoint) {
                                        setState(() {
                                          widget.user.currentPoint -=
                                              item.price;
                                          item.count++;
                                        });
                                        // ✅ 현재 로그인한 사용자 uid 사용
                                        final uid = FirebaseAuth
                                            .instance
                                            .currentUser
                                            ?.uid;
                                        if (uid != null) {
                                          await buyItem(item.name);
                                        }
                                      }
                                      Navigator.pop(context);
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                          leading: getThemedIcon(
                            context,
                            item.icon,
                            width: 30,
                            height: 30,
                          ),
                          title: Text(
                            item.name,
                            style: TextStyle(fontSize: 18),
                          ),
                          trailing: Text(
                            '${item.price}pt',
                            style: TextStyle(fontSize: 16),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
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
                onPressed: () {
                  Navigator.pop(context);
                  widget.onNext(3); // Navigate to PlannerMain
                },
              ),

              IconButton(
                icon: Icon(Icons.home),
                onPressed: () {
                  Navigator.pop(context);
                  widget.onNext(0);
                },
              ),
              IconButton(
                icon: Icon(Icons.settings),
                onPressed: () {
                  Navigator.pop(context);
                  widget.onNext(6);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ItemlistPage2 extends StatefulWidget {
  final void Function(int) onNext;
  final Pets? pet;
  final Users user;
  final int pageType;
  const ItemlistPage2({
    required this.onNext,
    required this.pet,
    required this.user,
    required this.pageType,
    super.key,
  });

  @override
  State<ItemlistPage2> createState() => _ItemlistPage2State();
}

class _ItemlistPage2State extends State<ItemlistPage2> {
  List<Item>? inventory; // null이면 아직 로딩 중

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    final result = await readItemList(2);
    setState(() {
      inventory = result;
    });
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
              child: Mainarea(
                key: ValueKey(widget.pet!.name),
                onNext: widget.onNext,
                pet: widget.pet,
                user: widget.user,
                pageType: widget.pageType,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.all(8.0),
              color: Colors.blue,
              child: Row(
                children: [
                  Image.asset(
                    "assets/icons/icon-list-alt.png",
                    width: 30,
                    height: 30,
                  ),
                  SizedBox(width: 10.0),
                  Text(
                    "창고 - 장난감",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Container(
              padding: EdgeInsets.all(8.0),
              color: Theme.of(context).scaffoldBackgroundColor,
              child: (inventory == null)
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: inventory!.length,
                      itemBuilder: (context, index) {
                        final item = inventory![index];
                        return ListTile(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: Center(child: Text(item.name)),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    getThemedIcon(
                                      context,
                                      item.icon,
                                      width: 100,
                                      height: 100,
                                    ),
                                    SizedBox(height: 10),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            "행복도 +${item.happy}",
                                            style: TextStyle(fontSize: 16),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 10),
                                    Text(
                                      item.itemText,
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    child: Text('취소'),
                                    onPressed: () => Navigator.pop(context),
                                  ),
                                  TextButton(
                                    child: Text('사용'),
                                    onPressed: () async {
                                      if (item.count > 0) {
                                        setState(() {
                                          item.count--;
                                          widget.pet!.happy += item.happy;
                                        });
                                        // ✅ 현재 로그인한 사용자 uid 사용
                                        final uid = FirebaseAuth
                                            .instance
                                            .currentUser
                                            ?.uid;
                                        if (uid != null) {
                                          await useItem(item.name);
                                        }
                                      }
                                      Navigator.pop(context);
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                          leading: getThemedIcon(
                            context,
                            item.icon,
                            width: 30,
                            height: 30,
                          ),
                          title: Text(
                            item.name,
                            style: TextStyle(fontSize: 18),
                          ),
                          trailing: Text(
                            '${item.count}개',
                            style: TextStyle(fontSize: 16),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
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
                onPressed: () {
                  Navigator.pop(context);
                  widget.onNext(3); // Navigate to PlannerMain
                },
              ),

              IconButton(
                icon: Icon(Icons.home),
                onPressed: () {
                  Navigator.pop(context);
                  widget.onNext(0);
                },
              ),
              IconButton(
                icon: Icon(Icons.settings),
                onPressed: () {
                  Navigator.pop(context);
                  widget.onNext(6);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ShoplistPage2 extends StatefulWidget {
  final void Function(int) onNext;
  final Pets? pet;
  final Users user;
  final int pageType;
  const ShoplistPage2({
    required this.onNext,
    required this.pet,
    required this.user,
    required this.pageType,
    super.key,
  });

  @override
  State<ShoplistPage2> createState() => _ShoplistPage2State();
}

class _ShoplistPage2State extends State<ShoplistPage2> {
  List<Item>? inventory; // null이면 아직 로딩 중

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    final result = await readShopList(2);
    setState(() {
      inventory = result;
    });
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
              child: Mainarea(
                key: ValueKey(widget.pet!.name),
                onNext: widget.onNext,
                pet: widget.pet,
                user: widget.user,
                pageType: widget.pageType,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.all(8.0),
              color: Colors.blue,
              child: Row(
                children: [
                  Image.asset(
                    "assets/icons/icon-store.png",
                    width: 30,
                    height: 30,
                  ),
                  SizedBox(width: 10.0),
                  Text(
                    "상점 - 장난감",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Expanded(
                    child: Container(
                      alignment: Alignment.centerRight,
                      child: Text(
                        "${widget.user.currentPoint}pt",
                        style: TextStyle(
                          fontSize: 24,
                          color: Colors.yellowAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Container(
              padding: EdgeInsets.all(8.0),
              color: Theme.of(context).scaffoldBackgroundColor,
              child: (inventory == null)
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: inventory!.length,
                      itemBuilder: (context, index) {
                        final item = inventory![index];
                        return ListTile(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: Center(child: Text(item.name)),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    getThemedIcon(
                                      context,
                                      item.icon,
                                      width: 100,
                                      height: 100,
                                    ),
                                    SizedBox(height: 10),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            "행복도 +${item.happy}",
                                            style: TextStyle(fontSize: 16),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 10),
                                    Text(
                                      '가격은 ${item.price}pt입니다.',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    child: Text('취소'),
                                    onPressed: () => Navigator.pop(context),
                                  ),
                                  TextButton(
                                    child: Text('구매'),
                                    onPressed: () async {
                                      if (item.price <
                                          widget.user.currentPoint) {
                                        setState(() {
                                          widget.user.currentPoint -=
                                              item.price;
                                          item.count++;
                                        });
                                        // ✅ 현재 로그인한 사용자 uid 사용
                                        final uid = FirebaseAuth
                                            .instance
                                            .currentUser
                                            ?.uid;
                                        if (uid != null) {
                                          await buyItem(item.name);
                                        }
                                      }
                                      Navigator.pop(context);
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                          leading: getThemedIcon(
                            context,
                            item.icon,
                            width: 30,
                            height: 30,
                          ),
                          title: Text(
                            item.name,
                            style: TextStyle(fontSize: 18),
                          ),
                          trailing: Text(
                            '${item.price}pt',
                            style: TextStyle(fontSize: 16),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
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
                onPressed: () {
                  Navigator.pop(context);
                  widget.onNext(3); // Navigate to PlannerMain
                },
              ),

              IconButton(
                icon: Icon(Icons.home),
                onPressed: () {
                  Navigator.pop(context);
                  widget.onNext(0);
                },
              ),
              IconButton(
                icon: Icon(Icons.settings),
                onPressed: () {
                  Navigator.pop(context);
                  widget.onNext(6);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ItemlistPage3 extends StatefulWidget {
  final void Function(int) onNext;
  final Pets? pet;
  final Users user;
  final int pageType;
  const ItemlistPage3({
    required this.onNext,
    required this.pet,
    required this.user,
    required this.pageType,
    super.key,
  });

  @override
  State<ItemlistPage3> createState() => _ItemlistPage3State();
}

class _ItemlistPage3State extends State<ItemlistPage3> {
  List<Item>? inventory; // null이면 아직 로딩 중

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    final result = await readItemList(3);
    setState(() {
      inventory = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.user.setting['placeID'] == "") {
      return Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          Expanded(
            flex: 6,
            child: Container(
              color: Theme.of(context).scaffoldBackgroundColor,
              child: Mainarea(
                key: ValueKey(widget.pet!.name),
                onNext: widget.onNext,
                pet: widget.pet,
                user: widget.user,
                pageType: widget.pageType,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.all(8.0),
              color: Colors.blue,
              child: Row(
                children: [
                  Image.asset(
                    "assets/icons/icon-list-alt.png",
                    width: 30,
                    height: 30,
                  ),
                  SizedBox(width: 10.0),
                  Text(
                    "창고 - 배경",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Container(
              padding: EdgeInsets.all(8.0),
              color: Theme.of(context).scaffoldBackgroundColor,
              child: (inventory == null)
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: inventory!.length,
                      itemBuilder: (context, index) {
                        final item = inventory![index];
                        final isHighlighted =
                            item.name ==
                            nameChange(widget.user.setting['placeID']);
                        return Container(
                          color: isHighlighted
                              ? (Theme.of(context).brightness == Brightness.dark
                                    ? Colors.grey
                                    : Colors.yellow)
                              : Colors.transparent,
                          child: ListTile(
                            onTap: () {
                              if (!isHighlighted) {
                                showDialog(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    title: Center(child: Text(item.name)),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        getThemedIcon(
                                          context,
                                          item.icon,
                                          width: 100,
                                          height: 100,
                                        ),
                                        SizedBox(height: 10),
                                        Text(
                                          item.itemText,
                                          style: TextStyle(fontSize: 16),
                                        ),
                                      ],
                                    ),
                                    actions: [
                                      TextButton(
                                        child: Text('취소'),
                                        onPressed: () => Navigator.pop(context),
                                      ),
                                      TextButton(
                                        child: Text('사용'),
                                        onPressed: () async {
                                          setState(() {
                                            widget.user.setting['placeID'] =
                                                "assets/images/${item.name}.png";
                                          });
                                          await usePlaceItem(item.name);
                                          Navigator.pop(context);
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              }
                            },
                            leading: getThemedIcon(
                              context,
                              item.icon,
                              width: 30,
                              height: 30,
                            ),
                            title: Text(
                              item.name,
                              style: TextStyle(fontSize: 18),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
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
                onPressed: () {
                  Navigator.pop(context);
                  widget.onNext(3); // Navigate to PlannerMain
                },
              ),

              IconButton(
                icon: Icon(Icons.home),
                onPressed: () {
                  Navigator.pop(context);
                  widget.onNext(0);
                },
              ),
              IconButton(
                icon: Icon(Icons.settings),
                onPressed: () {
                  Navigator.pop(context);
                  widget.onNext(6);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ShoplistPage3 extends StatefulWidget {
  final void Function(int) onNext;
  final Pets? pet;
  final Users user;
  final int pageType;
  const ShoplistPage3({
    required this.onNext,
    required this.pet,
    required this.user,
    required this.pageType,
    super.key,
  });

  @override
  State<ShoplistPage3> createState() => _ShoplistPage3State();
}

class _ShoplistPage3State extends State<ShoplistPage3> {
  List<Item>? inventory; // null이면 아직 로딩 중

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    final result = await readShopList(3);
    setState(() {
      inventory = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.user.setting['placeID'] == "") {
      return Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          Expanded(
            flex: 6,
            child: Container(
              color: Theme.of(context).scaffoldBackgroundColor,
              child: Mainarea(
                key: ValueKey(widget.pet!.name),
                onNext: widget.onNext,
                pet: widget.pet,
                user: widget.user,
                pageType: widget.pageType,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.all(8.0),
              color: Colors.blue,
              child: Row(
                children: [
                  Image.asset(
                    "assets/icons/icon-store.png",
                    width: 30,
                    height: 30,
                  ),
                  SizedBox(width: 10.0),
                  Text(
                    "상점 - 배경",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Expanded(
                    child: Container(
                      alignment: Alignment.centerRight,
                      child: Text(
                        "${widget.user.currentPoint}pt",
                        style: TextStyle(
                          fontSize: 24,
                          color: Colors.yellowAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Container(
              padding: EdgeInsets.all(8.0),
              color: Theme.of(context).scaffoldBackgroundColor,
              child: (inventory == null)
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: inventory!.length,
                      itemBuilder: (context, index) {
                        final item = inventory![index];
                        final check = (item.count != 0);

                        return Container(
                          color: check
                              ? (Theme.of(context).brightness == Brightness.dark
                                    ? Colors.grey
                                    : Colors.red)
                              : Colors.transparent,
                          child: ListTile(
                            onTap: () {
                              if (!check) {
                                showDialog(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    title: Center(child: Text(item.name)),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        getThemedIcon(
                                          context,
                                          item.icon,
                                          width: 100,
                                          height: 100,
                                        ),
                                        SizedBox(height: 10),
                                        Text(
                                          '가격은 ${item.price}pt입니다.',
                                          style: TextStyle(fontSize: 16),
                                        ),
                                      ],
                                    ),
                                    actions: [
                                      TextButton(
                                        child: Text('취소'),
                                        onPressed: () => Navigator.pop(context),
                                      ),
                                      TextButton(
                                        child: Text('구매'),
                                        onPressed: () async {
                                          if (item.price <
                                              widget.user.currentPoint) {
                                            setState(() {
                                              widget.user.currentPoint -=
                                                  item.price;
                                            });
                                            // ✅ 현재 로그인한 사용자 uid 사용
                                            await buyItem(item.name);
                                          }
                                          Navigator.pop(context);
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              }
                            },
                            leading: getThemedIcon(
                              context,
                              item.icon,
                              width: 30,
                              height: 30,
                            ),
                            title: Text(
                              item.name,
                              style: TextStyle(fontSize: 18),
                            ),
                            trailing: Text(
                              '${item.price}pt',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
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
                onPressed: () {
                  Navigator.pop(context);
                  widget.onNext(3); // Navigate to PlannerMain
                },
              ),

              IconButton(
                icon: Icon(Icons.home),
                onPressed: () {
                  Navigator.pop(context);
                  widget.onNext(0);
                },
              ),
              IconButton(
                icon: Icon(Icons.settings),
                onPressed: () {
                  Navigator.pop(context);
                  widget.onNext(6);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ItemlistPage4 extends StatefulWidget {
  final void Function(int) onNext;
  final Pets? pet;
  final Users user;
  final int pageType;
  const ItemlistPage4({
    required this.onNext,
    required this.pet,
    required this.user,
    required this.pageType,
    super.key,
  });

  @override
  State<ItemlistPage4> createState() => _ItemlistPage4State();
}

class _ItemlistPage4State extends State<ItemlistPage4> {
  String usedItem = "beach";
  List<Item>? inventory; // null이면 아직 로딩 중

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    final result = await readItemList(4);
    setState(() {
      inventory = result;
    });
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
              child: Mainarea(
                key: ValueKey(widget.pet!.name),
                onNext: widget.onNext,
                pet: widget.pet,
                user: widget.user,
                pageType: widget.pageType,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.all(8.0),
              color: Colors.blue,
              child: Row(
                children: [
                  Image.asset(
                    "assets/icons/icon-list-alt.png",
                    width: 30,
                    height: 30,
                  ),
                  SizedBox(width: 10.0),
                  Text(
                    "창고 - 스타일",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Container(
              padding: EdgeInsets.all(8.0),
              color: Theme.of(context).scaffoldBackgroundColor,
              child: (inventory == null)
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: inventory!.length,
                      itemBuilder: (context, index) {
                        final item = inventory![index];
                        final isHighlighted = item.name == usedItem;

                        return Container(
                          color: isHighlighted
                              ? (Theme.of(context).brightness == Brightness.dark
                                    ? Colors.grey
                                    : Colors.yellow)
                              : Colors.transparent,
                          child: ListTile(
                            onTap: () {
                              if (!isHighlighted) {
                                showDialog(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    title: Center(child: Text(item.name)),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        getThemedIcon(
                                          context,
                                          item.icon,
                                          width: 100,
                                          height: 100,
                                        ),
                                        SizedBox(height: 10),
                                        Text(
                                          item.itemText,
                                          style: TextStyle(fontSize: 16),
                                        ),
                                      ],
                                    ),
                                    actions: [
                                      TextButton(
                                        child: Text('취소'),
                                        onPressed: () => Navigator.pop(context),
                                      ),
                                      TextButton(
                                        child: Text('사용'),
                                        onPressed: () async {
                                          setState(() {
                                            usedItem = item.name;
                                          });
                                          // ✅ 현재 로그인한 사용자 uid 사용
                                          await useStyleItem(item.name);
                                          Navigator.pop(context);
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              }
                            },
                            leading: getThemedIcon(
                              context,
                              item.icon,
                              width: 30,
                              height: 30,
                            ),
                            title: Text(
                              item.name,
                              style: TextStyle(fontSize: 18),
                            ),
                            trailing: Text(
                              '${item.count}',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
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
                onPressed: () {
                  Navigator.pop(context);
                  widget.onNext(3); // Navigate to PlannerMain
                },
              ),

              IconButton(
                icon: Icon(Icons.home),
                onPressed: () {
                  Navigator.pop(context);
                  widget.onNext(0);
                },
              ),
              IconButton(
                icon: Icon(Icons.settings),
                onPressed: () {
                  Navigator.pop(context);
                  widget.onNext(6);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ShoplistPage4 extends StatefulWidget {
  final void Function(int) onNext;
  final Pets? pet;
  final Users user;
  final int pageType;
  const ShoplistPage4({
    required this.onNext,
    required this.pet,
    required this.user,
    required this.pageType,
    super.key,
  });

  @override
  State<ShoplistPage4> createState() => _ShoplistPage4State();
}

class _ShoplistPage4State extends State<ShoplistPage4> {
  List<Item>? inventory; // null이면 아직 로딩 중

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    final result = await readShopList(4);
    setState(() {
      inventory = result;
    });
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
              child: Mainarea(
                key: ValueKey(widget.pet!.name),
                onNext: widget.onNext,
                pet: widget.pet,
                user: widget.user,
                pageType: widget.pageType,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.all(8.0),
              color: Colors.blue,
              child: Row(
                children: [
                  Image.asset(
                    "assets/icons/icon-store.png",
                    width: 30,
                    height: 30,
                  ),
                  SizedBox(width: 10.0),
                  Text(
                    "상점 - 스타일",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Expanded(
                    child: Container(
                      alignment: Alignment.centerRight,
                      child: Text(
                        "${widget.user.currentPoint}pt",
                        style: TextStyle(
                          fontSize: 24,
                          color: Colors.yellowAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Container(
              padding: EdgeInsets.all(8.0),
              color: Theme.of(context).scaffoldBackgroundColor,
              child: (inventory == null)
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: inventory!.length,
                      itemBuilder: (context, index) {
                        final item = inventory![index];
                        final check = (item.count != 0);
                        return Container(
                          color: check
                              ? (Theme.of(context).brightness == Brightness.dark
                                    ? Colors.grey
                                    : Colors.red)
                              : Colors.transparent,
                          child: ListTile(
                            onTap: () {
                              if (!check) {
                                showDialog(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    title: Center(child: Text(item.name)),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        getThemedIcon(
                                          context,
                                          item.icon,
                                          width: 100,
                                          height: 100,
                                        ),
                                        SizedBox(height: 10),
                                        Text(
                                          '가격은 ${item.price}pt입니다.',
                                          style: TextStyle(fontSize: 16),
                                        ),
                                      ],
                                    ),
                                    actions: [
                                      TextButton(
                                        child: Text('취소'),
                                        onPressed: () => Navigator.pop(context),
                                      ),
                                      TextButton(
                                        child: Text('구매'),
                                        onPressed: () async {
                                          if (item.price <
                                              widget.user.currentPoint) {
                                            setState(() {
                                              widget.user.currentPoint -=
                                                  item.price;
                                            });
                                            await buyItem(item.name);
                                          }
                                          Navigator.pop(context);
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              }
                            },
                            leading: getThemedIcon(
                              context,
                              item.icon,
                              width: 30,
                              height: 30,
                            ),
                            title: Text(
                              item.name,
                              style: TextStyle(fontSize: 18),
                            ),
                            trailing: Text(
                              '${item.price}pt',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
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
                onPressed: () {
                  Navigator.pop(context);
                  widget.onNext(3); // Navigate to PlannerMain
                },
              ),

              IconButton(
                icon: Icon(Icons.home),
                onPressed: () {
                  Navigator.pop(context);
                  widget.onNext(0);
                },
              ),
              IconButton(
                icon: Icon(Icons.settings),
                onPressed: () {
                  Navigator.pop(context);
                  widget.onNext(6);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ItemCategory extends StatefulWidget {
  final void Function(int) onNext;
  final Pets? pet;
  final Users user;
  final int pageType;
  const ItemCategory({
    required this.onNext,
    required this.pet,
    required this.user,
    required this.pageType,
    super.key,
  });

  @override
  State<ItemCategory> createState() => _ItemCategoryState();
}

class _ItemCategoryState extends State<ItemCategory> {
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
              child: Mainarea(
                key: ValueKey(widget.pet!.name),
                onNext: widget.onNext,
                pet: widget.pet,
                user: widget.user,
                pageType: widget.pageType,
              ),
              // MainArea()로 변경
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.all(8.0),
              color: Colors.blue,
              child: Row(
                children: [
                  Image.asset(
                    "assets/icons/icon-list-alt.png",
                    width: 30,
                    height: 30,
                  ),
                  SizedBox(width: 10.0),
                  Text(
                    "창고",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Container(
              padding: EdgeInsets.all(8.0),
              color: Theme.of(context).scaffoldBackgroundColor,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ItemlistPage1(
                                    onNext: widget.onNext,
                                    pet: widget.pet,
                                    user: widget.user,
                                    pageType: 2,
                                  ),
                                ),
                              ).then((value) {
                                setState(() {});
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[100],
                            ),
                            child: Center(
                              child: Image.asset(
                                "assets/icons/icon-chicken.png",
                                width: 30,
                                height: 30,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 10.0),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ItemlistPage2(
                                    onNext: widget.onNext,
                                    pet: widget.pet,
                                    user: widget.user,
                                    pageType: 2,
                                  ),
                                ),
                              ).then((value) {
                                setState(() {});
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[100],
                            ),
                            child: Center(
                              child: Image.asset(
                                "assets/icons/icon-teddybear.png",
                                width: 30,
                                height: 30,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10.0),
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ItemlistPage3(
                                    onNext: widget.onNext,
                                    pet: widget.pet,
                                    user: widget.user,
                                    pageType: 2,
                                  ),
                                ),
                              ).then((value) {
                                setState(() {});
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[100],
                            ),
                            child: Center(
                              child: Image.asset(
                                "assets/icons/icon-mountains.png",
                                width: 30,
                                height: 30,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 10.0),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ItemlistPage4(
                                    onNext: widget.onNext,
                                    pet: widget.pet,
                                    user: widget.user,
                                    pageType: 2,
                                  ),
                                ),
                              ).then((value) {
                                setState(() {});
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[100],
                            ),
                            child: Center(
                              child: Image.asset(
                                "assets/icons/icon-pivotx.png",
                                width: 30,
                                height: 30,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // SubArea()로 변경
            ),
          ),
        ],
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
                onPressed: () {
                  widget.onNext(3); // Navigate to PlannerMain
                },
              ),

              IconButton(
                icon: Icon(Icons.home),
                onPressed: () {
                  widget.onNext(0);
                },
              ),
              IconButton(
                icon: Icon(Icons.settings),
                onPressed: () {
                  Navigator.pop(context);
                  widget.onNext(6);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ShopCategory extends StatefulWidget {
  final void Function(int) onNext;
  final Pets? pet;
  final Users user;
  final int pageType;
  const ShopCategory({
    required this.onNext,
    required this.pet,
    required this.user,
    required this.pageType,
    super.key,
  });

  @override
  State<ShopCategory> createState() => _ShopCategoryState();
}

class _ShopCategoryState extends State<ShopCategory> {
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
              child: Mainarea(
                key: ValueKey(widget.pet!.name),
                onNext: widget.onNext,
                pet: widget.pet,
                user: widget.user,
                pageType: widget.pageType,
              ),
              // MainArea()로 변경
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.all(8.0),
              color: Colors.blue,
              child: Row(
                children: [
                  Image.asset(
                    "assets/icons/icon-store.png",
                    width: 30,
                    height: 30,
                  ),
                  SizedBox(width: 10.0),
                  Text(
                    "상점",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Expanded(
                    child: Container(
                      alignment: Alignment.centerRight,
                      child: Text(
                        "${widget.user.currentPoint}pt",
                        style: TextStyle(
                          fontSize: 24,
                          color: Colors.yellowAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Container(
              padding: EdgeInsets.all(8.0),
              color: Theme.of(context).scaffoldBackgroundColor,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ShoplistPage1(
                                    onNext: widget.onNext,
                                    pet: widget.pet,
                                    user: widget.user,
                                    pageType: 3,
                                  ),
                                ),
                              ).then((value) {
                                setState(() {});
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[100],
                            ),
                            child: Center(
                              child: Image.asset(
                                "assets/icons/icon-chicken.png",
                                width: 30,
                                height: 30,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 10.0),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ShoplistPage2(
                                    onNext: widget.onNext,
                                    pet: widget.pet,
                                    user: widget.user,
                                    pageType: 3,
                                  ),
                                ),
                              ).then((value) {
                                setState(() {});
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[100],
                            ),
                            child: Center(
                              child: Image.asset(
                                "assets/icons/icon-teddybear.png",
                                width: 30,
                                height: 30,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10.0),
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ShoplistPage3(
                                    onNext: widget.onNext,
                                    pet: widget.pet,
                                    user: widget.user,
                                    pageType: 3,
                                  ),
                                ),
                              ).then((value) {
                                setState(() {});
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[100],
                            ),
                            child: Center(
                              child: Image.asset(
                                "assets/icons/icon-mountains.png",
                                width: 30,
                                height: 30,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 10.0),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ShoplistPage4(
                                    onNext: widget.onNext,
                                    pet: widget.pet,
                                    user: widget.user,
                                    pageType: 3,
                                  ),
                                ),
                              ).then((value) {
                                setState(() {});
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[100],
                            ),
                            child: Center(
                              child: Image.asset(
                                "assets/icons/icon-pivotx.png",
                                width: 30,
                                height: 30,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // SubArea()로 변경
            ),
          ),
        ],
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
                onPressed: () {
                  widget.onNext(3); // Navigate to PlannerMain
                },
              ),

              IconButton(
                icon: Icon(Icons.home),
                onPressed: () {
                  widget.onNext(0);
                },
              ),
              IconButton(
                icon: Icon(Icons.settings),
                onPressed: () {
                  Navigator.pop(context);
                  widget.onNext(6);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
