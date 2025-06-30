import 'package:flutter/material.dart';
import 'itemlist.dart';
import 'petmain.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Virtual Pet'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 0;
  
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
          currentWidget = Petmain(onNext: goNext);
          break;
        case 1:
          currentWidget = ItemlistPage(onNext: goNext);
          break;
        case 2:
          currentWidget = Icon(Icons.star);
          break;
        default:
          currentWidget = Text('기본');
    }
    
    return Scaffold(
      body:currentWidget
    );  
  }
}
