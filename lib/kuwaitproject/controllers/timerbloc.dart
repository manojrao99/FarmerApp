import 'dart:async';

import '../models/modelclass.dart';
import 'controller.dart';
import 'deviceevent.dart';

class TimerBloc {
  Timer? _timer;
  final _remainingTimeController = StreamController<int>();

  Stream<int> get remainingTimeStream => _remainingTimeController.stream;

  void startTimer(int initialTime, UserBloc itemCubit) {
    if (_timer == null) {
      int remainingTime = initialTime;
      _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
        remainingTime--;
        _remainingTimeController.sink.add(remainingTime);
        if (remainingTime <= 0) {
          _timer?.cancel();
          // print(itemCubit.state.props[0].farmerid);
          // Call the method with data when the timer is complete
          // itemCubit.fetchDevicesData(data: itemCubit.state.props, devices: itemCubit.deviceEUIIDs.toString());
        }
      });
    }
    else {
      print(_timer!.isActive);
    }
  }

  void stopTimer() {
    _timer?.cancel();
  }

  void restartTimer(int initialTime, itemCubit) {
    stopTimer();
    print("method calling");
      _timer=null;
    startTimer(initialTime, itemCubit); // Pass the initial time when restarting the timer
  }

  void dispose() {
    _remainingTimeController.close();
  }

  void fetchData(List<farmer_kuwait> data) {
    List<String> deviceEUIIDs=[];
          _timer?.cancel();
          _timer=null;
    deviceEUIIDs.addAll(data.map((element) {
      return "'${element.deviceEUIID.toString()}'";
    }).toList());
    print(deviceEUIIDs);
    String result = deviceEUIIDs.where((element) => element is String).join(', ');
          // itemCubit.add(UserDevicestatus(deviceEUIIDs:result.toString(),telematicDataList: data,userbloc:  itemCubit));
  }
}
