// import 'package:flutter/cupertino.dart';
import 'package:cultyvate/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import '../controllers/radiobuttoncontroller.dart';




class RadioButtonWidget extends StatelessWidget {
  // final RadioButtonCubit radiocubit = RadioButtonCubit();
  RadioButtonWidget({required this.radiocubit});
  final radiocubit;
  @override
  Widget build(BuildContext context) {
    // final radiocubit = context.read<RadioButtonCubit>();

    return BlocBuilder<RadioButtonCubit, RadioButtonOption>(
        builder: (context, state)
    {
      return Container(
          width: MediaQuery
              .of(context)
              .size
              .width * 0.70,
          child: Row(
            children: [
              const Text('All',style: TextStyle(color: Colors.white
              ),),
              Radio<RadioButtonOption>(
                value: RadioButtonOption.allData,
                activeColor: Colors.white,
                groupValue: state,
                onChanged: (RadioButtonOption? value) {
                  radiocubit.selectOption(value!);
                },
              ),

              Text('Online',style: TextStyle(color: Colors.white
              ),),
              Radio<RadioButtonOption>(
                activeColor: Colors.white,
                value: RadioButtonOption.onlineDevices,
                groupValue: state,
                onChanged: (RadioButtonOption? value) {
                  try {
                    radiocubit.selectOption(value!);
                  }
                  catch (e) {
                    print("eror os is ${e}");
                  }
                },
              ),

              Text('Offline',style: TextStyle(color: Colors.white
              ),),
              Radio<RadioButtonOption>(
                value: RadioButtonOption.offlineDevices,
                groupValue: state,
                activeColor: Colors.white,
                onChanged: (RadioButtonOption? value) {
                  print("values is ${value}");
                  radiocubit.selectOption(value!);
                },
              ),

            ],
          )
      );
    }
    );
  }
}
