import 'package:flutter/material.dart';
import 'petchoose.dart';
import 'itemlist.dart';

class Mainarea extends StatelessWidget {
  const Mainarea({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: Colors.white10,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold), 
                      "LV 13",),
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                      Icon(Icons.heart_broken,),
                      Icon(Icons.heart_broken,),
                      Icon(Icons.heart_broken,),
                      Icon(Icons.heart_broken,),
                      Icon(Icons.heart_broken,),
                      ],
                    )
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        icon: Icon(Icons.question_mark,),
                        onPressed: () {
                          // Handle back button press
                        },
                        )
                      ),
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                      Icon(Icons.apple,),
                      Icon(Icons.apple,),
                      Icon(Icons.apple,),
                      Icon(Icons.apple,),
                      Icon(Icons.apple,),
                      ],
                    )
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: GestureDetector(
            onLongPress: () {
              // Handle long press
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PetChoose()),
              );
            },
            child: Container(
              color: Colors.white,
              child: Center(child: Text('Main Area')),
          ),),
        ),
      ],
    );
  }
}

class SubArea extends StatelessWidget {
  const SubArea({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Handle button press
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ItemlistPage()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[100],
                    ),
                    child: Center(child: Text('Area 2')),
                  ),
                ),
                SizedBox(height: 10.0,),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Handle button press
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[100],
                    ),
                    child: Center(child: Text('Area 3')),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 10.0,),
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Handle button press
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ItemlistPage()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[100],
                    ),
                    child: Center(child: Text('Area 4')),
                  ),
                ),
                SizedBox(height: 10.0,),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Handle button press
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[100],
                    ),
                    child: Center(child: Text('Area 5')),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
  }
}