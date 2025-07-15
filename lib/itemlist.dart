import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import 'petmain.dart';
import 'object.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

Future<void> useItemsSave(List<Item> items, int index) async {
  final directory = await getApplicationDocumentsDirectory();
  final file = File('${directory.path}/items$index.json');

  final jsonString = jsonEncode(items.map((e) => e.toJson()).toList());

  await file.writeAsString(jsonString);
}

class ItemlistPage1 extends StatefulWidget {
  final void Function(int) onNext;
  final Pets pet;
  final bool isUseItem;
  const ItemlistPage1({required this.onNext, required this.pet, required this.isUseItem, super.key});

  @override
  State<ItemlistPage1> createState() => _ItemlistPage1State();
}

class _ItemlistPage1State extends State<ItemlistPage1> {
  List<Item> inventory = [];

  @override
  void initState() {
    super.initState();
    initAsync();
  }

  Future<void> initAsync() async {
    await initJsonIfNotExists(); // 먼저 파일 복사
    await loadItems();           // 복사 완료 후 파일 읽기
  }

  Future<void> initJsonIfNotExists() async {
    final dir = await getApplicationDocumentsDirectory();
    final file1 = File('${dir.path}/items1.json');

    if (!await file1.exists()) {
      final assetJson = await rootBundle.loadString('lib/DBtest/items1.json');
      await file1.writeAsString(assetJson);
    }
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
              color: Colors.white,
              child: Mainarea(onNext: widget.onNext, pet: widget.pet,),
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
              color: Colors.grey[100],
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
                                Image.asset(item.icon, fit: BoxFit.fill, width: 100, height: 100),
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
                                  });
                                  useItemsSave(inventory, 1);
                                }
                                Navigator.pop(context);
                                },
                            ),
                          ],
                        ),
                      );
                    },
                    leading: Image.asset(item.icon, width: 30, height: 30),
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
          color: Colors.white,
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
                  onPressed: () {},
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
              color: Colors.white,
              child: Mainarea(onNext: widget.onNext, pet: widget.pet,),
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
                      child: Text("100pt", 
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
              color: Colors.grey[100],
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
                                Image.asset(item.icon, fit: BoxFit.fill, width: 100, height: 100),
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
                                  item.count++;
                                  useItemsSave(inventory, 1);
                                });
                                Navigator.pop(context);
                                },
                            ),
                          ],
                        ),
                      );
                    },
                    leading: Image.asset(item.icon, width: 30, height: 30),
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
          color: Colors.white,
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
                  onPressed: () {},
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
  final bool isUseItem;
  const ItemlistPage2({required this.onNext, required this.pet, required this.isUseItem, super.key});

  @override
  State<ItemlistPage2> createState() => _ItemlistPage2State();
}

class _ItemlistPage2State extends State<ItemlistPage2> {
  List<Item> inventory = [];

  @override
  void initState() {
    super.initState();
    initAsync();
  }

  Future<void> initAsync() async {
    await initJsonIfNotExists(); // 먼저 파일 복사
    await loadItems();           // 복사 완료 후 파일 읽기
  }

  Future<void> initJsonIfNotExists() async {
    final dir = await getApplicationDocumentsDirectory();
    final file2 = File('${dir.path}/items2.json');

    if (!await file2.exists()) {
      final assetJson = await rootBundle.loadString('lib/DBtest/items2.json');
      await file2.writeAsString(assetJson);
    }
  }


  Future<void> loadItems() async {
    final testDirectory = await getApplicationDocumentsDirectory();
    String jsonStr = await File('${testDirectory.path}/items2.json').readAsString();    
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
              color: Colors.white,
              child: Mainarea(onNext: widget.onNext, pet: widget.pet,),
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
              color: Colors.grey[100],
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
                                Image.asset(item.icon, fit: BoxFit.fill, width: 100, height: 100),
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
                    leading: Image.asset(item.icon, width: 30, height: 30),
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
          color: Colors.white,
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
                  onPressed: () {},
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
                color: Colors.white,
                child: Mainarea(onNext: widget.onNext, pet: widget.pet),
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
                        child: Text("100pt", 
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
                color: Colors.grey[100],
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
                                Image.asset(item.icon, fit: BoxFit.fill, width: 100, height: 100),
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
                                });
                                Navigator.pop(context);
                                },
                            ),
                          ],
                        ),
                      );
                    },
                      leading: Image.asset(item.icon, width: 30, height: 30),
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
            color: Colors.white,
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
                    onPressed: () {},
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
  final bool isUseItem;
  const ItemlistPage3({required this.onNext, required this.pet, required this.isUseItem, super.key});

  @override
  State<ItemlistPage3> createState() => _ItemlistPage3State();
}

class _ItemlistPage3State extends State<ItemlistPage3> {
  List<Item> inventory = [];
  String usedItem = "바다";

  @override
  void initState() {
    super.initState();
    initAsync();
  }

  Future<void> initAsync() async {
    await initJsonIfNotExists(); // 먼저 파일 복사
    await loadItems();           // 복사 완료 후 파일 읽기
  }

  Future<void> initJsonIfNotExists() async {
    final dir = await getApplicationDocumentsDirectory();
    final file2 = File('${dir.path}/items3.json');

    if (!await file2.exists()) {
      final assetJson = await rootBundle.loadString('lib/DBtest/items3.json');
      await file2.writeAsString(assetJson);
    }
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
    if (widget.isUseItem) {
      return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          Expanded(
            flex: 6,
            child: Container(
              color: Colors.white,
              child: Mainarea(onNext: widget.onNext, pet: widget.pet,),
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
              color: Colors.grey[100],
              child: ListView.builder(
                itemCount: inventory.length,
                itemBuilder: (context, index) {
                  final item = inventory[index];
                  final isHighlighted = item.name == usedItem;
                  return Container(
                    color: isHighlighted ? Colors.yellow : Colors.transparent,
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
                                  Image.asset(item.icon, fit: BoxFit.fill, width: 100, height: 100),
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
                                  });
                                  Navigator.pop(context);
                                  },
                              ),
                            ],
                          ),
                        );
                        }
                      },
                      leading: Image.asset(item.icon, width: 30, height: 30),
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
          color: Colors.white,
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
                  onPressed: () {},
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
              color: Colors.white,
              child: Mainarea(onNext: widget.onNext, pet: widget.pet,),
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
                      child: Text("100pt", 
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
              color: Colors.grey[100],
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
                                Image.asset(item.icon, fit: BoxFit.fill, width: 100, height: 100),
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
                                });
                                useItemsSave(inventory, 3);
                                Navigator.pop(context);
                                },
                            ),
                          ],
                        ),
                      );
                    },
                    leading: Image.asset(item.icon, width: 30, height: 30),
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
          color: Colors.white,
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
                  onPressed: () {},
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
  final bool isUseItem;
  const ItemlistPage4({required this.onNext, required this.pet, required this.isUseItem, super.key});

  @override
  State<ItemlistPage4> createState() => _ItemlistPage4State();
}

class _ItemlistPage4State extends State<ItemlistPage4> {
  List<Item> inventory = [];
  String usedItem = "기본";

  @override
  void initState() {
    super.initState();
    initAsync();
  }

  Future<void> initAsync() async {
    await initJsonIfNotExists(); // 먼저 파일 복사
    await loadItems();           // 복사 완료 후 파일 읽기
  }

  Future<void> initJsonIfNotExists() async {
    final dir = await getApplicationDocumentsDirectory();
    final file2 = File('${dir.path}/items4.json');

    if (!await file2.exists()) {
      final assetJson = await rootBundle.loadString('lib/DBtest/items4.json');
      await file2.writeAsString(assetJson);
    }
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
              color: Colors.white,
              child: Mainarea(onNext: widget.onNext, pet: widget.pet,),
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
              color: Colors.grey[100],
              child: ListView.builder(
                itemCount: inventory.length,
                itemBuilder: (context, index) {
                  final item = inventory[index];
                  final isHighlighted = item.name == usedItem;

                  return Container(
                    color: isHighlighted ? Colors.yellow : Colors.transparent,
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
                                    Image.asset(item.icon, fit: BoxFit.fill, width: 100, height: 100),
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
                                    });
                                    Navigator.pop(context);
                                    },
                                ),
                              ],
                            ),
                          );
                        }
                      },
                      leading: Image.asset(item.icon, width: 30, height: 30),
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
          color: Colors.white,
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
                  onPressed: () {},
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
              color: Colors.white,
              child: Mainarea(onNext: widget.onNext, pet: widget.pet,),
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
                      child: Text("100pt", 
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
              color: Colors.grey[100],
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
                                Image.asset(item.icon, fit: BoxFit.fill, width: 100, height: 100),
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
                                }
                              },
                            ),
                          ],
                        ),
                      );
                    },
                    leading: Image.asset(item.icon, width: 30, height: 30),
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
          color: Colors.white,
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
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
      );
    }
  }
}

class ItemCategory extends StatelessWidget {
  final void Function(int) onNext;
  final Pets pet1;
  const ItemCategory({required this.onNext, required this.pet1, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          Expanded(
            flex: 6,
            child: Container(
              color: Colors.white,
              child: Mainarea(onNext: onNext, pet: pet1,),
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
              color: Colors.grey[100],
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
                                    builder: (context) => ItemlistPage1(onNext: onNext, pet: pet1,isUseItem: true,),
                                ),
                                );
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
                                    builder: (context) => ItemlistPage2(onNext: onNext, pet: pet1, isUseItem: true,),
                                ),
                                );
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
                                    builder: (context) => ItemlistPage3(onNext: onNext, pet: pet1, isUseItem:  true,),
                                ),
                                );
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
                                    builder: (context) => ItemlistPage4(onNext: onNext, pet: pet1, isUseItem: true,),
                                ),
                                );
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
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [

                IconButton(
                  icon: const Icon(Icons.calendar_month),
                  onPressed: () {
                    onNext(3); // Navigate to PlannerMain
                  },
                ),

                IconButton(
                  icon: Icon(Icons.home),
                  onPressed: () {onNext(0);
                  },
                ),
                IconButton(
                  icon: Icon(Icons.settings),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
    );
  }
}

class ShopCategory extends StatelessWidget {
  final void Function(int) onNext;
  final Pets pet1;
  const ShopCategory({required this.onNext, required this.pet1, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          Expanded(
            flex: 6,
            child: Container(
              color: Colors.white,
              child: Mainarea(onNext: onNext, pet: pet1),
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
                      child: Text("100pt", 
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
              color: Colors.grey[100],
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
                                    builder: (context) => ItemlistPage1(onNext: onNext, pet: pet1, isUseItem: false,),
                                ),
                                );
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
                                    builder: (context) => ItemlistPage2(onNext: onNext, pet: pet1, isUseItem: false,),
                                ),
                                );
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
                                    builder: (context) => ItemlistPage3(onNext: onNext, pet: pet1, isUseItem: false,),
                                ),
                                );
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
                                    builder: (context) => ItemlistPage4(onNext: onNext, pet: pet1, isUseItem: false,),
                                ),
                                );
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
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [

                IconButton(
                  icon: const Icon(Icons.calendar_month),
                  onPressed: () {
                    onNext(3); // Navigate to PlannerMain
                  },
                ),

                IconButton(
                  icon: Icon(Icons.home),
                  onPressed: () {onNext(0);
                  },
                ),
                IconButton(
                  icon: Icon(Icons.settings),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
    );
  }
}