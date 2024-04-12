import 'package:bloc/bloc.dart';

enum RadioButtonOption { allData, onlineDevices ,offlineDevices}

class RadioButtonCubit extends Cubit<RadioButtonOption> {
  RadioButtonCubit() : super(RadioButtonOption.allData);

  void selectOption(RadioButtonOption option) {
    emit(option);
  }
}
