import 'package:flutter/material.dart';
import 'petmain.dart';

class Item {
  final Image icon;
  final String name;
  final int count;

  Item({required this.icon, required this.name, required this.count});
}

class ItemlistPage extends StatelessWidget {
  final void Function(int) onNext;
  ItemlistPage({required this.onNext, super.key});
  
  final List<Item> items = [
    Item(icon: Image.asset("assets/icons/icon-soup.png"), name: '버섯 수프', count: 5),
    Item(icon: Image.asset("assets/icons/icon-strawberry.png"), name: '딸기', count: 3),
    Item(icon: Image.asset("assets/icons/icon-cupcake.png"), name: '푸딩', count: 2),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          Expanded(
            flex: 4,
            child: Container(
              color: Colors.white,
              child: Mainarea(onNext: onNext,),
            ),
          ),
          Expanded(
            flex: 3,
            child: Container(
              padding: EdgeInsets.all(8.0),
              color: Colors.grey[100],
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
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
      bottomNavigationBar: BottomNavigationBar(
        onTap: (index) {
          // Handle bottom navigation bar tap
          if (index == 0) {
            // Navigate to planner
          } else if (index == 1) {
            // Navigate to home
            onNext(0); // Call onNext to switch to ItemlistPage
          } else if (index == 2) {
            // Navigate to settings
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'planner',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'setting',
          ),
        ],
      ),
    );
  }
}