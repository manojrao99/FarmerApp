
import 'dart:io';

import 'package:flutter/material.dart';
class Internetcheck extends StatefulWidget {
  const Internetcheck({Key? key}) : super(key: key);

  @override
  State<Internetcheck> createState() => _InternetcheckState();
}

class _InternetcheckState extends State<Internetcheck> {
  @override
  void initState() {
    // TODO: implement initState
    CheckUserConnection();

    super.initState();
  }
  bool ActiveConnection = false;
  String T = "";
  Future CheckUserConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        setState(() {
          ActiveConnection = true;
          T = "No Internet";
        });
      }
    } on SocketException catch (_) {
      setState(() {
        ActiveConnection = false;
        T = "Turn On the data and repress again";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 15),
      height: 30,
      color: Colors.red,
      width: MediaQuery.of(context).size.width,
      child: Center(child: Text("$T",style: TextStyle(color: Colors.white,fontSize: 20,decoration: TextDecoration.none),)),
    );
  }
}
