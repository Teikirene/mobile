import 'package:bui_tuan_kiet/event/history_event.dart';
import 'package:bui_tuan_kiet/helper/shared_preference_helper.dart';
import 'package:bui_tuan_kiet/state/history_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  HistoryBloc() : super(HistoryInitial()) {
    on<FetchHistoryEvent>(_onFetchHistory);
  }

  Future<void> _onFetchHistory(FetchHistoryEvent event, Emitter<HistoryState> emit) async {
    emit(HistoryLoading());
    try {
      final history = await SharedPreferenceHelper.getMealHistory();
      // Nhóm dữ liệu theo ngày
      final Map<String, List<Map<String, dynamic>>> historyByDate = {};
      for (var meal in history) {
        final date = meal['date'] as String;
        if (!historyByDate.containsKey(date)) {
          historyByDate[date] = [];
        }
        historyByDate[date]!.add(meal);
      }
      final sortedHistoryByDate = Map.fromEntries(
        historyByDate.entries.toList()
          ..sort((a, b) => b.key.compareTo(a.key)),
      );
      emit(HistoryLoaded(sortedHistoryByDate));
    } catch (e) {
      emit(HistoryError('Failed to load history: $e'));
    }
  }
}