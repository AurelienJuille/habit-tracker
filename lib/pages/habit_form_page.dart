import 'package:flutter/material.dart';
import 'package:habit_tracker_app/main.dart';
import 'package:habit_tracker_app/themes.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class HabitFormPage extends StatefulWidget {
  final Habit? habit;

  HabitFormPage({super.key, this.habit});

  @override
  HabitFormPageState createState() => HabitFormPageState();
}

class HabitFormPageState extends State<HabitFormPage> {
  final List<IconData> iconList = [
    // General
    Icons.favorite_rounded,
    Icons.grade,
    Icons.done_rounded,
    Icons.block_rounded,
    Icons.timer,

    // Environment
    Icons.wb_sunny_rounded,
    Icons.bedtime_rounded,
    Icons.volunteer_activism_rounded,
    Icons.cottage_rounded,

    // Lifestyle
    Icons.bed_rounded,
    Icons.restaurant,
    Icons.water_drop_rounded,
    Icons.shower_rounded,
    Icons.local_hospital_rounded,
    Icons.self_improvement_rounded,
    Icons.park_rounded,
    Icons.mobile_off_rounded,

    // Sport
    Icons.fitness_center_rounded,
    Icons.directions_run_rounded,

    // Hobbies
    Icons.menu_book_rounded,
    Icons.music_note_rounded,
    Icons.palette_rounded,

    // Business
    Icons.school_rounded,
    Icons.today_rounded,
    Icons.paid_rounded,
    Icons.lightbulb_rounded,
    Icons.rocket_launch_rounded,
    Icons.tag_rounded,
  ];

  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late int _colorIndex;
  late IconData _selectedIcon;

  @override
  void initState() {
    super.initState();

    if (widget.habit != null) {
      _nameController = TextEditingController(text: widget.habit!.name);
      _descriptionController =
          TextEditingController(text: widget.habit!.description);
      _colorIndex = widget.habit!.colorIndex;
      _selectedIcon = widget.habit!.icon;
    } else {
      _nameController = TextEditingController();
      _descriptionController = TextEditingController();
      _colorIndex = 0;
      _selectedIcon = iconList[0];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.background,
        title: Text(widget.habit != null
            ? 'Modifier l\'habitude'
            : 'Créer une nouvelle habitude'),
      ),
      body: pageBody(context),
    );
  }

  SingleChildScrollView pageBody(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Nom'),
              onChanged: (value) {
                setState(() {});
              },
            ),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
            ),
            SizedBox(height: 16.0),
            iconSelector(),
            SizedBox(height: 16.0),
            colorSelector(),
            SizedBox(height: 16.0),
            Visibility(
              visible: widget.habit != null,
              child: dateSelector(),
            ),
            SizedBox(height: 16.0),
            Visibility(
              visible: _nameController.text.trim().isNotEmpty,
              child: ElevatedButton(
                onPressed: () {
                  if (_nameController.text.trim().isNotEmpty) {
                    _saveHabit(context);
                  }
                },
                child: Text("Enregistrer"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Column colorSelector() {
    return Column(
      children: [
        Text('Sélectionner la couleur :'),
        GridView.builder(
          physics: NeverScrollableScrollPhysics(),
          gridDelegate:
              SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 5),
          itemCount: HabitColors.lightColorList.length,
          shrinkWrap: true,
          itemBuilder: (context, index) {
            bool isSelected = _colorIndex == index;
            return GestureDetector(
              onTap: () => setState(() => _colorIndex = index),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: HabitColors.lightColorList[index],
                    borderRadius:
                        BorderRadius.circular(12.0), // Angles arrondis
                    border: Border.all(
                      color: isSelected
                          ? Theme.of(context).colorScheme.onBackground
                          : Colors.transparent,
                      width: 2.0,
                    ),
                  ),
                  child: isSelected
                      ? Icon(
                          Icons.done,
                          color: Theme.of(context).colorScheme.onBackground,
                        )
                      : null,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Column iconSelector() {
    const int nColumns = 5;

    return Column(
      children: [
        Text('Sélectionner l\'icône :'),
        GridView.builder(
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: nColumns),
          itemCount: iconList.length,
          shrinkWrap: true,
          itemBuilder: (context, index) {
            IconData icon = iconList[index];
            bool isSelected = _selectedIcon == icon;
            return GestureDetector(
              onTap: () => setState(() => _selectedIcon = icon),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(12.0), // Angles arrondis
                    border: Border.all(
                      color: isSelected
                          ? Theme.of(context).colorScheme.onBackground
                          : Colors.transparent,
                      width: 2.0,
                    ),
                  ),
                  child: Icon(icon),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Column dateSelector() {
    const int numberOfDates = 14;
    DateTime today = DateTime.now();
    today = DateTime(today.year, today.month, today.day);

    final HabitsProvider habitsProvider =
        Provider.of<HabitsProvider>(context, listen: false);

    Color habitColor = Provider.of<HabitsProvider>(context).isDarkMode
        ? HSVColor.fromColor(HabitColors.lightColorList[_colorIndex])
            .withSaturation(0.8)
            .toColor()
        : HabitColors.lightColorList[_colorIndex];

    if (widget.habit != null) {
      return Column(
        children: [
          Text("Sélectionner les dates accomplies"),
          SizedBox(
            height: 80.0,
            child: ListView(
              scrollDirection: Axis.horizontal,
              reverse: true,
              children: List.generate(
                numberOfDates,
                (index) => AspectRatio(
                  aspectRatio: 1.0,
                  child: Card(
                    elevation: 1.0,
                    color: widget.habit!.completedDays
                            .contains(today.subtract(Duration(days: index)))
                        ? habitColor
                        : habitColor.withOpacity(.2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    clipBehavior: Clip.hardEdge,
                    child: InkWell(
                      onTap: () {
                        habitsProvider.toggleHabitCompletion(widget.habit!,
                            date: today.subtract(Duration(days: index)));
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(DateFormat('EEEE')
                              .format(today.subtract(Duration(days: index)))
                              .substring(0, 3)),
                          Text(today
                              .subtract(Duration(days: index))
                              .day
                              .toString()),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      );
    }
    return Column();
  }

  void _saveHabit(BuildContext context) {
    final HabitsProvider habitsProvider =
        Provider.of<HabitsProvider>(context, listen: false);

    if (widget.habit != null) {
      // Modification d'une habitude existante
      final updatedHabit = widget.habit!.copyWith(
        name: _nameController.text,
        description: _descriptionController.text,
        colorIndex: _colorIndex,
        icon: _selectedIcon,
      );
      final int index = habitsProvider.habits.indexOf(widget.habit!);

      if (index != -1) habitsProvider.changeHabit(index, updatedHabit);
    } else {
      // Création d'une nouvelle habitude
      final newHabit = Habit(
        name: _nameController.text,
        description: _descriptionController.text,
        colorIndex: _colorIndex,
        icon: _selectedIcon,
      );
      habitsProvider.addHabit(newHabit);
    }

    Navigator.pop(context);
  }
}
