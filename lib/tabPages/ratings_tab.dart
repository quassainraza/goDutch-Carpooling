import 'package:flutter/material.dart';

class RatingsTab extends StatefulWidget {
  const RatingsTab({Key? key}) : super(key: key);

  @override
  State<RatingsTab> createState() => _RatingsTabState();
}

class _RatingsTabState extends State<RatingsTab> {
  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        color: Colors.white,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                "images/ratings.png",
                width: 333,
                height: 205,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
