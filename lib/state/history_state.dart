abstract class HistoryState {}

class HistoryInitial extends HistoryState {}

class HistoryLoading extends HistoryState {}

class HistoryLoaded extends HistoryState {
  final Map<String, List<Map<String, dynamic>>> historyByDate;

  HistoryLoaded(this.historyByDate);
}

class HistoryError extends HistoryState {
  final String message;

  HistoryError(this.message);
}