import 'package:flutter/material.dart';
class NoNetwork extends StatelessWidget {
  final String error;
  double hight;
  String imagepath;


  NoNetwork({required this.imagepath,required this.error,required this.hight}) ;
  // usb-cable
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        height: hight,
        child: Column(
          children: [
            Image.asset(imagepath,
              height: hight/3,
              // width: 300,
            ),
            SizedBox(height: 10,),
            Text(error,style: TextStyle(color: Colors.red,fontWeight: FontWeight.bold),),
          ],
        ),
      ),
    );
  }
}
