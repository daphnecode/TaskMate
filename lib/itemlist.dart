import 'package:flutter/material.dart';
import 'petmain.dart';

class Item {
  final Image icon;
  final String name;
  final int count;
  final int price;

  Item({required this.icon, required this.name, required this.count, required this.price});
}

class ItemlistPage1 extends StatelessWidget {
  final void Function(int) onNext;
  ItemlistPage1({required this.onNext, super.key});
  
  final List<Item> items1 = [
    Item(icon: Image.asset("assets/icons/icon-soup.png"), name: '버섯 수프', count: 5, price: 100),
    Item(icon: Image.asset("assets/icons/icon-strawberry.png"), name: '딸기', count: 3, price: 50),
    Item(icon: Image.asset("assets/icons/icon-cupcake.png"), name: '푸딩', count: 2, price: 150),
  ];

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
              child: Mainarea(onNext: onNext,),
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
                itemCount: items1.length,
                itemBuilder: (context, index) {
                  final item = items1[index];
                  return ListTile(
                    leading: item.icon,
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

class ItemlistPage2 extends StatelessWidget {
  final void Function(int) onNext;
  ItemlistPage2({required this.onNext, super.key});

  final List<Item> items2 = [
    Item(icon: Image.asset("assets/icons/icon-teddybear.png"), name: '뼈다귀', count: 5, price: 100),
    Item(icon: Image.asset("assets/icons/icon-teddybear.png"), name: '공', count: 3, price: 50),
    Item(icon: Image.asset("assets/icons/icon-teddybear.png"), name: '낚싯대', count: 2, price: 150),
  ];

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
              child: Mainarea(onNext: onNext,),
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
                itemCount: items2.length,
                itemBuilder: (context, index) {
                  final item = items2[index];
                  return ListTile(
                    leading: item.icon,
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

class ItemlistPage3 extends StatelessWidget {
  final void Function(int) onNext;
  ItemlistPage3({required this.onNext, super.key});
  
  final List<Item> items3 = [
    Item(icon: Image.asset("assets/icons/icon-mountains.png"), name: '초원', count: 0, price: 200),
    Item(icon: Image.asset("assets/icons/icon-mountains.png"), name: '바다', count: 0, price: 300),
    Item(icon: Image.asset("assets/icons/icon-mountains.png"), name: '구름', count: 0, price: 400),
    Item(icon: Image.asset("assets/icons/icon-mountains.png"), name: '화산', count: 0, price: 500),
    Item(icon: Image.asset("assets/icons/icon-mountains.png"), name: '야경', count: 0, price: 600),
  ];

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
              child: Mainarea(onNext: onNext,),
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
                itemCount: items3.length,
                itemBuilder: (context, index) {
                  final item = items3[index];
                  return ListTile(
                    leading: item.icon,
                    title: Text(item.name, style: TextStyle(fontSize: 18)),
                    trailing: Text(''),
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

class ItemlistPage4 extends StatelessWidget {
  final void Function(int) onNext;
  ItemlistPage4({required this.onNext, super.key});

  final List<Item> items4 = [
    Item(icon: Image.asset("assets/icons/icon-pivotx.png"), name: '기본', count: 0, price: 0),
    Item(icon: Image.asset("assets/icons/icon-pivotx.png"), name: '버블 오라', count: 0, price: 150),
    Item(icon: Image.asset("assets/icons/icon-pivotx.png"), name: '별빛 오라', count: 0, price: 200),
  ];

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
              child: Mainarea(onNext: onNext,),
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
                itemCount: items4.length,
                itemBuilder: (context, index) {
                  final item = items4[index];
                  return ListTile(
                    leading: item.icon,
                    title: Text(item.name, style: TextStyle(fontSize: 18)),
                    trailing: Text(''),
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

class ShoplistPage1 extends StatelessWidget {
  final void Function(int) onNext;
  ShoplistPage1({required this.onNext, super.key});
  
  final List<Item> items1 = [
    Item(icon: Image.asset("assets/icons/icon-soup.png"), name: '버섯 수프', count: 5, price: 100),
    Item(icon: Image.asset("assets/icons/icon-strawberry.png"), name: '딸기', count: 3, price: 50),
    Item(icon: Image.asset("assets/icons/icon-cupcake.png"), name: '푸딩', count: 2, price: 150),
  ];

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
              child: Mainarea(onNext: onNext,),
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
                itemCount: items1.length,
                itemBuilder: (context, index) {
                  final item = items1[index];
                  return ListTile(
                    leading: item.icon,
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

class ShoplistPage2 extends StatelessWidget {
  final void Function(int) onNext;
  ShoplistPage2({required this.onNext, super.key});

  final List<Item> items2 = [
    Item(icon: Image.asset("assets/icons/icon-teddybear.png"), name: '뼈다귀', count: 5, price: 100),
    Item(icon: Image.asset("assets/icons/icon-teddybear.png"), name: '공', count: 3, price: 50),
    Item(icon: Image.asset("assets/icons/icon-teddybear.png"), name: '낚싯대', count: 2, price: 150),
  ];

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
              child: Mainarea(onNext: onNext,),
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
                itemCount: items2.length,
                itemBuilder: (context, index) {
                  final item = items2[index];
                  return ListTile(
                    leading: item.icon,
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

class ShoplistPage3 extends StatelessWidget {
  final void Function(int) onNext;
  ShoplistPage3({required this.onNext, super.key});
  
  final List<Item> items3 = [
    Item(icon: Image.asset("assets/icons/icon-mountains.png"), name: '초원', count: 0, price: 200),
    Item(icon: Image.asset("assets/icons/icon-mountains.png"), name: '바다', count: 0, price: 300),
    Item(icon: Image.asset("assets/icons/icon-mountains.png"), name: '구름', count: 0, price: 400),
    Item(icon: Image.asset("assets/icons/icon-mountains.png"), name: '화산', count: 0, price: 500),
    Item(icon: Image.asset("assets/icons/icon-mountains.png"), name: '야경', count: 0, price: 600),
  ];

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
              child: Mainarea(onNext: onNext,),
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
                itemCount: items3.length,
                itemBuilder: (context, index) {
                  final item = items3[index];
                  return ListTile(
                    leading: item.icon,
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

class ShoplistPage4 extends StatelessWidget {
  final void Function(int) onNext;
  ShoplistPage4({required this.onNext, super.key});

  final List<Item> items4 = [
    Item(icon: Image.asset("assets/icons/icon-pivotx.png"), name: '기본', count: 0, price: 0),
    Item(icon: Image.asset("assets/icons/icon-pivotx.png"), name: '버블 오라', count: 0, price: 150),
    Item(icon: Image.asset("assets/icons/icon-pivotx.png"), name: '별빛 오라', count: 0, price: 200),
  ];

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
              child: Mainarea(onNext: onNext,),
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
                itemCount: items4.length,
                itemBuilder: (context, index) {
                  final item = items4[index];
                  return ListTile(
                    leading: item.icon,
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

class ItemCategory extends StatelessWidget {
  final void Function(int) onNext;
  const ItemCategory({required this.onNext, super.key});

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
              child: Mainarea(onNext: onNext,),
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
                                    builder: (context) => ItemlistPage1(onNext: onNext,),
                                ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue[100],
                              ),
                              child: Center(
                                child: Image.asset(
                                  "assets/icons/icon-chicken.png", 
                                  width: 50, height: 50
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
                                    builder: (context) => ItemlistPage2(onNext: onNext,),
                                ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue[100],
                              ),
                              child: Center(child: Image.asset(
                                  "assets/icons/icon-teddybear.png", 
                                  width: 50, height: 50
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
                                    builder: (context) => ItemlistPage3(onNext: onNext,),
                                ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue[100],
                              ),
                              child: Center(
                                child: Image.asset(
                                  "assets/icons/icon-mountains.png", 
                                  width: 50, height: 50
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
                                    builder: (context) => ItemlistPage4(onNext: onNext,),
                                ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue[100],
                              ),
                              child: Center(child: Image.asset(
                                  "assets/icons/icon-pivotx.png", 
                                  width: 50, height: 50
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
  const ShopCategory({required this.onNext, super.key});

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
              child: Mainarea(onNext: onNext,),
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
                                    builder: (context) => ShoplistPage1(onNext: onNext,),
                                ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue[100],
                              ),
                              child: Center(
                                child: Image.asset(
                                  "assets/icons/icon-chicken.png", 
                                  width: 50, height: 50
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
                                    builder: (context) => ShoplistPage2(onNext: onNext,),
                                ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue[100],
                              ),
                              child: Center(child: Image.asset(
                                  "assets/icons/icon-teddybear.png", 
                                  width: 50, height: 50
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
                                    builder: (context) => ShoplistPage3(onNext: onNext,),
                                ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue[100],
                              ),
                              child: Center(
                                child: Image.asset(
                                  "assets/icons/icon-mountains.png", 
                                  width: 50, height: 50
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
                                    builder: (context) => ShoplistPage4(onNext: onNext,),
                                ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue[100],
                              ),
                              child: Center(child: Image.asset(
                                  "assets/icons/icon-pivotx.png", 
                                  width: 50, height: 50
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