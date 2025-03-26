import 'package:bui_tuan_kiet/bloc/history_bloc.dart';
import 'package:bui_tuan_kiet/event/history_event.dart';
import 'package:bui_tuan_kiet/state/history_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HistoryBloc()..add(FetchHistoryEvent()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Lịch sử thực đơn'),
          backgroundColor: Colors.blueAccent,
        ),
        body: BlocBuilder<HistoryBloc, HistoryState>(
          builder: (context, state) {
            if (state is HistoryLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is HistoryLoaded) {
              final historyByDate = state.historyByDate;
              if (historyByDate.isEmpty) {
                return Center(child: const Text('Chưa có lịch sử thực đơn.'));
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: historyByDate.length,
                itemBuilder: (context, index) {
                  final date = historyByDate.keys.elementAt(index);
                  final meals = historyByDate[date]!;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16.0),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ExpansionTile(
                      title: Text(
                        date,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      children: _buildMealSections(meals),
                    ),
                  );
                },
              );
            } else if (state is HistoryError) {
              return Center(child: Text(state.message));
            }
            return const Center(child: Text('Vui lòng tải lịch sử thực đơn.'));
          },
        ),
      ),
    );
  }

  List<Widget> _buildMealSections(List<Map<String, dynamic>> meals) {
    final mealTypes = ['breakfast', 'lunch', 'dinner', 'snack'];
    final mealNames = {
      'breakfast': 'Bữa sáng',
      'lunch': 'Bữa trưa',
      'dinner': 'Bữa tối',
      'snack': 'Bữa phụ',
    };
    final mealColors = {
      'breakfast': Colors.green.withOpacity(0.1),
      'lunch': Colors.orange.withOpacity(0.1),
      'dinner': Colors.blue.withOpacity(0.1),
      'snack': Colors.yellow.withOpacity(0.1),
    };

    List<Widget> sections = [];
    for (var mealType in mealTypes) {
      final mealsForType = meals.where((meal) => meal['mealType'] == mealType).toList();
      if (mealsForType.isNotEmpty) {
        final totalCalories = mealsForType.fold<int>(
          0,
          (sum, meal) => sum + (meal['calorie'] as int),
        );
        sections.add(
          Container(
            margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            padding: EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: mealColors[mealType],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      mealNames[mealType]!,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      '$totalCalories kcal',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8.0),
                ...mealsForType.map((meal) {
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text('${meal['name']} (${meal['gram']}g)'),
                    trailing: Text('${meal['calorie']} kcal'),
                  );
                }).toList(),
              ],
            ),
          ),
        );
      }
    }
    return sections;
  }
}