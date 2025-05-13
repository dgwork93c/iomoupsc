import 'package:flutter/material.dart';

class HMLoader extends StatelessWidget {
  const HMLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 200,
        height: 200,
        child: PageView(
          children: listOfAnimations
              .map(
                (appBody) => Container(
                  key: UniqueKey(), // Ensures unique instances
                  color: Colors.transparent, // Transparent background
                  child: Center(
                    child: appBody.widget,
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

class AppBody {
  final Widget widget;
  AppBody(this.widget);
}

final listOfAnimations = <AppBody>[
  AppBody(
    const Padding(
      padding: EdgeInsets.all(0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 32.0), // Adjust the height as needed
            Text(
              'Loading Please Wait...',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    ),
  ),
];

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Stack(
        children: [
          const HMLoader(),
          Positioned.fill(
            child: GestureDetector(
              onTap: () {},
              child: Container(
                color: Colors.transparent, // Ensures background is transparent
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
