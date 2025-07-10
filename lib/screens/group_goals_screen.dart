import 'package:flutter/material.dart';
import 'package:goalkeeper/models/goal.dart';

class GroupGoalsScreen extends StatelessWidget {
  const GroupGoalsScreen({super.key});

  // Mock user data - replace with your actual user data
  final Map<String, String> users = const {
    'user1': 'Alice',
    'user2': 'Bob',
    'user3': 'Charlie',
    'user4': 'Diana',
  };

  @override
  Widget build(BuildContext context) {
    // Example group goals with participants
    final List<Goal> groupGoals = [
      Goal(
        id: 'g1',
        title: 'Team Project Completion',
        description: 'Finish the Flutter project with the team',
        dueDate: DateTime.now().add(const Duration(days: 14)),
        createdBy: 'user1',
        isGroupGoal: true,
        participants: ['user1', 'user2', 'user3'],
      ),
      Goal(
        id: 'g2',
        title: 'Group Vacation',
        description: 'Plan summer trip with friends',
        dueDate: DateTime.now().add(const Duration(days: 90)),
        createdBy: 'user4',
        isGroupGoal: true,
        participants: ['user1', 'user4'],
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
                const SizedBox(height: 4),
                _buildParticipantsRow(goal),
                Text(
                  'Created by: ${users[goal.createdBy] ?? 'Unknown'}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
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

  Widget _buildParticipantsRow(Goal goal) {
    return SizedBox(
      height: 30,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          const Text('Participants: ', style: TextStyle(fontSize: 12)),
          ...goal.participants.map((userId) {
            return Padding(
              padding: const EdgeInsets.only(right: 4.0),
              child: Chip(
                label: Text(
                  users[userId] ?? 'Unknown',
                  style: const TextStyle(fontSize: 12),
                ),
                visualDensity: VisualDensity.compact,
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
