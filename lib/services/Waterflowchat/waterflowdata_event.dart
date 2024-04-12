part of 'waterflowdata_bloc.dart';

@immutable
abstract class WaterflowdataFetchEvent {
  final String duration;
  final Map<String, dynamic> postData;

  WaterflowdataFetchEvent(this.duration, this.postData);
}