import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../utils/constants.dart';
class NoInternetConnection extends StatelessWidget {
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
                        child: SvgPicture.asset(
                          'assets/images/no_internet.svg',
                        ),
                      )),
                  Container(
                    margin: EdgeInsets.only(top: 20.0),
                    child: Text(
                      'No Internet Connection!',
                      style: TextStyle(
                        color: Colors.black,
                          fontFamily: "Poppins",
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 20.0),
                    child: Text(
                      'Please check your internet connection. and try again',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black,
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