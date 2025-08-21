import 'package:flutter/material.dart';

class mainButton extends StatelessWidget {
  final void Function(int) onNext;
  final String buttonName;
  final String icon;
  final int pageNumber;
  const mainButton({
    required this.onNext, 
    required this.buttonName, 
    required this.icon,
    required this.pageNumber,
    super.key});
  
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ElevatedButton(
          onPressed: () {
          onNext(pageNumber); // Navigate to ItemlistPage
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue[100],
          ),
          child: Center(
            child: Text(buttonName, style: TextStyle(fontSize: 16, color: Colors.black)),
          ),
        ),
        Positioned(
          left: 0, top: 0,
          child: CircleAvatar(
            backgroundColor: Colors.blueAccent,
            radius: 35,
            child: Image.asset(
              icon, 
              fit: BoxFit.fill, width: 50, height: 50
            ),
          ),
        ),
      ],
    ); 
  }
}