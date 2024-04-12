import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../utils/constants.dart';
class ServerDown extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Widget noInternetConnection() {
      return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            centerTitle: true,
            title:   Image(
              image: AssetImage(
                  '${assetImagePath}cultyvate.png'),
            ),
          ),
          body: SafeArea(child: Container(
            child:

            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                    child: Center(
                      child:   Image(
                      image: AssetImage(
                        '${assetImagePath}cultyvate.png',
                      ),
                      )
                    )),
                Container(
                  margin: EdgeInsets.only(top: 20.0),
                  child: Text(
                    'cultYvate server is down',
                    style: TextStyle(
                        fontFamily: "Poppins",
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 20.0),
                  child: Text(
                    'Please contact cultYvate',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: "Poppins",
                    ),
                  ),
                ),
//            Container(
//                margin: EdgeInsets.only(top: 20.0, left: 40.0, right: 40.0),
//                child: retryButton)
              ],
            ),

          ),)
      );
    }

    return Container(
      height: MediaQuery.of(context).size.height-400,
      child: noInternetConnection(),
    );
  }
}