import 'package:flutter/material.dart';

class Snr_signal_Stringth extends StatelessWidget {
  final int count;

  const Snr_signal_Stringth({Key? key, required this.count}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      child: GridView.count(
        crossAxisCount: 2,
        children: List.generate(4, (index) {
          if (index >= 4 - count) {
            return Container(
              color: Colors.black,
              margin: EdgeInsets.all(1),
              width: 4, // Adjust the width as needed
              height: 4, // Adj
            );
          } else {
            return Container(
              // color: Colors.white,
              margin: EdgeInsets.all(1),
              width: 4, // Adjust the width as needed
              height: 4, // Adj
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.black, // Set the border color here
                // Set the border width here
                ),
              ),
            );
          }
        }),
      ),
    );
  }
}