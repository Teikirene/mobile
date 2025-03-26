import 'package:bui_tuan_kiet/event/daily_event.dart';
import 'package:bui_tuan_kiet/helper/api_helper.dart';
import 'package:bui_tuan_kiet/helper/shared_preference_helper.dart';
import 'package:bui_tuan_kiet/state/daily_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


class DailyBloc extends Bloc<DailyEvent, DailyState> {
  DailyBloc() : super(DailyInitial()) {
    on<FetchCalorieEvent>((event, emit) async {
      emit(CalorieLoading(event.mealType)); 
      try {
        final foodCalories = await ApiHelper.fetchMultipleCalories(event.foods);
        for (var food in foodCalories) {
          await SharedPreferenceHelper.saveMeal(
            food['name'],
            food['gram'],
            food['calorie'],
            event.mealType,
          );
        }
        emit(CalorieLoaded(event.mealType, foodCalories));
      } catch (e) {
        emit(CalorieError(e.toString()));
      }
    });
  }
}