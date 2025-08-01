import 'package:flutter/material.dart';
import 'dart:convert';
import 'petmain.dart';
import 'object.dart';
import 'package:path_provider/path_provider.dart';
import 'package:taskmate/utils/icon_utis.dart';
import 'dart:io';

Future<void> useItemsSave(List<Item> items, int index) async {
  final directory = await getApplicationDocumentsDirectory();
  final file = File('${directory.path}/items$index.json');

  final jsonString = jsonEncode(items.map((e) => e.toJson()).toList());

  await file.writeAsString(jsonString);
}

Future<void> userSave(Users user) async {
  final directory = await getApplicationDocumentsDirectory();
  final file = File('${directory.path}/user1.json');

  final jsonString = jsonEncode(user.toJson());

  await file.writeAsString(jsonString);
}

String nameChange(String name) {
    String result;
    switch (name) {
      case "초원":
        result = "assets/images/prairie.png";
        return result;
      case "바닷가":
        result = "assets/images/beach.png";
        return result;
      case "숲 속":
        result = "assets/images/forest.png";
        return result;
      case "구름 위":
        result = "assets/images/cloud.png";
        return result;
      case "화산":
        result = "assets/images/volcano.png";
        return result;
      case "야경":
        result = "assets/images/nightcity.png";
        return result;
      default:
        result = "assets/images/prairie.png";
        return result;
    }
  }

class ItemlistPage1 extends StatefulWidget {
  final void Function(int) onNext;
  final Pets pet;
  final Users user;
  final int pageType;
  final bool isUseItem;
  const ItemlistPage1({required this.onNext, required this.pet, required this.user, required this.pageType, required this.isUseItem, super.key});

  @override
  State<ItemlistPage1> createState() => _ItemlistPage1State();
}

class _ItemlistPage1State extends State<ItemlistPage1> {
  List<Item> inventory = [];

  @override
  void initState() {
    super.initState();
    loadItems();
  }

  Future<void> loadItems() async {
    final testDirectory = await getApplicationDocumentsDirectory();
    String jsonStr = await File('${testDirectory.path}/items1.json').readAsString();    
    final List<dynamic> jsonData = json.decode(jsonStr);
    final List<Item> loadedItems = jsonData.map((e) => Item.fromJson(e)).toList();

    setState(() {
      inventory = loadedItems;
    });
  }

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
          ), // Placeholder for Mainareaaceholder for Mainarea
          Expanded(
            flex: 3,
            child: Container(
              padding: EdgeInsets.all(8.0),
                color: Theme.of(context).scaffoldBackgroundColor,
                child: ListView.builder(
                itemCount: inventory.length,
                itemBuilder: (context, index) {
                  final item = inventory[index];
                  return ListTile(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: Center(child: Text('${item.name}')),
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
                                Text('${item.itemText}', 
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
                              onPressed: () {
                                if(item.count > 0) {
                                  setState(() {
                                    item.count--;
                                    widget.pet.hunger += item.hunger;
                                    widget.pet.happy += item.happy;
                                    changeStatusSave(widget.pet);
                                    useItemsSave(inventory, 1);
                                    /*
                                    ┌─────────────────────────────────────────────┐
                                      firestore에 User 하위의 Pet 정보 갱신 요청.
                                      firestore에 User의 statistics 정보 갱신 요청.
                                      firestore에 User 하위의 Item 정보 갱신 요청.
                                    └─────────────────────────────────────────────┘
                                    */
                                  });
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
                      child: Text("${widget.user.point}pt", 
                        style: TextStyle(fontSize: 24, color: Colors.yellowAccent, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ), // Placeholder for Mainarea
          Expanded(
            flex: 3,
            child: Container(
              padding: EdgeInsets.all(8.0),
                color: Theme.of(context).scaffoldBackgroundColor,
                child: ListView.builder(
                itemCount: inventory.length,
                itemBuilder: (context, index) {
                  final item = inventory[index];
                  return ListTile(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: Center(child: Text('${item.name}')),
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
                              onPressed: () {
                                setState(() {
                                  if (item.price < widget.user.point) {
                                  widget.user.point -= item.price;
                                  item.count++;
                                  useItemsSave(inventory, 1);
                                  userSave(widget.user);
                                  /*
                                  ┌─────────────────────────────────────────────┐
                                    firestore에 User 하위의 Item 정보 갱신 요청.
                                    firestore에 User의 point 정보 갱신 요청.
                                  └─────────────────────────────────────────────┘
                                  */
                                  }
                                });
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
  const ItemlistPage2({required this.onNext, required this.pet, required this.user, required this.pageType, required this.isUseItem, super.key});

  @override
  State<ItemlistPage2> createState() => _ItemlistPage2State();
}

class _ItemlistPage2State extends State<ItemlistPage2> {
  List<Item> inventory = [];
  Pets pet = Pets(
    image: "assets/images/dragon.png",
    name: "",
    hunger:0,
    happy: 0,
    level: 0,
    currentExp: 0,
    styleID: "",
  );

  @override
  void initState() {
    super.initState();
    loadItems();
  }

  Future<void> loadItems() async {
    final testDirectory = await getApplicationDocumentsDirectory();
    String jsonStr = await File('${testDirectory.path}/items2.json').readAsString();    
    final List<dynamic> jsonData = json.decode(jsonStr);
    final List<Item> loadedItems = jsonData.map((e) => Item.fromJson(e)).toList();

    String jsonStr1 = await File('${testDirectory.path}/pet1.json').readAsString();    
    final Map<String, dynamic> jsonData1 = json.decode(jsonStr1);
    final Pets loadedItems1 = Pets.fromJson(jsonData1);

    setState(() {
      inventory = loadedItems;
      pet = loadedItems1;
    });
  }

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
          ), // Placeholder for Mainarea
          Expanded(
            flex: 3,
            child: Container(
              padding: EdgeInsets.all(8.0),
              color: Theme.of(context).scaffoldBackgroundColor,
              child: ListView.builder(
                itemCount: inventory.length,
                itemBuilder: (context, index) {
                  final item = inventory[index];
                  return ListTile(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: Center(child: Text('${item.name}')),
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
                                Text('${item.itemText}', 
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
                              onPressed: () {
                                if(item.count > 0) {
                                  setState(() {
                                    item.count--;
                                    pet.happy += item.happy;
                                    /*
                                    ┌─────────────────────────────────────────────┐
                                      firestore에 User 하위의 Pet 정보 갱신 요청.
                                      firestore에 User의 statistics 정보 갱신 요청.
                                      firestore에 User 하위의 Item 정보 갱신 요청.
                                    └─────────────────────────────────────────────┘
                                    */                                    
                                  });
                                  useItemsSave(inventory, 2);
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
                        child: Text("${widget.user.point}pt", 
                          style: TextStyle(fontSize: 24, color: Colors.yellowAccent, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ), // Placeholder for Mainarea
            Expanded(
              flex: 3,
              child: Container(
                padding: EdgeInsets.all(8.0),
                color: Theme.of(context).scaffoldBackgroundColor,
                child: ListView.builder(
                  itemCount: inventory.length,
                  itemBuilder: (context, index) {
                    final item = inventory[index];
                    return ListTile(
                      onTap: () {
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: Center(child: Text('${item.name}')),
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
                              onPressed: () {
                                setState(() {
                                  item.count++;
                                  useItemsSave(inventory, 2);
                                  /*
                                  ┌─────────────────────────────────────────────┐
                                    firestore에 User 하위의 Item 정보 갱신 요청.
                                    firestore에 User의 point 정보 갱신 요청.
                                  └─────────────────────────────────────────────┘
                                  */
                                });
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
  const ItemlistPage3({required this.onNext, required this.pet, required this.user, required this.pageType, required this.isUseItem, super.key});

  @override
  State<ItemlistPage3> createState() => _ItemlistPage3State();
}

class _ItemlistPage3State extends State<ItemlistPage3> {
  List<Item> inventory = [];

  @override
  void initState() {
    super.initState();
    loadItems();
  }

  Future<void> loadItems() async {
    final testDirectory = await getApplicationDocumentsDirectory();
    String jsonStr = await File('${testDirectory.path}/items3.json').readAsString();    
    final List<dynamic> jsonData = json.decode(jsonStr);
    final List<Item> loadedItems = jsonData.map((e) => Item.fromJson(e)).toList();  

    setState(() {
      inventory = loadedItems;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.user.image == "") {
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
          ), // Placeholder for Mainarea
          Expanded(
            flex: 3,
            child: Container(
              padding: EdgeInsets.all(8.0),
              color: Theme.of(context).scaffoldBackgroundColor,
              child: ListView.builder(
                itemCount: inventory.length,
                itemBuilder: (context, index) {
                  final item = inventory[index];
                  final isHighlighted = item.name == widget.user.name;
                  return Container(
                    color: isHighlighted
                        ? (Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey // 다크모드에서 하이라이트 색
                        : Colors.yellow) // 라이트모드에서 하이라이트 색
                        : Colors.transparent,
                    child: ListTile(
                      onTap: () {
                        if (!isHighlighted) {
                          showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: Center(child: Text('${item.name}')),
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
                                  Text('${item.itemText}', 
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
                                onPressed: () {
                                  setState(() {
                                    widget.user.image = nameChange(item.name);
                                    widget.user.name = item.name;
                                  });
                                  userSave(widget.user);                                  
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
                  Text("상점 - 배경", 
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  Expanded(
                    child: Container(
                      alignment: Alignment.centerRight,
                      child: Text("${widget.user.point}pt", 
                        style: TextStyle(fontSize: 24, color: Colors.yellowAccent, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ), // Placeholder for Mainarea
          Expanded(
            flex: 3,
            child: Container(
              padding: EdgeInsets.all(8.0),
              color: Theme.of(context).scaffoldBackgroundColor,
              child: ListView.builder(
                itemCount: inventory.length,
                itemBuilder: (context, index) {
                  final item = inventory[index];
                  final check = (item.count != 0);
                  
                  return Container(
                    color: check
                        ? (Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey // 다크모드에서 색
                        : Colors.red)  // 라이트모드에서 색
                        : Colors.transparent,
                    child: ListTile(
                      onTap: () {
                        if (!check) {
                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: Center(child: Text('${item.name}')),
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
                                  onPressed: () {
                                    setState(() {
                                      item.count++;
                                      /*
                                      ┌─────────────────────────────────────────────┐
                                        firestore에 User 하위의 Item 정보 갱신 요청.
                                        firestore에 User의 point 정보 갱신 요청.
                                      └─────────────────────────────────────────────┘
                                      */
                                    });
                                    useItemsSave(inventory, 3);
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
  const ItemlistPage4({required this.onNext, required this.pet, required this.user, required this.pageType, required this.isUseItem, super.key});

  @override
  State<ItemlistPage4> createState() => _ItemlistPage4State();
}

class _ItemlistPage4State extends State<ItemlistPage4> {
  List<Item> inventory = [];
  String usedItem = "기본";

  @override
  void initState() {
    super.initState();
    loadItems();
  }


  Future<void> loadItems() async {
    final testDirectory = await getApplicationDocumentsDirectory();
    String jsonStr = await File('${testDirectory.path}/items4.json').readAsString();    
    final List<dynamic> jsonData = json.decode(jsonStr);
    final List<Item> loadedItems = jsonData.map((e) => Item.fromJson(e)).toList();  

    setState(() {
      inventory = loadedItems;
    });
  }

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
          ), // Placeholder for Mainarea
          Expanded(
            flex: 3,
            child: Container(
              padding: EdgeInsets.all(8.0),
              color: Theme.of(context).scaffoldBackgroundColor,
              child: ListView.builder(
                itemCount: inventory.length,
                itemBuilder: (context, index) {
                  final item = inventory[index];
                  final isHighlighted = item.name == usedItem;

                  return Container(
                    color: isHighlighted
                        ? (Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey // 다크모드에서 하이라이트
                        : Colors.yellow) // 라이트모드에서 하이라이트
                        : Colors.transparent,
                    child: ListTile(
                      onTap: () {
                        if(!isHighlighted) {
                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: Center(child: Text('${item.name}')),
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
                                    Text('${item.itemText}', 
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
                                  onPressed: () {
                                    setState(() {
                                      usedItem = item.name;
                                      /*
                                      ┌─────────────────────────────────────────────┐
                                        firestore에 User의 statistics 정보 갱신 요청.
                                        firestore에 User 하위의 Item 정보 갱신 요청.
                                      └─────────────────────────────────────────────┘
                                      */
                                    });
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
                      child: Text("${widget.user.point}pt", 
                        style: TextStyle(fontSize: 24, color: Colors.yellowAccent, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ), // Placeholder for Mainarea
          Expanded(
            flex: 3,
            child: Container(
              padding: EdgeInsets.all(8.0),
              color: Theme.of(context).scaffoldBackgroundColor,
              child: ListView.builder(
                itemCount: inventory.length,
                itemBuilder: (context, index) {
                  final item = inventory[index];
                  final check = (item.count != 0);
                  return Container(
                    color: check
                        ? (Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey // 다크모드일 때
                        : Colors.red)  // 라이트모드일 때
                        : Colors.transparent,
                    child: ListTile(
                      onTap: () {
                        if (!check) {
                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: Center(child: Text('${item.name}')),
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
                                  onPressed: () {
                                    if (item.count == 0) {
                                      setState(() {
                                        item.count++;
                                      });
                                      useItemsSave(inventory, 4);
                                      Navigator.pop(context);
                                    }
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
          ), // Placeholder for Mainarea
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
                                    builder: (context) => ItemlistPage1(onNext: widget.onNext, pet: widget.pet, user: widget.user, pageType: 2, isUseItem: true,),
                                )
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
                                    builder: (context) => ItemlistPage2(onNext: widget.onNext, pet: widget.pet, user: widget.user, pageType: 2, isUseItem: true,),
                                ),
                                ).then((value) {
                                  setState(() {

                                  });
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
                                    builder: (context) => ItemlistPage3(onNext: widget.onNext, pet: widget.pet, user: widget.user, pageType: 2, isUseItem:  true,),
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
                          SizedBox(width: 10.0,),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ItemlistPage4(onNext: widget.onNext, pet: widget.pet, user: widget.user, pageType: 2, isUseItem: true,),
                                ),
                                ).then((value) {
                                  setState(() {

                                  });
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
                      child: Text("${widget.user.point}pt", 
                        style: TextStyle(fontSize: 24, color: Colors.yellowAccent, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ), // Placeholder for Mainarea
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
                                    builder: (context) => ItemlistPage1(onNext: widget.onNext, pet: widget.pet, user: widget.user, pageType: 3, isUseItem: false,),
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
                                    builder: (context) => ItemlistPage2(onNext: widget.onNext, pet: widget.pet, user: widget.user, pageType: 3, isUseItem: false,),
                                ),
                                ).then((value) {
                                  setState(() {

                                  });
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
                                    builder: (context) => ItemlistPage3(onNext: widget.onNext, pet: widget.pet, user: widget.user, pageType: 3, isUseItem: false,),
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
                          SizedBox(width: 10.0,),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ItemlistPage4(onNext: widget.onNext, pet: widget.pet, user: widget.user, pageType: 3, isUseItem: false,),
                                ),
                                ).then((value) {
                                  setState(() {

                                  });
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