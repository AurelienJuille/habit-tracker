import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:habit_tracker_app/main.dart';
import 'package:habit_tracker_app/pages/habit_form_page.dart';
import 'package:provider/provider.dart';

class HabitCard extends StatelessWidget {
  final Habit habit;
  final double unactiveOpacityFactor = .2;

  void _deleteHabit(BuildContext context) {
    final HabitsProvider habitsProvider =
        Provider.of<HabitsProvider>(context, listen: false);
    habitsProvider.removeHabit(habit);
  }

  HabitCard(this.habit);

  @override
  Widget build(BuildContext context) {
    final habitsProvider = Provider.of<HabitsProvider>(context);
    return Dismissible(
      key: Key(habit.name),
      direction: DismissDirection.horizontal,
      background: ColoredBox(
        color: Theme.of(context).colorScheme.secondary,
        child: Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Icon(Icons.edit_rounded, color: Colors.white),
          ),
        ),
      ),
      secondaryBackground: const ColoredBox(
        color: Colors.red,
        child: Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Icon(Icons.delete, color: Colors.white),
          ),
        ),
      ),
      confirmDismiss: (DismissDirection direction) async {
        if (direction == DismissDirection.endToStart) {
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: RichText(
                  text: TextSpan(
                    style: DefaultTextStyle.of(context).style,
                    children: [
                      TextSpan(
                        text: 'Voulez-vous vraiment supprimer l\'habitude ',
                      ),
                      TextSpan(
                        text: habit.name,
                        style: TextStyle(color: habit.getColor(context)),
                      ),
                      TextSpan(
                        text: ' ?',
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('No'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Yes'),
                  )
                ],
              );
            },
          );
          return confirmed;
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HabitFormPage(
                habit: habit,
              ),
            ),
          );
          return false;
        }
      },
      onDismissed: (direction) {
        _deleteHabit(context);
      },
      child: Card(
        elevation: 1.0,
        color: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        clipBehavior: Clip.hardEdge,
        child: InkWell(
          onTap: () {
            habitsProvider.toggleHabitCompletion(habit);
          },
          child: Container(
            padding: EdgeInsets.all(10.0),
            child: Column(
              children: [
                HabitCardTopBar(
                  habit: habit,
                  unactiveOpacityFactor: unactiveOpacityFactor,
                ),
                HabitCalendarDrawer(
                  habit: habit,
                  unactiveOpacityFactor: unactiveOpacityFactor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class HabitCardTopBar extends StatelessWidget {
  const HabitCardTopBar({
    super.key,
    required this.habit,
    required this.unactiveOpacityFactor,
  });

  final Habit habit;
  final double unactiveOpacityFactor;

  @override
  Widget build(BuildContext context) {
    final habitsProvider = Provider.of<HabitsProvider>(context, listen: false);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          flex: 1,
          child: OverflowBar(
            clipBehavior: Clip.hardEdge,
            children: [
              Row(
                children: [
                  AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    padding: EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                      color: habit.isCompletedToday
                          ? habit.getColor(context)
                          : habit
                              .getColor(context)
                              .withOpacity(unactiveOpacityFactor),
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                    ),
                    child: Icon(habit.icon),
                  ),
                  SizedBox(width: 8),
                  Flexible(
                    flex: 1,
                    child: Text(
                      habit.name,
                      overflow: TextOverflow.clip,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Row(
          children: [
            IconButton(
              onPressed: () {
                habitsProvider.toggleShowCalendar(habit);
              },
              icon: habit.showCalendar ? Icon(Icons.arrow_drop_up_rounded) : Icon(Icons.arrow_drop_down_rounded),
            ),
          ],
        ),
      ],
    );
  }
}

class HabitCalendarDrawer extends StatelessWidget {
  final Habit habit;
  final double unactiveOpacityFactor;

  HabitCalendarDrawer(
      {required this.habit, required this.unactiveOpacityFactor});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 200),
      height: habit.showCalendar ? 80 : 0,
      child: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 10.0,
            ),
            HabitCalendar(
              habit: habit,
              unactiveOpacityFactor: unactiveOpacityFactor,
            ),
          ],
        ),
      ),
    );
  }
}

class HabitCalendar extends StatefulWidget {
  final Habit habit;
  final double unactiveOpacityFactor;

  HabitCalendar({required this.habit, required this.unactiveOpacityFactor});

  @override
  State<HabitCalendar> createState() => _HabitCalendarState();
}

class _HabitCalendarState extends State<HabitCalendar> {
  late ScrollController scrollController;

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollController.jumpTo(scrollController.position.maxScrollExtent);
    });
  }

  @override
  Widget build(BuildContext context) {
    const totalHeight = 70.0;
    const squareToSpaceRatio = 0.8;
    const squareSize = squareToSpaceRatio * totalHeight / 7;
    const spaceSize = (1 - squareToSpaceRatio) * totalHeight / 6;
    const itemCount = 7 * 52;

    DateTime today = DateTime.now();
    today = DateTime(today.year, today.month, today.day);
    int currentDayOfWeek = today.weekday;
    int difference = currentDayOfWeek - DateTime.sunday;
    DateTime startSunday = today.subtract(Duration(days: difference));

    return SizedBox(
      width: double.infinity,
      height: totalHeight,
      child: GridView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: itemCount,
        controller: scrollController,
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: squareSize,
            childAspectRatio: 1,
            crossAxisSpacing: spaceSize,
            mainAxisSpacing: spaceSize),
        itemBuilder: (context, index) {
          DateTime currentDate =
              startSunday.subtract(Duration(days: itemCount - 1 - index));

          return GridTile(
            child: AnimatedContainer(
              duration: Duration(milliseconds: 300),
              curve: Curves.easeOut,
              decoration: BoxDecoration(
                color: widget.habit.completedDays
                        .any((date) => date.isAtSameMomentAs(currentDate))
                    ? widget.habit.getColor(context)
                    : widget.habit
                        .getColor(context)
                        .withOpacity(widget.unactiveOpacityFactor),
                borderRadius: BorderRadius.all(Radius.circular(squareSize / 3)),
              ),
            ),
          );
        },
      ),
    );
  }
}
