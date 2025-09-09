import 'package:flutter/material.dart';
import 'package:social_creater/pages/homepage.dart';

class Initialpage extends StatelessWidget {
  const Initialpage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Text(
                "GPS Swapper",
                style: TextStyle(fontSize: 20, color: Colors.blueAccent),
              ),
            ),
            SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (context) => Homepage()));
              },

              child: Text(
                "START",
                style: TextStyle(fontSize: 16, color: Colors.black45),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
