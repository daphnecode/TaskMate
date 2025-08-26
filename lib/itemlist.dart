import 'package:flutter/material.dart';
import 'DBtest/firestore_service.dart';
import 'petmain.dart';
import 'object.dart';
import 'package:taskmate/utils/icon_utis.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  final Pets pet;
  final Users user;
  final int pageType;
  final bool isUseItem;
  final List<Item> inventory;
  const ItemlistPage1({
    required this.onNext,
    required this.pet,
    required this.user,
    required this.pageType,
    required this.isUseItem,
    required this.inventory,
    super.key});

  @override
  State<ItemlistPage1> createState() => _ItemlistPage1State();
}

class _ItemlistPage1State extends State<ItemlistPage1> {
  @override
  Widget build(BuildContext context) {
    if (widget.isUseItem) {
      return Scaffold(
        appBar: AppBar(),
        body: Column(
          children: [
            Expanded(
              flex: 6,
              child: Container(
                color: Theme.of(context).scaffoldBackgroundColor,
                child: Mainarea(onNext: widget.onNext, pet: widget.pet, user: widget.user, pageType: widget.pageType,),
              ),
            ),
            Expanded(
              flex: 1,
              child:Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.all(8.0),
                color: Colors.blue,
                child: Row(
                  children: [
                    Image.asset(
                      "assets/icons/icon-list-alt.png",
                      width: 30, height: 30,
                    ),
                    SizedBox(width: 10.0,),
                    Text("창고 - 음식",
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
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
                child: ListView.builder(
                  itemCount: widget.inventory.length,
                  itemBuilder: (context, index) {
                    final item = widget.inventory[index];
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
                                    Expanded(child: Text("포만도 +${item.hunger}", style: TextStyle(fontSize: 16),)),
                                    Expanded(child: Text("행복도 +${item.happy}", style: TextStyle(fontSize: 16),)),
                                  ],
                                ),
                                SizedBox(height: 10),
                                Text(item.itemText,
                                    style: TextStyle(fontSize: 16)),
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
                                  if(item.count > 0) {
                                    setState(() {
                                      item.count--;
                                      widget.pet.hunger += item.hunger;
                                      widget.pet.happy += item.happy;
                                    });
                                    // ✅ 현재 로그인한 사용자 uid 사용
                                    final uid = FirebaseAuth.instance.currentUser?.uid;
                                    if (uid != null) {
                                      await itemSaveDB(uid, item.name, item);
                                      await petSaveDB(uid, widget.user.nowPet, widget.pet);
                                    }
                                  }
                                  Navigator.pop(context);
                                },
                              ),
                            ],
                          ),
                        );
                      },
                      leading: getThemedIcon(context, item.icon, width: 30, height: 30),
                      title: Text(item.name, style: TextStyle(fontSize: 18)),
                      trailing: Text('${item.count}개', style: TextStyle(fontSize: 16)),
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
    else {
      return Scaffold(
        appBar: AppBar(),
        body: Column(
          children: [
            Expanded(
              flex: 6,
              child: Container(
                color: Theme.of(context).scaffoldBackgroundColor,
                child: Mainarea(onNext: widget.onNext, pet: widget.pet, user: widget.user, pageType: widget.pageType,),
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
                      width: 30, height: 30,
                    ),
                    SizedBox(width: 10.0,),
                    Text("상점 - 음식",
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                    Expanded(
                      child: Container(
                        alignment: Alignment.centerRight,
                        child: Text("${widget.user.currentPoint}pt",
                          style: TextStyle(fontSize: 24, color: Colors.yellowAccent, fontWeight: FontWeight.bold),
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
                child: ListView.builder(
                  itemCount: widget.inventory.length,
                  itemBuilder: (context, index) {
                    final item = widget.inventory[index];
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
                                    Expanded(child: Text("포만도 +${item.hunger}", style: TextStyle(fontSize: 16),)),
                                    Expanded(child: Text("행복도 +${item.happy}", style: TextStyle(fontSize: 16),)),
                                  ],
                                ),
                                SizedBox(height: 10),
                                Text('가격은 ${item.price}pt입니다.',
                                    style: TextStyle(fontSize: 16)),
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
                                  if (item.price < widget.user.currentPoint) {
                                    setState(() {
                                      widget.user.currentPoint -= item.price;
                                      item.count++;
                                    });
                                    // ✅ 현재 로그인한 사용자 uid 사용
                                    final uid = FirebaseAuth.instance.currentUser?.uid;
                                    if (uid != null) {
                                      await itemSaveDB(uid, item.name, item);
                                      await userSavePointDB(uid, widget.user.currentPoint);
                                    }
                                  }
                                  Navigator.pop(context);
                                },
                              ),
                            ],
                          ),
                        );
                      },
                      leading: getThemedIcon(context, item.icon, width: 30, height: 30),
                      title: Text(item.name, style: TextStyle(fontSize: 18)),
                      trailing: Text('${item.price}pt', style: TextStyle(fontSize: 16)),
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
}

class ItemlistPage2 extends StatefulWidget {
  final void Function(int) onNext;
  final Pets pet;
  final Users user;
  final int pageType;
  final bool isUseItem;
  final List<Item> inventory;
  const ItemlistPage2({
    required this.onNext,
    required this.pet,
    required this.user,
    required this.pageType,
    required this.isUseItem,
    required this.inventory,
    super.key});

  @override
  State<ItemlistPage2> createState() => _ItemlistPage2State();
}

class _ItemlistPage2State extends State<ItemlistPage2> {
  @override
  Widget build(BuildContext context) {
    if (widget.isUseItem) {
      return Scaffold(
        appBar: AppBar(),
        body: Column(
          children: [
            Expanded(
              flex: 6,
              child: Container(
                color: Theme.of(context).scaffoldBackgroundColor,
                child: Mainarea(onNext: widget.onNext, pet: widget.pet, user: widget.user, pageType: widget.pageType,),
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
                      width: 30, height: 30,
                    ),
                    SizedBox(width: 10.0,),
                    Text("창고 - 장난감",
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
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
                child: ListView.builder(
                  itemCount: widget.inventory.length,
                  itemBuilder: (context, index) {
                    final item = widget.inventory[index];
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
                                    Expanded(child: Text("행복도 +${item.happy}", style: TextStyle(fontSize: 16),)),
                                  ],
                                ),
                                SizedBox(height: 10),
                                Text(item.itemText,
                                    style: TextStyle(fontSize: 16)),
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
                                  if(item.count > 0) {
                                    setState(() {
                                      item.count--;
                                      widget.pet.happy += item.happy;
                                    });
                                    // ✅ 현재 로그인한 사용자 uid 사용
                                    final uid = FirebaseAuth.instance.currentUser?.uid;
                                    if (uid != null) {
                                      await itemSaveDB(uid, item.name, item);
                                      await petSaveDB(uid, widget.user.nowPet, widget.pet);
                                    }
                                  }
                                  Navigator.pop(context);
                                },
                              ),
                            ],
                          ),
                        );
                      },
                      leading: getThemedIcon(context, item.icon, width: 30, height: 30),
                      title: Text(item.name, style: TextStyle(fontSize: 18)),
                      trailing: Text('${item.count}개', style: TextStyle(fontSize: 16)),
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
    } else {
      return Scaffold(
        appBar: AppBar(),
        body: Column(
          children: [
            Expanded(
              flex: 6,
              child: Container(
                color: Theme.of(context).scaffoldBackgroundColor,
                child: Mainarea(onNext: widget.onNext, pet: widget.pet, user: widget.user, pageType: widget.pageType,),
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
                      width: 30, height: 30,
                    ),
                    SizedBox(width: 10.0,),
                    Text("상점 - 장난감",
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                    Expanded(
                      child: Container(
                        alignment: Alignment.centerRight,
                        child: Text("${widget.user.currentPoint}pt",
                          style: TextStyle(fontSize: 24, color: Colors.yellowAccent, fontWeight: FontWeight.bold),
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
                child: ListView.builder(
                  itemCount: widget.inventory.length,
                  itemBuilder: (context, index) {
                    final item = widget.inventory[index];
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
                                    Expanded(child: Text("행복도 +${item.happy}", style: TextStyle(fontSize: 16),)),
                                  ],
                                ),
                                SizedBox(height: 10),
                                Text('가격은 ${item.price}pt입니다.',
                                    style: TextStyle(fontSize: 16)),
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
                                  if (item.price < widget.user.currentPoint) {
                                    setState(() {
                                      widget.user.currentPoint -= item.price;
                                      item.count++;
                                    });
                                    // ✅ 현재 로그인한 사용자 uid 사용
                                    final uid = FirebaseAuth.instance.currentUser?.uid;
                                    if (uid != null) {
                                      await itemSaveDB(uid, item.name, item);
                                      await userSavePointDB(uid, widget.user.currentPoint);
                                    }
                                  }
                                  Navigator.pop(context);
                                },
                              ),
                            ],
                          ),
                        );
                      },
                      leading: getThemedIcon(context, item.icon, width: 30, height: 30),
                      title: Text(item.name, style: TextStyle(fontSize: 18)),
                      trailing: Text('${item.price}pt', style: TextStyle(fontSize: 16)),
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
}

class ItemlistPage3 extends StatefulWidget {
  final void Function(int) onNext;
  final Pets pet;
  final Users user;
  final int pageType;
  final bool isUseItem;
  final List<Item> inventory;
  const ItemlistPage3({
    required this.onNext,
    required this.pet,
    required this.user,
    required this.pageType,
    required this.isUseItem,
    required this.inventory,
    super.key});

  @override
  State<ItemlistPage3> createState() => _ItemlistPage3State();
}

class _ItemlistPage3State extends State<ItemlistPage3> {
  @override
  Widget build(BuildContext context) {
    if (widget.user.setting['placeID'] == "") {
      return Center(child: CircularProgressIndicator());
    }

    if (widget.isUseItem) {
      return Scaffold(
        appBar: AppBar(),
        body: Column(
          children: [
            Expanded(
              flex: 6,
              child: Container(
                color: Theme.of(context).scaffoldBackgroundColor,
                child: Mainarea(onNext: widget.onNext, pet: widget.pet, user: widget.user, pageType: widget.pageType,),
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
                      width: 30, height: 30,
                    ),
                    SizedBox(width: 10.0,),
                    Text("창고 - 배경",
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
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
                child: ListView.builder(
                  itemCount: widget.inventory.length,
                  itemBuilder: (context, index) {
                    final item = widget.inventory[index];
                    final isHighlighted = item.name == nameChange(widget.user.setting['placeID']);
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
                                    Text(item.itemText,
                                        style: TextStyle(fontSize: 16)),
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
                                        widget.user.setting['placeID'] = "assets/images/${item.name}.png";
                                      });
                                      // ✅ 현재 로그인한 사용자 uid 사용
                                      final uid = FirebaseAuth.instance.currentUser?.uid;
                                      if (uid != null) {
                                        await userSavePlaceDB(uid, widget.user.setting['placeID']);
                                      }
                                      Navigator.pop(context);
                                    },
                                  ),
                                ],
                              ),
                            );
                          }
                        },
                        leading: getThemedIcon(context, item.icon, width: 30, height: 30),
                        title: Text(item.name, style: TextStyle(fontSize: 18)),
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
    } else {
      return Scaffold(
        appBar: AppBar(),
        body: Column(
          children: [
            Expanded(
              flex: 6,
              child: Container(
                color: Theme.of(context).scaffoldBackgroundColor,
                child: Mainarea(onNext: widget.onNext, pet: widget.pet, user: widget.user, pageType: widget.pageType,),
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
                      width: 30, height: 30,
                    ),
                    SizedBox(width: 10.0,),
                    Text("상점 - 배경",
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                    Expanded(
                      child: Container(
                        alignment: Alignment.centerRight,
                        child: Text("${widget.user.currentPoint}pt",
                          style: TextStyle(fontSize: 24, color: Colors.yellowAccent, fontWeight: FontWeight.bold),
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
                child: ListView.builder(
                  itemCount: widget.inventory.length,
                  itemBuilder: (context, index) {
                    final item = widget.inventory[index];
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
                                    Text('가격은 ${item.price}pt입니다.',
                                        style: TextStyle(fontSize: 16)),
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
                                      if (item.price < widget.user.currentPoint) {
                                        setState(() {
                                          widget.user.currentPoint -= item.price;
                                        });
                                        // ✅ 현재 로그인한 사용자 uid 사용
                                        final uid = FirebaseAuth.instance.currentUser?.uid;
                                        if (uid != null) {
                                          await itemSaveDB(uid, item.name, item);
                                          await userSavePointDB(uid, widget.user.currentPoint);
                                        }
                                      }
                                      Navigator.pop(context);
                                    },
                                  ),
                                ],
                              ),
                            );
                          }
                        },
                        leading: getThemedIcon(context, item.icon, width: 30, height: 30),
                        title: Text(item.name, style: TextStyle(fontSize: 18)),
                        trailing: Text('${item.price}pt', style: TextStyle(fontSize: 16)),
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
}

class ItemlistPage4 extends StatefulWidget {
  final void Function(int) onNext;
  final Pets pet;
  final Users user;
  final int pageType;
  final bool isUseItem;
  final List<Item> inventory;
  const ItemlistPage4({
    required this.onNext,
    required this.pet,
    required this.user,
    required this.pageType,
    required this.isUseItem,
    required this.inventory,
    super.key});

  @override
  State<ItemlistPage4> createState() => _ItemlistPage4State();
}

class _ItemlistPage4State extends State<ItemlistPage4> {
  String usedItem = "prairie";

  @override
  Widget build(BuildContext context) {
    if (widget.isUseItem) {
      return Scaffold(
        appBar: AppBar(),
        body: Column(
          children: [
            Expanded(
              flex: 6,
              child: Container(
                color: Theme.of(context).scaffoldBackgroundColor,
                child: Mainarea(onNext: widget.onNext, pet: widget.pet, user: widget.user, pageType: widget.pageType,),
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
                      width: 30, height: 30,
                    ),
                    SizedBox(width: 10.0,),
                    Text("창고 - 스타일",
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
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
                child: ListView.builder(
                  itemCount: widget.inventory.length,
                  itemBuilder: (context, index) {
                    final item = widget.inventory[index];
                    final isHighlighted = item.name == usedItem;

                    return Container(
                      color: isHighlighted
                          ? (Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey
                          : Colors.yellow)
                          : Colors.transparent,
                      child: ListTile(
                        onTap: () {
                          if(!isHighlighted) {
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
                                    Text(item.itemText,
                                        style: TextStyle(fontSize: 16)),
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
                                      final uid = FirebaseAuth.instance.currentUser?.uid;
                                      if (uid != null) {
                                        await itemSaveDB(uid, item.name, item);
                                      }
                                      Navigator.pop(context);
                                    },
                                  ),
                                ],
                              ),
                            );
                          }
                        },
                        leading: getThemedIcon(context, item.icon, width: 30, height: 30),
                        title: Text(item.name, style: TextStyle(fontSize: 18)),
                        trailing: Text('${item.count}', style: TextStyle(fontSize: 16)),
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
    } else {
      return Scaffold(
        appBar: AppBar(),
        body: Column(
          children: [
            Expanded(
              flex: 6,
              child: Container(
                color: Theme.of(context).scaffoldBackgroundColor,
                child: Mainarea(onNext: widget.onNext, pet: widget.pet, user: widget.user, pageType: widget.pageType,),
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
                      width: 30, height: 30,
                    ),
                    SizedBox(width: 10.0,),
                    Text("상점 - 스타일",
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                    Expanded(
                      child: Container(
                        alignment: Alignment.centerRight,
                        child: Text("${widget.user.currentPoint}pt",
                          style: TextStyle(fontSize: 24, color: Colors.yellowAccent, fontWeight: FontWeight.bold),
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
                child: ListView.builder(
                  itemCount: widget.inventory.length,
                  itemBuilder: (context, index) {
                    final item = widget.inventory[index];
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
                                    Text('가격은 ${item.price}pt입니다.',
                                        style: TextStyle(fontSize: 16)),
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
                                      if (item.price < widget.user.currentPoint) {
                                        setState(() {
                                          widget.user.currentPoint -= item.price;
                                        });
                                        // ✅ 현재 로그인한 사용자 uid 사용
                                        final uid = FirebaseAuth.instance.currentUser?.uid;
                                        if (uid != null) {
                                          await itemSaveDB(uid, item.name, item);
                                          await userSavePointDB(uid, widget.user.currentPoint);
                                        }
                                      }
                                      Navigator.pop(context);
                                    },
                                  ),
                                ],
                              ),
                            );
                          }
                        },
                        leading: getThemedIcon(context, item.icon, width: 30, height: 30),
                        title: Text(item.name, style: TextStyle(fontSize: 18)),
                        trailing: Text('${item.price}pt', style: TextStyle(fontSize: 16)),
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
}

class ItemCategory extends StatefulWidget {
  final void Function(int) onNext;
  final Pets pet;
  final Users user;
  final int pageType;
  const ItemCategory({required this.onNext,required this.pet, required this.user, required this.pageType, super.key});

  @override
  State<ItemCategory> createState() => _ItemCategoryState();
}

class _ItemCategoryState extends State<ItemCategory> {
  List<Item> inventory = [];

  @override
  void initState() {
    super.initState();
    loadItems();
  }

  Future<void> loadItems() async {
    List<Item> itemDoc = [];

    // ✅ 현재 로그인한 사용자 uid 사용
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      setState(() { inventory = []; });
      return;
    }

    QuerySnapshot snapshot1 = await FirebaseFirestore.instance
        .collection('Users')
        .doc(uid)
        .collection('items')
        .get();

    if (snapshot1.docs.isNotEmpty) {
      itemDoc = snapshot1.docs.map((doc) {
        return Item.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
    }

    setState(() {
      inventory = itemDoc;
    });
  }

  List<Item> getItemsByCategory(int category) {
    return inventory.where((item) => item.category == category).toList();
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
              child: Mainarea(onNext: widget.onNext, pet: widget.pet, user: widget.user, pageType: widget.pageType,),
              // MainArea()로 변경
            ),
          ),
          Expanded(
            flex: 1,
            child:Container(
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.all(8.0),
              color: Colors.blue,
              child: Row(
                children: [
                  Image.asset(
                    "assets/icons/icon-list-alt.png",
                    width: 30, height: 30,
                  ),
                  SizedBox(width: 10.0,),
                  Text("창고",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
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
                                      isUseItem: true,
                                      inventory: getItemsByCategory(1),
                                    ),
                                  )
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
                                  width: 30, height: 30
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 10.0,),
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
                                    isUseItem: true,
                                    inventory: getItemsByCategory(2),
                                  ),
                                ),
                              ).then((value) {
                                setState(() {});
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[100],
                            ),
                            child: Center(child: Image.asset(
                                "assets/icons/icon-teddybear.png",
                                width: 30, height: 30
                            ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10.0,),
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ItemlistPage3(onNext: widget.onNext,
                                    pet: widget.pet,
                                    user: widget.user,
                                    pageType: 2,
                                    isUseItem: true,
                                    inventory: getItemsByCategory(3),
                                  ),
                                ),
                              ).then((value) {
                                setState(() {
                                });
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[100],
                            ),
                            child: Center(
                              child: Image.asset(
                                  "assets/icons/icon-mountains.png",
                                  width: 30, height: 30
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 10.0,),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ItemlistPage4(onNext: widget.onNext,
                                    pet: widget.pet,
                                    user: widget.user,
                                    pageType: 2,
                                    isUseItem: true,
                                    inventory: getItemsByCategory(4),
                                  ),
                                ),
                              ).then((value) {
                                setState(() {});
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[100],
                            ),
                            child: Center(child: Image.asset(
                                "assets/icons/icon-pivotx.png",
                                width: 30, height: 30
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
                onPressed: () {widget.onNext(0);
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
  final Pets pet;
  final Users user;
  final int pageType;
  const ShopCategory({required this.onNext, required this.pet, required this.user,  required this.pageType, super.key});

  @override
  State<ShopCategory> createState() => _ShopCategoryState();
}

class _ShopCategoryState extends State<ShopCategory> {
  List<Item> inventory = [];

  @override
  void initState() {
    super.initState();
    loadItems();
  }

  Future<void> loadItems() async {
    List<Item> shopDoc = [];

    QuerySnapshot snapshot2 = await FirebaseFirestore.instance
        .collection('aLLitems')
        .get();

    if (snapshot2.docs.isNotEmpty) {
      shopDoc = snapshot2.docs.map((doc) {
        return Item.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
    }

    setState(() {
      inventory = shopDoc;
    });
  }

  List<Item> getItemsByCategory(int category) {
    return inventory.where((item) => item.category == category).toList();
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
              child: Mainarea(onNext: widget.onNext, pet: widget.pet, user: widget.user, pageType: widget.pageType,),
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
                    width: 30, height: 30,
                  ),
                  SizedBox(width: 10.0,),
                  Text("상점",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  Expanded(
                    child: Container(
                      alignment: Alignment.centerRight,
                      child: Text("${widget.user.currentPoint}pt",
                        style: TextStyle(fontSize: 24, color: Colors.yellowAccent, fontWeight: FontWeight.bold),
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
                                  builder: (context) => ItemlistPage1(
                                    onNext: widget.onNext,
                                    pet: widget.pet,
                                    user: widget.user,
                                    pageType: 3,
                                    isUseItem: false,
                                    inventory: getItemsByCategory(1),
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
                                  width: 30, height: 30
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 10.0,),
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
                                    pageType: 3,
                                    isUseItem: false,
                                    inventory: getItemsByCategory(2),
                                  ),
                                ),
                              ).then((value) {
                                setState(() {});
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[100],
                            ),
                            child: Center(child: Image.asset(
                                "assets/icons/icon-teddybear.png",
                                width: 30, height: 30
                            ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10.0,),
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
                                    pageType: 3,
                                    isUseItem: false,
                                    inventory: getItemsByCategory(3),
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
                                  width: 30, height: 30
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 10.0,),
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
                                    pageType: 3,
                                    isUseItem: false,
                                    inventory: getItemsByCategory(4),
                                  ),
                                ),
                              ).then((value) {
                                setState(() {});
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[100],
                            ),
                            child: Center(child: Image.asset(
                                "assets/icons/icon-pivotx.png",
                                width: 30, height: 30
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
