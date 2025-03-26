abstract class DailyEvent {}

class FetchCalorieEvent extends DailyEvent {
  final String mealType; 
  final List<Map<String, dynamic>> foods;

  FetchCalorieEvent({required this.mealType, required this.foods});
}