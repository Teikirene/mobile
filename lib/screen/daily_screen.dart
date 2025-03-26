import 'package:bui_tuan_kiet/bloc/daily_bloc.dart';
import 'package:bui_tuan_kiet/event/daily_event.dart';
import 'package:bui_tuan_kiet/helper/shared_preference_helper.dart';
import 'package:bui_tuan_kiet/state/daily_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


class DailyScreen extends StatefulWidget {
  const DailyScreen({super.key});

  @override
  _DailyScreenState createState() => _DailyScreenState();
}

class _DailyScreenState extends State<DailyScreen> {
  final Map<String, List<TextEditingController>> _foodControllers = {
    'breakfast': [],
    'lunch': [],
    'dinner': [],
    'snack': [],
  };
  final Map<String, List<TextEditingController>> _gramControllers = {
    'breakfast': [],
    'lunch': [],
    'dinner': [],
    'snack': [],
  };
  final Map<String, List<Map<String, dynamic>>> _mealCalories = {
    'breakfast': [],
    'lunch': [],
    'dinner': [],
    'snack': [],
  };

  @override
  void initState() {
    super.initState();
    _loadTempData();
  }

  Future<void> _loadTempData() async {
    for (var mealType in ['breakfast', 'lunch', 'dinner', 'snack']) {
      final tempMeals = await SharedPreferenceHelper.getTempMeal(mealType);
      final today = DateTime.now().toString().split(' ')[0];
      final historyMeals = (await SharedPreferenceHelper.getMealHistory())
          .where((meal) => meal['mealType'] == mealType && meal['date'] == today)
          .toList();

      setState(() {
        if (tempMeals.isNotEmpty) {
          _foodControllers[mealType] = tempMeals.map((meal) => TextEditingController(text: meal['food'])).toList();
          _gramControllers[mealType] = tempMeals.map((meal) => TextEditingController(text: meal['gram'].toString())).toList();
        } else {
          _foodControllers[mealType]!.add(TextEditingController());
          _gramControllers[mealType]!.add(TextEditingController());
        }
        _mealCalories[mealType] = historyMeals;
      });
    }
  }

  void _addFoodField(String mealType) {
    setState(() {
      _foodControllers[mealType]!.add(TextEditingController());
      _gramControllers[mealType]!.add(TextEditingController());
      _saveTempData(mealType);
    });
  }

  Future<void> _saveTempData(String mealType) async {
    final foods = _foodControllers[mealType]!.asMap().entries.map((entry) {
      final index = entry.key;
      final food = entry.value.text.trim();
      final gram = int.tryParse(_gramControllers[mealType]![index].text) ?? 0;
      return {'food': food, 'gram': gram};
    }).where((f) => (f['food'] as String).isNotEmpty).toList();
    await SharedPreferenceHelper.saveTempMeal(mealType, foods);
  }

  @override
  void dispose() {
    _foodControllers.values.forEach((controllers) => controllers.forEach((c) => c.dispose()));
    _gramControllers.values.forEach((controllers) => controllers.forEach((c) => c.dispose()));
    super.dispose();
  }

  int _calculateMealCalories(String mealType) {
    return _mealCalories[mealType]!.fold<int>(
      0,
      (sum, item) => sum + (item['calorie'] as int),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DailyBloc(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Thực đơn'),
          backgroundColor: Colors.blueAccent,
        ),
        body: BlocConsumer<DailyBloc, DailyState>(
          listener: (context, state) {
            if (state is CalorieLoaded) {
              setState(() {
                _mealCalories[state.mealType] = state.foodCalories;
              });
              _saveTempData(state.mealType);
            } else if (state is CalorieError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error: ${state.message}')),
              );
            }
          },
          builder: (context, state) {
            final totalCalories = _mealCalories.values
                .expand((calories) => calories)
                .fold<int>(0, (sum, item) => sum + (item['calorie'] as int));

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.blueAccent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Tổng số calories tiêu thụ: $totalCalories calo',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Bữa sáng
                  Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                      color: Colors.green.withOpacity(0.1),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Row(
                              children: [
                                Icon(
                                  Icons.free_breakfast,
                                  color: Colors.green,
                                  size: 28,
                                ),
                                SizedBox(width: 10),
                                Text(
                                  'Bữa sáng',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              '${_calculateMealCalories('breakfast')} kcal',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        ...List.generate(_foodControllers['breakfast']!.length, (index) {
                          return Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: TextField(
                                      controller: _foodControllers['breakfast']![index],
                                      decoration: InputDecoration(
                                        labelText: 'Tên món ăn ${index + 1}',
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                      onChanged: (_) => _saveTempData('breakfast'),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: TextField(
                                      controller: _gramControllers['breakfast']![index],
                                      decoration: InputDecoration(
                                        labelText: 'Gram',
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                      keyboardType: TextInputType.number,
                                      onChanged: (_) => _saveTempData('breakfast'),
                                    ),
                                  ),
                                ],
                              ),
                              if (index < _foodControllers['breakfast']!.length - 1)
                                const SizedBox(height: 5),
                            ],
                          );
                        }),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton(
                              onPressed: () => _addFoodField('breakfast'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey.shade300,
                                foregroundColor: Colors.black87,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text('Thêm món ăn'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                final foods = _foodControllers['breakfast']!.asMap().entries.map((entry) {
                                  final index = entry.key;
                                  final food = entry.value.text.trim();
                                  final gram = int.tryParse(_gramControllers['breakfast']![index].text) ?? 0;
                                  return {'food': food, 'gram': gram};
                                }).where((f) => (f['food'] as String).isNotEmpty && (f['gram'] as int) > 0).toList();

                                if (foods.isNotEmpty) {
                                  context.read<DailyBloc>().add(FetchCalorieEvent(
                                    mealType: 'breakfast',
                                    foods: foods,
                                  ));
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Vui lòng nhập ít nhất một món ăn hợp lệ cho Bữa sáng')),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: state is CalorieLoading && (state as CalorieLoading).mealType == 'breakfast'
                                  ? const CircularProgressIndicator(color: Colors.white)
                                  : const Text(
                                      'Tính Calo',
                                      style: TextStyle(color: Colors.white),
                                    ),
                            ),
                          ],
                        ),
                        if (_mealCalories['breakfast']!.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _mealCalories['breakfast']!.length,
                              itemBuilder: (context, index) {
                                final food = _mealCalories['breakfast']![index];
                                return ListTile(
                                  title: Text('${food['name']} (${food['gram']}g)'),
                                  trailing: Text('${food['calorie']} kcal'),
                                );
                              },
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  // Bữa trưa
                  Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                      color: Colors.orange.withOpacity(0.1),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Row(
                              children: [
                                Icon(
                                  Icons.lunch_dining,
                                  color: Colors.orange,
                                  size: 28,
                                ),
                                SizedBox(width: 10),
                                Text(
                                  'Bữa trưa',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              '${_calculateMealCalories('lunch')} kcal',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        ...List.generate(_foodControllers['lunch']!.length, (index) {
                          return Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: TextField(
                                      controller: _foodControllers['lunch']![index],
                                      decoration: InputDecoration(
                                        labelText: 'Tên món ăn ${index + 1}',
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                      onChanged: (_) => _saveTempData('lunch'),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: TextField(
                                      controller: _gramControllers['lunch']![index],
                                      decoration: InputDecoration(
                                        labelText: 'Gram',
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                      keyboardType: TextInputType.number,
                                      onChanged: (_) => _saveTempData('lunch'),
                                    ),
                                  ),
                                ],
                              ),
                              if (index < _foodControllers['lunch']!.length - 1)
                                const SizedBox(height: 5),
                            ],
                          );
                        }),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton(
                              onPressed: () => _addFoodField('lunch'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey.shade300,
                                foregroundColor: Colors.black87,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text('Thêm món ăn'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                final foods = _foodControllers['lunch']!.asMap().entries.map((entry) {
                                  final index = entry.key;
                                  final food = entry.value.text.trim();
                                  final gram = int.tryParse(_gramControllers['lunch']![index].text) ?? 0;
                                  return {'food': food, 'gram': gram};
                                }).where((f) => (f['food'] as String).isNotEmpty && (f['gram'] as int) > 0).toList();

                                if (foods.isNotEmpty) {
                                  context.read<DailyBloc>().add(FetchCalorieEvent(
                                    mealType: 'lunch',
                                    foods: foods,
                                  ));
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Vui lòng nhập ít nhất một món ăn hợp lệ cho Bữa trưa')),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: state is CalorieLoading && (state as CalorieLoading).mealType == 'lunch'
                                  ? const CircularProgressIndicator(color: Colors.white)
                                  : const Text(
                                      'Tính Calo',
                                      style: TextStyle(color: Colors.white),
                                    ),
                            ),
                          ],
                        ),
                        if (_mealCalories['lunch']!.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _mealCalories['lunch']!.length,
                              itemBuilder: (context, index) {
                                final food = _mealCalories['lunch']![index];
                                return ListTile(
                                  title: Text('${food['name']} (${food['gram']}g)'),
                                  trailing: Text('${food['calorie']} kcal'),
                                );
                              },
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  // Bữa tối
                  Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                      color: Colors.blue.withOpacity(0.1),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Row(
                              children: [
                                Icon(
                                  Icons.dinner_dining,
                                  color: Colors.blue,
                                  size: 28,
                                ),
                                SizedBox(width: 10),
                                Text(
                                  'Bữa tối',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              '${_calculateMealCalories('dinner')} kcal',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        ...List.generate(_foodControllers['dinner']!.length, (index) {
                          return Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: TextField(
                                      controller: _foodControllers['dinner']![index],
                                      decoration: InputDecoration(
                                        labelText: 'Tên món ăn ${index + 1}',
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                      onChanged: (_) => _saveTempData('dinner'),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: TextField(
                                      controller: _gramControllers['dinner']![index],
                                      decoration: InputDecoration(
                                        labelText: 'Gram',
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                      keyboardType: TextInputType.number,
                                      onChanged: (_) => _saveTempData('dinner'),
                                    ),
                                  ),
                                ],
                              ),
                              if (index < _foodControllers['dinner']!.length - 1)
                                const SizedBox(height: 5),
                            ],
                          );
                        }),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton(
                              onPressed: () => _addFoodField('dinner'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey.shade300,
                                foregroundColor: Colors.black87,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text('Thêm món ăn'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                final foods = _foodControllers['dinner']!.asMap().entries.map((entry) {
                                  final index = entry.key;
                                  final food = entry.value.text.trim();
                                  final gram = int.tryParse(_gramControllers['dinner']![index].text) ?? 0;
                                  return {'food': food, 'gram': gram};
                                }).where((f) => (f['food'] as String).isNotEmpty && (f['gram'] as int) > 0).toList();

                                if (foods.isNotEmpty) {
                                  context.read<DailyBloc>().add(FetchCalorieEvent(
                                    mealType: 'dinner',
                                    foods: foods,
                                  ));
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Vui lòng nhập ít nhất một món ăn hợp lệ cho Bữa tối')),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: state is CalorieLoading && (state as CalorieLoading).mealType == 'dinner'
                                  ? const CircularProgressIndicator(color: Colors.white)
                                  : const Text(
                                      'Tính Calo',
                                      style: TextStyle(color: Colors.white),
                                    ),
                            ),
                          ],
                        ),
                        if (_mealCalories['dinner']!.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _mealCalories['dinner']!.length,
                              itemBuilder: (context, index) {
                                final food = _mealCalories['dinner']![index];
                                return ListTile(
                                  title: Text('${food['name']} (${food['gram']}g)'),
                                  trailing: Text('${food['calorie']} kcal'),
                                );
                              },
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  // Bữa phụ
                  Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                      color: Colors.yellow.withOpacity(0.1),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Row(
                              children: [
                                Icon(
                                  Icons.fastfood,
                                  color: Colors.yellow,
                                  size: 28,
                                ),
                                SizedBox(width: 10),
                                Text(
                                  'Bữa phụ',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              '${_calculateMealCalories('snack')} kcal',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        ...List.generate(_foodControllers['snack']!.length, (index) {
                          return Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: TextField(
                                      controller: _foodControllers['snack']![index],
                                      decoration: InputDecoration(
                                        labelText: 'Tên món ăn ${index + 1}',
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                      onChanged: (_) => _saveTempData('snack'),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: TextField(
                                      controller: _gramControllers['snack']![index],
                                      decoration: InputDecoration(
                                        labelText: 'Gram',
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                      keyboardType: TextInputType.number,
                                      onChanged: (_) => _saveTempData('snack'),
                                    ),
                                  ),
                                ],
                              ),
                              if (index < _foodControllers['snack']!.length - 1)
                                const SizedBox(height: 5),
                            ],
                          );
                        }),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton(
                              onPressed: () => _addFoodField('snack'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey.shade300,
                                foregroundColor: Colors.black87,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text('Thêm món ăn'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                final foods = _foodControllers['snack']!.asMap().entries.map((entry) {
                                  final index = entry.key;
                                  final food = entry.value.text.trim();
                                  final gram = int.tryParse(_gramControllers['snack']![index].text) ?? 0;
                                  return {'food': food, 'gram': gram};
                                }).where((f) => (f['food'] as String).isNotEmpty && (f['gram'] as int) > 0).toList();

                                if (foods.isNotEmpty) {
                                  context.read<DailyBloc>().add(FetchCalorieEvent(
                                    mealType: 'snack',
                                    foods: foods,
                                  ));
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Vui lòng nhập ít nhất một món ăn hợp lệ cho Bữa phụ')),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.yellow,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: state is CalorieLoading && (state as CalorieLoading).mealType == 'snack'
                                  ? const CircularProgressIndicator(color: Colors.white)
                                  : const Text(
                                      'Tính Calo',
                                      style: TextStyle(color: Colors.white),
                                    ),
                            ),
                          ],
                        ),
                        if (_mealCalories['snack']!.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _mealCalories['snack']!.length,
                              itemBuilder: (context, index) {
                                final food = _mealCalories['snack']![index];
                                return ListTile(
                                  title: Text('${food['name']} (${food['gram']}g)'),
                                  trailing: Text('${food['calorie']} kcal'),
                                );
                              },
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}