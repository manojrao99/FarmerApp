part of 'waterflowdata_bloc.dart';

@immutable
abstract class WaterflowdataState {}

class WaterflowdataInitial extends WaterflowdataState {}
class PostLoadingState extends WaterflowdataState {}

class PostLoadedState extends WaterflowdataState {
  Map<String, int> graphData = {};

  PostLoadedState(this.graphData);
}

class PostErrorState extends WaterflowdataState {
  final String errorMessage;

  PostErrorState(this.errorMessage);
}
