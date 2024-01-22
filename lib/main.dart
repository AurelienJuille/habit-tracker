import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:habit_tracker_app/pages/habit_form_page.dart';
import 'package:habit_tracker_app/pages/main_page.dart';
import 'package:habit_tracker_app/pages/settings_page.dart';
import 'package:habit_tracker_app/themes.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Habit {
  String name;
  String description;
  IconData icon;
  Set<DateTime> completedDays;
  int colorIndex;
  Color getColor(BuildContext context) {
    return Provider.of<HabitsProvider>(context).isDarkMode
        ? HSVColor.fromColor(HabitColors.lightColorList[colorIndex])
            .withSaturation(0.8)
            .toColor()
        : HabitColors.lightColorList[colorIndex];
  }

  bool showCalendar;
  bool get isCompletedToday {
    DateTime today = DateTime.now();
    today = DateTime(today.year, today.month, today.day);
    return completedDays.any((date) => date.isAtSameMomentAs(today));
  }

  Habit({
    required this.name,
    required this.description,
    required this.colorIndex,
    required this.icon,
    this.showCalendar = false,
    Set<DateTime>? completedDays,
  }) : completedDays = completedDays ?? <DateTime>{};

  Habit copyWith({
    String? name,
    String? description,
    int? colorIndex,
    IconData? icon,
    Set<DateTime>? completedDays,
    bool? showCalendar,
  }) {
    return Habit(
      name: name ?? this.name,
      description: description ?? this.description,
      colorIndex: colorIndex ?? this.colorIndex,
      icon: icon ?? this.icon,
      completedDays: completedDays ?? Set.from(this.completedDays),
      showCalendar: showCalendar ?? this.showCalendar,
    );
  }

  // Méthode pour convertir l'objet en Map (JSON)
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'colorIndex': colorIndex,
      'icon': icon.codePoint,
      'showCalendar': showCalendar,
      'completedDays':
          completedDays.map((date) => date.toIso8601String()).toList(),
    };
  }

  factory Habit.fromJson(Map<String, dynamic> json) {
    return Habit(
      name: json['name'],
      description: json['description'],
      colorIndex: json['colorIndex'],
      icon: IconData(json['icon'], fontFamily: 'MaterialIcons'),
      showCalendar: json['showCalendar'] ?? false,
      completedDays: (json['completedDays'] as List<dynamic>?)
              ?.map((dateString) => DateTime.parse(dateString))
              .toSet() ??
          <DateTime>{},
    );
  }

  void toggleAccomplishment({DateTime? date}) {
    DateTime selectedDate = date ?? DateTime.now();
    selectedDate =
        DateTime(selectedDate.year, selectedDate.month, selectedDate.day);

    if (completedDays.any((date) => date.isAtSameMomentAs(selectedDate))) {
      completedDays.removeWhere((date) => date.isAtSameMomentAs(selectedDate));
    } else {
      completedDays.add(selectedDate);
    }
  }
}

class HabitsProvider extends ChangeNotifier {
  HabitsProvider() {
    _loadHabits();
    _loadThemePreference();
  }

  List<Habit> _habits = [];

  List<Habit> get habits => _habits;

  set habits(List<Habit> value) {
    _habits = value;
    notifyListeners();
    _saveHabits();
  }

  void toggleShowCalendar(Habit habit) {
    habit.showCalendar = !habit.showCalendar;
    notifyListeners();
    _saveHabits();
  }

  void toggleHabitCompletion(Habit habit, {DateTime? date}) {
    DateTime selectedDate = date ?? DateTime.now();
    selectedDate = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);

    habit.toggleAccomplishment(date: selectedDate);
    notifyListeners();
    _saveHabits();
  }

  void removeHabit(Habit habit) {
    _habits.remove(habit);
    notifyListeners();
    _saveHabits();
  }

  void addHabit(Habit habit) {
    _habits.add(habit);
    notifyListeners();
    _saveHabits();
  }

  void changeHabit(int index, Habit habit) {
    habits[index] = habit;
    notifyListeners();
    _saveHabits();
  }

  void reorderHabit(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }

    final habitToReorder = _habits.removeAt(oldIndex);
    _habits.insert(newIndex, habitToReorder);

    notifyListeners();
    _saveHabits();
  }

  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  _loadHabits() async {
    try {
      String? habitsJson = await _secureStorage.read(key: 'habits');

      if (habitsJson != null) {
        List<dynamic> habitsList = json.decode(habitsJson);
        habits = habitsList.map((habit) => Habit.fromJson(habit)).toList();
      }
    } catch (e) {
      print('Error loading habits: $e');
    }
  }

  _saveHabits() async {
    try {
      String habitsJson = json.encode(habits);
      await _secureStorage.write(key: 'habits', value: habitsJson);
    } catch (e) {
      print('Error saving habits: $e');
    }
  }

  late bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  set isDarkMode(bool value) {
    _isDarkMode = value;
    notifyListeners();
  }

  Future<void> _loadThemePreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    notifyListeners();
  }

  void toggleDarkMode(bool value) async {
    _isDarkMode = value;
    notifyListeners();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isDarkMode', value);
  }
}

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => HabitsProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Habit Tracker',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: Provider.of<HabitsProvider>(context).isDarkMode
          ? ThemeMode.dark
          : ThemeMode.light,
      home: const MyHomePage(title: 'Habit Tracker Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Random random = Random();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.background,
        leading: IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SettingsPage()),
            );
          },
          icon: Icon(Icons.settings),
        ),
        centerTitle: false,
        title: Text("Habit Tracker"),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HabitFormPage()),
                );
              },
              icon: Icon(Icons.add_circle_outline)),
        ],
      ),
      body: MainPage(),
    );
  }
}
