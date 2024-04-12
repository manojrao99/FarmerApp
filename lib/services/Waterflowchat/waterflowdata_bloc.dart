import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../network/repositry.dart';

part 'waterflowdata_event.dart';
part 'waterflowdata_state.dart';

class WaterflowdataBloc extends Bloc<WaterflowdataFetchEvent, WaterflowdataState> {
  WaterflowdataBloc() : super(WaterflowdataInitial());

  @override
  Stream<WaterflowdataState> mapEventToState(WaterflowdataFetchEvent event) async* {
      if (event is WaterflowdataFetchEvent) {
        yield PostLoadingState();
        try {
          final posts = await Repositry.Postapis(passid: event.postData, subpath: '/telematic/history');
          if (posts.isNotEmpty && (posts['success'] ?? false)) {
            PostLoadedState(posts['data']['flowValues']);
          }
          yield PostLoadedState(posts);
        } catch (e) {
          yield PostErrorState('Failed to load posts');
        }
      }
    }



}
