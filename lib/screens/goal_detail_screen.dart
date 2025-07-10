import 'package:flutter/material.dart';
import 'package:goalkeeper/models/goal.dart';

class GoalDetailScreen extends StatelessWidget {
  final Goal goal;

  const GoalDetailScreen({super.key, required this.goal});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Goal Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              goal.title,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Text(
              goal.description,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            if (goal.dueDate != null)
              Text(
                'Due: ${goal.dueDate!.toString().split(' ')[0]}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            const SizedBox(height: 16),
            Text(
              'Status: ${goal.isCompleted ? 'Completed' : 'In Progress'}',
              style: TextStyle(
                color: goal.isCompleted ? Colors.green : Colors.orange,
                fontSize: 16,
              ),
            ),
            if (goal.isGroupGoal) ...[
              const SizedBox(height: 16),
              const Text(
                'Participants:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              // Add participant list here if needed
            ],
          ],
        ),
      ),
    );
  }
}
