import 'package:equatable/equatable.dart';

import '../models/modelclass.dart';
import 'controller.dart';

abstract class UserEvent extends Equatable {
  const UserEvent();
}

class FetchUsers extends UserEvent {
  int ?farmerID;

  FetchUsers({this.farmerID,});

  @override
  // TODO: implement props
  List<Object?> get props => throw UnimplementedError();



  // @override
  // TODO: implement props
  // List<farmer_kuwait> get props =>[];


}
class UserDevicestatus extends UserEvent{
  String deviceEUIIDs ;
  UserBloc userbloc;
  @override
  List<farmer_kuwait> telematicDataList;
  UserDevicestatus({required this.deviceEUIIDs, required this.telematicDataList,required this.userbloc});

  @override
  // TODO: implement props
  List<Object?> get props => [];
}