import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../utils/styles.dart';
import '../../utils/string_extension.dart';
import '../../models/farmer_profile.dart';

class SelectFarmland extends StatefulWidget {
  const SelectFarmland(
      {required this.farmlands, required this.setSelectedFarmland, Key? key})
      : super(key: key);
  final List<FarmLand> farmlands;
  final Function setSelectedFarmland;
  @override
  State<SelectFarmland> createState() => _SelectFarmlandState();
}

class _SelectFarmlandState extends State<SelectFarmland> {
  bool showUI = false; // Controls whether to show the UI or spinkit
  List<Widget> columns = [];
  late List<FarmLand> farmlands;
  @override
  initState() {
    super.initState();
    farmlands = widget.farmlands;
    for (int i = 0; i < farmlands.length; i++) {
      columns.add(InkWell(
          onTap: () {
            //widget.setSelectedFarmland(i);
            Navigator.pop(context, i);
          },
          child: Container(
            padding: EdgeInsets.all(10.h),
            margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
            height: ScreenUtil().setHeight(60),
            width: double.infinity,
            decoration: BoxDecoration(
                color: cultGreen, borderRadius: BorderRadius.circular(10)),
            child: Center(
                child: Text(
              farmlands[i].name ?? '',
              style: TextStyle(
                  fontSize: bodyFont.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            )),
          )));
    }
  }

  // Method called on selection of a language by user
  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
          padding: EdgeInsets.symmetric(vertical: 30.h, horizontal: 10.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: ScreenUtil().setHeight(60.h)),
              Text(
                'Choose Farmland'.i18n,
                style: TextStyle(
                    fontSize: heading2Font.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 40.h),
              Column(
                children: columns,
              ),
            ],
          )),
    );
  }
}
