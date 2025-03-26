import 'package:bui_tuan_kiet/bloc/home_bloc.dart';
import 'package:bui_tuan_kiet/event/home_event.dart';
import 'package:bui_tuan_kiet/helper/shared_preference_helper.dart';
import 'package:bui_tuan_kiet/screen/daily_screen.dart';
import 'package:bui_tuan_kiet/screen/history_screen.dart';
import 'package:bui_tuan_kiet/state/home_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<int> _totalCaloriesFuture;

  @override
  void initState() {
    super.initState();
    _totalCaloriesFuture = _getTotalCaloriesForToday();
  }

  Future<int> _getTotalCaloriesForToday() async {
    try {
      final meals = await SharedPreferenceHelper.getMealHistory();
      print('Meals: $meals');
      final today = DateTime.now().toString().split(' ')[0];
      print('Today: $today');
      final filteredMeals = meals.where((meal) => meal['date'] == today).toList();
      print('Filtered Meals: $filteredMeals');
      return filteredMeals.fold<int>(0, (sum, meal) {
        final calorie = meal['calorie'];
        if (calorie is int) {
          return sum + calorie;
        } else if (calorie is double) {
          return sum + calorie.round();
        } else {
          print('Calo: $calorie');
          return sum;
        }
      });
    } catch (e) {
      print('Có lỗi xảy ra: $e');
      return 0; // Trả về 0 nếu có lỗi
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HomeBloc(),
      child: BlocConsumer<HomeBloc, HomeState>(
        listener: (context, state) {
          if (state is NavigateToDaily) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => DailyScreen()));
          } else if (state is NavigateToHistory) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => HistoryScreen()));
          }
        },
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: const Padding(
                padding: EdgeInsets.only(left: 3),
                child: Text(
                  'Calorie Tracker',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
              backgroundColor: Colors.green,
            ),
            body: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(
                    'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSDvkI0f9f3mPBrnNXwZf9lLjNLLFXl9nJZfA&s',
                  ),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.3),
                    BlendMode.dstATop,
                  ),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: 150,
                      width: 150,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRlpG_W0_vkgg7YXKu_ENAQgBaFqh-kqpaGuA&s',
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(child: CircularProgressIndicator());
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Center(
                              child: Text(
                                'Failed to load image',
                                style: TextStyle(color: Colors.grey.shade600),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8), // Nền mờ để văn bản dễ đọc
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: FutureBuilder<int>(
                        future: _totalCaloriesFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          } else if (snapshot.hasError) {
                            return Text(
                              'Error: ${snapshot.error}',
                              style: const TextStyle(color: Colors.red),
                            );
                          }
                          final totalCalories = snapshot.data ?? 0;
                          return Text(
                            'Số calo hôm nay đã tiêu thụ: $totalCalories kcal',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                            textAlign: TextAlign.center,
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 40),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: ElevatedButton(
                              onPressed: () {
                                context.read<HomeBloc>().add(GoToDailyEvent());
                                setState(() {
                                  _totalCaloriesFuture = _getTotalCaloriesForToday();
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Thực đơn hôm nay',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: ElevatedButton(
                              onPressed: () => context.read<HomeBloc>().add(GoToHistoryEvent()),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey.shade300,
                                foregroundColor: Colors.black87,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Lịch sử',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}