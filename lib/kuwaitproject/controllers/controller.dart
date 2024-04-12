//
// import 'dart:io';
//
// import 'package:bloc/bloc.dart';
// import 'package:dio/dio.dart';
// import 'package:equatable/equatable.dart';
// import 'package:flutter/services.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:time_machine/time_machine.dart' as tz;
// import 'package:time_machine/time_machine.dart';
// import 'package:time_machine/time_machine_text_patterns.dart';
// import '../../network/repositry.dart';
// import '../../services/dashboard_service.dart';
// import '../models/Telemetricsdata.dart';
// import '../models/modelclass.dart';
//
// // import '../../models/devicequery.dart';
// // import '../../network/repositry.dart';
//
// abstract class ApiDataState extends Equatable {
//    ApiDataState();
//
//   @override
//   List<farmer_kuwait> get props => [];
// }
//
// class ApiDataInitial extends ApiDataState {
//
// }
//
// class ApiDataLoading extends ApiDataState {}
//
// class ApiDataSuccess extends ApiDataState {
//    List<farmer_kuwait> data=[];
//   //
//   ApiDataSuccess(this.data);
//
//   // @override
//   List<farmer_kuwait> get props => data;
// }
// class ApiDataFailure extends ApiDataState {
//   final String Error;
//   ApiDataFailure(this.Error);
// }
// class ApiDataNetwork extends ApiDataState {
//   final String Error;
//   ApiDataNetwork(this.Error);
// }
// class ApiDataServerNotReachable extends ApiDataState {
//   final String Error;
//   ApiDataServerNotReachable(this.Error);
// }
//
// class ApiDataCubit extends Cubit<ApiDataState> {
//   ApiDataCubit() : super(ApiDataInitial());
//   DashboardService r=new DashboardService();
//   Repositry  rrep=new Repositry();
//
//   final List<String> deviceEUIIDs=[];
//   DateTime currentDateTime = DateTime.now();
//
//   void fetchData({required int farmerid}) async {
//     emit(ApiDataLoading());
//   print("updating loading state");
//     try {
//
//       Map<String, dynamic> response = await Repositry.getapis(passid: farmerid,subpath:'farmer/kuwaitproject' );
//       print("updating loading stateefegr");
//       // Map<String, dynamic> response = await getdata(devicenumber);
//       print(response);
//       if (response['success']??false) {
//         if(response['data']!=null ||response['data'] !=[]) {
//           try{
//             print("updating loading stateefegr");
//             List<farmer_kuwait> telematicDataList = (response['data'] as List) .map((data) => farmer_kuwait.fromJson(data)).toList();
//             deviceEUIIDs.addAll(telematicDataList.map((element) { return "'${element.deviceEUIID.toString()}'"; }).toList());
//             print(deviceEUIIDs);
//             fetchDevicesData(data: telematicDataList,devices: deviceEUIIDs.toString());
//            // ApiDataSuccess(telematicDataList);
//
//           }
//           catch(e){
//             print("catch e ");
//             emit(ApiDataFailure('No records found. try again'));
//           }
//
//         }
//         else{
//           emit(ApiDataFailure('No records found. try again'));
//         }
//
//       }
//       else {
//         emit(ApiDataFailure(response['message']));
//       }
//       // return telematicDataList;
//     } on DioError catch (e) {
//       print('error meesgae ${e}');
//
//       if (DioErrorType.connectTimeout == e.type ||
//           DioErrorType.receiveTimeout == e.type) {
//         emit(ApiDataFailure(
//             "Server is not reachable.\n Please try again"));
//       } else if (DioErrorType.response == e.type) {
//         emit(ApiDataServerNotReachable("Problem connecting to the server. Please try again."));
//         // 4xx 5xx response
//         // throw exception...
//       } else if (e.type == DioErrorType.other && e.error is SocketException) {
//         if (e.message.contains('SocketException')) {
//           emit(ApiDataNetwork('                      Server is not reachable.\n Please verify your internet connection and try again'));
//         }
//       } else {
//         emit(ApiDataFailure("Problem connecting to the server. Please try again."));
//       }
//
//       print("error is $e");
//     }
//   }
//    fetchDevicesData({required List<farmer_kuwait> data ,required String devices}) async* {
//      print("updating loading state v2");
//     try {
//
//       await tz.TimeMachine.initialize({
//         'rootBundle': rootBundle,
//       });
//       print('Hello, ${DateTimeZone.local} from the Dart Time Machine!\n');
//
//       var tzdb = await DateTimeZoneProviders.tzdb;
//
//
//       var now = Instant.now();
//
//       // if()
//       var paris = await tzdb["Asia/Kolkata"];
//       var convertedtime = now.inZone(paris).toString('yyyy-MM-dd');
//       var convertedenddate = now.inZone(paris).toString('yyyy-MM-dd HH:mm');
//
//
//       Map<String, dynamic> body = {
//         'deviceList': devices,
//         "starttime": convertedtime.toString(),
//         "Endtime": convertedenddate.toString()
//       };
//
//
//
//       Map<String, dynamic> response = await Repositry.Postapis(subpath: 'telematic/temphub',passid:body);
//
//       // Map<String, dynamic> response = await getdata(devicenumber);
//       if (response['success'] ?? false) {
//         if (response['data'] != null || response['data'] != []) {
//           try {
//             List<output> telematicDataList = (response['data'] as List)
//                 .map((data) => output.fromJson(data))git add .
// git commit -m "Initial commit"
//                 .toList();
//             telematicDataList.forEach((outputdata) {
//               // if(key=='DeviceID')
//               data.forEach((element) {
//                 if(outputdata.deviceID==element.deviceEUIID) {
//                   // element.(
//                   element.currenthumidity= outputdata.humidity;
//                 element.currenttempurature= outputdata.temperature;
//                 element.maxhumidity= outputdata.mAXHumidity;
//                   element.minhumidity= outputdata.mINHumidity;
//                   element.maxtempurature= outputdata.mAXTemeprature;
//                   element.mintempurature= outputdata.mINTemperature;
//                   element.sensordateandtime= outputdata.sensorDataPacketDateTime;
//                   element.cretedateandtime=outputdata.createDate;
//
//                 }
//               });
//             });
// print("apidate updatev @@@@@@@@@@@@@@@@@@@");
//
//             emit (ApiDataSuccess(data.toList()));
import 'dart:io';

import 'package:bloc/bloc.dart';
// import 'package:cultyvate/kuwaitproject/controllers/userstare.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
// user_bloc.dart
import 'package:time_machine/time_machine.dart' as tz;
import 'package:time_machine/time_machine.dart';
import '../../network/repositry.dart';
import '../../services/dashboard_service.dart';
import '../models/Telemetricsdata.dart';
import '../models/modelclass.dart';
import 'package:equatable/equatable.dart';

import 'deviceevent.dart';
import 'userstare.dart';

// States




class UserBloc extends Bloc<UserEvent, UserState> {
  final List<String> deviceEUIIDs = [];
  // final UserRepository userRepository = UserRepository();
  UserBloc() : super(UserLoading());
  // @override
  // UserState get initialState => UserLoading();

  @override
  Stream<UserState> mapEventToState(UserEvent event) async* {
    if (event is FetchUsers) {

      yield UserLoading();

      try {
        print('farmer/kuwaitproject');
        Map<String, dynamic> response = await Repositry.getapis(passid: event.farmerID, subpath: 'farmer/kuwaitproject');
        if (response['success'] ?? false) {
          if (response['data'] != null || response['data'] != []) {
            try {
              List<farmer_kuwait> telematicDataList =(response['data'] as List).map((data) => farmer_kuwait.fromJson(data)).toList();
              deviceEUIIDs.addAll(telematicDataList.map((element) {
                return "'${element.deviceEUIID.toString()}'";
              }).toList());



              await tz.TimeMachine.initialize({'rootBundle': rootBundle});

              var tzdb = await DateTimeZoneProviders.tzdb;
              var now = Instant.now();
              var paris = await tzdb["Asia/Kolkata"];
              var convertedtime = now.inZone(paris).toString('yyyy-MM-dd');
              var convertedenddate = now.inZone(paris).toString('yyyy-MM-dd HH:mm');

              Map<String, dynamic> body = {
                'deviceList': deviceEUIIDs,
                "starttime": convertedtime.toString(),
                "Endtime": convertedenddate.toString()
              };

              Map<String, dynamic> responsea = await Repositry.Postapis(subpath: 'telematic/temphub', passid: body);

              if (responsea['success'] ?? false) {
                if (responsea['data'] != null || responsea['data'] != []) {
                  try {
                    print("responce data is telemateics  ${responsea['data']}");
                    List<output> telematicDataListlocal = (responsea['data'] as List).map((data) => output.fromJson(data)).toList();
                    telematicDataListlocal.forEach((outputdata) {
                      print("data element is ${outputdata.mAXHumidity}");

                      telematicDataList.forEach((element) {
                        if (outputdata.deviceID == element.deviceEUIID) {
                          element.currenthumidity = outputdata.humidity;
                          element.currenttempurature = outputdata.temperature;
                          element.maxhumidity = outputdata.mAXHumidity;
                          element.minhumidity = outputdata.mINHumidity;
                          element.maxtempurature = outputdata.mAXTemeprature;
                          element.mintempurature = outputdata.mINTemperature;
                          element.sensordateandtime = outputdata.sensorDataPacketDateTime;
                          element.cretedateandtime = outputdata.createDate;
                        }
                      });



                    });
                    print("************************");
                    try{
                      print("************************");
                      // final value =event.telematicDataList;
                      print("value before ");
                      // yield UserLoaded(value.toList());
                      // emit( UserError('No records found. try again'));
                      yield UserLoaded(telematicDataList);
                      print("value after ");
                    }
                    catch(e){
                      print('while updationg error $e');
                    }
                  }
                  catch (e) {
                    yield UserError('No records found. try again');
                  }
                }
                else{
                  yield UserError('No records found. try again');
                }

              }
              else {
                yield UserError(response['message']);
              }


             // event.userbloc.add(UserDevicestatus( deviceEUIIDs.toString(),telematicDataList,event.userbloc));
            } catch (e) {
              yield UserError('No records found. try again');
            }
          } else {
            yield UserError('No records found. try again');
          }
        } else {
          yield UserError(response['message']);
        }
      } on DioError catch (e) {

        if (DioErrorType.connectTimeout == e.type || DioErrorType.receiveTimeout == e.type) {
          yield UserError("Server is not reachable.\n Please try again");
        } else if (DioErrorType.response == e.type) {
          yield UserError("Problem connecting to the server. Please try again.");
        } else if (e.type == DioErrorType.other && e.error is SocketException) {
          if (e.message.contains('SocketException')) {
            yield UserError(
                'Server is not reachable.\n Please verify your internet connection and try again');
          }
        } else {
          yield UserError("Problem connecting to the server. Please try again.");
        }

        print("error is $e");
      }
      catch (e) {
        yield UserError("Failed to load users: $e");
      }
    }
    else if(event is UserDevicestatus){


        try {
          yield UserLoading();

          await tz.TimeMachine.initialize({'rootBundle': rootBundle});

          var tzdb = await DateTimeZoneProviders.tzdb;
          var now = Instant.now();
          var paris = await tzdb["Asia/Kolkata"];
          var convertedtime = now.inZone(paris).toString('yyyy-MM-dd');
          var convertedenddate = now.inZone(paris).toString('yyyy-MM-dd HH:mm');

          Map<String, dynamic> body = {
            'deviceList': event.deviceEUIIDs,
            "starttime": convertedtime.toString(),
            "Endtime": convertedenddate.toString()
          };
          print('body is ${body}');
          Map<String, dynamic> response = await Repositry.Postapis(
              subpath: 'telematic/temphub', passid: body);

          if (response['success'] ?? false) {
            if (response['data'] != null || response['data'] != []) {
              try {
                print("responce data is telemateics  ${response['data']}");
                List<output> telematicDataList = (response['data'] as List)
                    .map((data) => output.fromJson(data))
                    .toList();
                telematicDataList.forEach((outputdata) {
                  print("data element is ${outputdata.mAXHumidity}");

                  event.telematicDataList.forEach((element) {
                    if (outputdata.deviceID == element.deviceEUIID) {
                      element.currenthumidity = outputdata.humidity;
                      element.currenttempurature = outputdata.temperature;
                      element.maxhumidity = outputdata.mAXHumidity;
                      element.minhumidity = outputdata.mINHumidity;
                      element.maxtempurature = outputdata.mAXTemeprature;
                      element.mintempurature = outputdata.mINTemperature;
                      element.sensordateandtime =
                          outputdata.sensorDataPacketDateTime;
                      element.cretedateandtime = outputdata.createDate;
                    }
                  });
                });

                print("************************");
                try {
                  print("************************");
                  final value = event.telematicDataList;
                  print("value before ");
                  yield UserLoaded(value.toList());

                  yield UserLoaded(value.toList());
                  print("value after ");
                }
                catch (e) {
                  print('while updationg error $e');
                }
              }
              catch (e) {
                yield UserError('No records found. try again');
              }
            }
            else {
              yield UserError('No records found. try again');
            }
          }
          else {
            yield UserError(response['message']);
          }

              }
      on DioError catch (e) {
print(e);
        if (DioErrorType.connectTimeout == e.type ||
            DioErrorType.receiveTimeout == e.type) {
          yield UserError(
              "Server is not reachable.\n Please try again");
        } else if (DioErrorType.response == e.type) {
          yield UserError("Problem connecting to the server. Please try again.");
          // 4xx 5xx response
          // throw exception...
        } else if (e.type == DioErrorType.other && e.error is SocketException) {
          if (e.message.contains('SocketException')) {
            yield UserError('                      Server is not reachable.\n Please verify your internet connection and try again');
          }
        } else {
          yield UserError("Problem connecting to the server. Please try again.");
        }

        print("error is $e");
      }
    }
  }


}




abstract class ApiDataState extends Equatable {
  ApiDataState();

  @override
  List<farmer_kuwait> get props => [];
}

class ApiDataInitial extends ApiDataState {}

class ApiDataLoading extends ApiDataState {}

class ApiDataSuccess extends ApiDataState {
  final List<farmer_kuwait> data;

  ApiDataSuccess(this.data);

  @override
  List<farmer_kuwait> get props=> data;
}

class ApiDataFailure extends ApiDataState {
  final String Error;

  ApiDataFailure(this.Error);
}

class ApiDataNetwork extends ApiDataState {
  final String Error;

  ApiDataNetwork(this.Error);
}


class ApiDataServerNotReachable extends ApiDataState {
  final String Error;

  ApiDataServerNotReachable(this.Error);
}



class ApiDataCubit extends Cubit<ApiDataState> {
  ApiDataCubit() : super(ApiDataInitial());
  DashboardService r = DashboardService();
  Repositry rrep = Repositry();

  final List<String> deviceEUIIDs = [];

  void fetchData({required int farmerid}) async {
    emit(ApiDataLoading());
    print("updating loading state");

    try {
      Map<String, dynamic> response = await Repositry.getapis(passid: farmerid, subpath: 'farmer/kuwaitproject');
      if (response['success'] ?? false) {
        if (response['data'] != null || response['data'] != []) {
          try {
            List<farmer_kuwait> telematicDataList =(response['data'] as List).map((data) => farmer_kuwait.fromJson(data)).toList();
            deviceEUIIDs.addAll(telematicDataList.map((element) {
              return "'${element.deviceEUIID.toString()}'";
            }).toList());
            print(deviceEUIIDs);
            fetchDevicesData(data: telematicDataList, devices: deviceEUIIDs.toString());
          } catch (e) {
            emit(ApiDataFailure('No records found. try again'));
          }
        } else {
          emit(ApiDataFailure('No records found. try again'));
        }
      } else {
        emit(ApiDataFailure(response['message']));
      }
    } on DioError catch (e) {
      print('error meesgae ${e}');

      if (DioErrorType.connectTimeout == e.type || DioErrorType.receiveTimeout == e.type) {
        emit(ApiDataFailure("Server is not reachable.\n Please try again"));
      } else if (DioErrorType.response == e.type) {
        emit(ApiDataServerNotReachable("Problem connecting to the server. Please try again."));
      } else if (e.type == DioErrorType.other && e.error is SocketException) {
        if (e.message.contains('SocketException')) {
          emit(ApiDataNetwork(
              'Server is not reachable.\n Please verify your internet connection and try again'));
        }
      } else {
        emit(ApiDataFailure("Problem connecting to the server. Please try again."));
      }

      print("error is $e");
    }
  }

  fetchDevicesData({required List<farmer_kuwait> data, required String devices}) async {
    try {
      await tz.TimeMachine.initialize({'rootBundle': rootBundle});

      var tzdb = await DateTimeZoneProviders.tzdb;
      var now = Instant.now();
      var paris = await tzdb["Asia/Kolkata"];
      var convertedtime = now.inZone(paris).toString('yyyy-MM-dd');
      var convertedenddate = now.inZone(paris).toString('yyyy-MM-dd HH:mm');

      Map<String, dynamic> body = {
        'deviceList': devices,
        "starttime": convertedtime.toString(),
        "Endtime": convertedenddate.toString()
      };

      Map<String, dynamic> response = await Repositry.Postapis(subpath: 'telematic/temphub', passid: body);

      if (response['success'] ?? false) {
        if (response['data'] != null || response['data'] != []) {
          try {
            List<output> telematicDataList =
            (response['data'] as List).map((data) => output.fromJson(data)).toList();
            telematicDataList.forEach((outputdata) {
              data.forEach((element) {
                if (outputdata.deviceID == element.deviceEUIID) {
                  element.currenthumidity = outputdata.humidity;
                  element.currenttempurature = outputdata.temperature;
                  element.maxhumidity = outputdata.mAXHumidity;
                  element.minhumidity = outputdata.mINHumidity;
                  element.maxtempurature = outputdata.mAXTemeprature;
                  element.mintempurature = outputdata.mINTemperature;
                  element.sensordateandtime = outputdata.sensorDataPacketDateTime;
                  element.cretedateandtime = outputdata.createDate;
                }
              });
            });
            print("apidate updatev @@@@@@@@@@@@@@@@@@@");
            emit (ApiDataSuccess(data.toList()));

            print("apidate updatev %%%%%%%%%%%%%%%%");
          }
          catch (e) {
              print("error $e");
            emit(ApiDataFailure('No records found. try again'));
          }
          //
        }
          else{
            emit(ApiDataFailure('No records found. try again'));
          }

        }
        else {
          emit(ApiDataFailure(response['message']));
        }
        // return telematicDataList;
      }
      on DioError catch (e) {
        print('error meesgae ${e}');

        if (DioErrorType.connectTimeout == e.type ||
            DioErrorType.receiveTimeout == e.type) {
          emit(ApiDataFailure(
              "Server is not reachable.\n Please try again"));
        } else if (DioErrorType.response == e.type) {
          emit(ApiDataServerNotReachable("Problem connecting to the server. Please try again."));
          // 4xx 5xx response
          // throw exception...
        } else if (e.type == DioErrorType.other && e.error is SocketException) {
          if (e.message.contains('SocketException')) {
            emit(ApiDataNetwork('                      Server is not reachable.\n Please verify your internet connection and try again'));
          }
        } else {
          emit(ApiDataFailure("Problem connecting to the server. Please try again."));
        }

        print("error is $e");
      }
      }

// catch(e){}

    }
