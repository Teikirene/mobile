import 'package:bui_tuan_kiet/event/home_event.dart';
import 'package:bui_tuan_kiet/state/home_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(HomeInitial()) {
    on<GoToDailyEvent>((event, emit) => emit(NavigateToDaily()));
    on<GoToHistoryEvent>((event, emit) => emit(NavigateToHistory()));
  }
}
