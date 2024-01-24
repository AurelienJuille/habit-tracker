import 'package:flutter/material.dart';
import 'package:habit_tracker_app/components/habit_card.dart';
import 'package:habit_tracker_app/main.dart';
import 'package:habit_tracker_app/pages/habit_form_page.dart';
import 'package:provider/provider.dart';

// TODO : Système de routines : un groupe d'habit. Une card qui montre le calendrier cumulé des habits dans la routine, et quand on clique sur la carte ça nous emmène vers une page où on peut valider les habits de la routine

class MainPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final habitsProvider = Provider.of<HabitsProvider>(context);

    return habitsProvider.habits.isEmpty
        ? NoHabitYet()
        : ReorderableListView(
            padding: EdgeInsets.all(5.0),
            children: habitsProvider.habits.map((habit) {
              return ReorderableWidget(
                key: Key(habit.name),
                child: HabitCard(habit),
              );
            }).toList(),
            onReorder: (oldIndex, newIndex) {
              habitsProvider.reorderHabit(oldIndex, newIndex);
            },
          );
  }
}

class ReorderableWidget extends StatelessWidget {
  @override
  // ignore: overridden_fields
  final Key key;
  final Widget child;

  ReorderableWidget({required this.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      key: key,
      padding: EdgeInsets.only(bottom: 5.0),
      child: Material(
        color: Colors.transparent,
        child: child,
      ),
    );
  }
}

class NoHabitYet extends StatelessWidget {
  const NoHabitYet({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Vous n'avez pas encore d'habitude"),
          SizedBox(height: 20,),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HabitFormPage()),
              );
            },
            child: Text('Ajouter une habitude'),
          ),
        ],
      ),
    );
  }
}
