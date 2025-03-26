abstract class DailyState {}

class DailyInitial extends DailyState {}

class CalorieLoading extends DailyState {
  final String mealType; 

  CalorieLoading(this.mealType);
}

class CalorieLoaded extends DailyState {
  final String mealType;
  final List<Map<String, dynamic>> foodCalories;

  CalorieLoaded(this.mealType, this.foodCalories);
}

class CalorieError extends DailyState {
  final String message;

  CalorieError(this.message);
}