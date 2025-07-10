import 'package:flutter/material.dart';
import 'package:goalkeeper/models/goal.dart';

class GroupGoalsScreen extends StatelessWidget {
  const GroupGoalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Example group goals - you'll replace with real data
    final List<Goal> groupGoals = [
      Goal(
        id: 'g1',
        title: 'Team Project Completion',
        description: 'Finish the Flutter project with the team',
        dueDate: DateTime.now().add(const Duration(days: 14)),
      ),
      Goal(
        id: 'g2',
        title: 'Group Vacation',
        description: 'Plan summer trip with friends',
        dueDate: DateTime.now().add(const Duration(days: 90)),
      ),
    ];

    return ListView.builder(
      itemCount: groupGoals.length,
      itemBuilder: (context, index) {
        final goal = groupGoals[index];
        return Card(
          margin: const EdgeInsets.all(8.0),
          child: ListTile(
            leading: const Icon(Icons.people, color: Colors.blue),
            title: Text(goal.title),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(goal.description),
                if (goal.dueDate != null)
                  Text(
                    'Due: ${goal.dueDate!.toString().split(' ')[0]}',
                    style: const TextStyle(color: Colors.grey),
                  ),
              ],
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Navigate to group goal detail screen
            },
          ),
        );
      },
    );
  }
}
