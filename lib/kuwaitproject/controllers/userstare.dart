import 'package:equatable/equatable.dart';

import '../models/modelclass.dart';

abstract class UserState extends Equatable  {
  const UserState();

  @override
  List<farmer_kuwait?> get props => [];
}

class UserLoading extends UserState {

}

class UserLoaded extends UserState {
  @override
  final List<farmer_kuwait> users;

  UserLoaded(this.users);
}



class UserError extends UserState {
  final String error;

  UserError(this.error);
}