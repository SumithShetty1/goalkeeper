import 'package:flutter/material.dart';
import 'package:goalkeeper/models/goal.dart';
import 'package:goalkeeper/screens/create_goal_screen.dart';

class GoalDetailScreen extends StatelessWidget {
  final Goal goal;
  final Function(Goal)? onUpdate;
  final Function()? onDelete;
  final Function()? onToggleComplete;

  final Map<String, String> users = const {
    'user1': 'Alice Johnson',
    'user2': 'Bob Smith',
    'user3': 'Charlie Brown',
    'user4': 'Diana Prince',
    'currentUserId': 'You',
  };

  const GoalDetailScreen({
    super.key,
    required this.goal,
    this.onUpdate,
    this.onDelete,
    this.onToggleComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Goal Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final updatedGoal = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CreateGoalScreen(
                    currentUserId: goal.createdBy,
                    existingGoal: goal,
                  ),
                ),
              );
              if (updatedGoal != null) {
                Navigator.pop(context, {
                  'action': 'update',
                  'goal': updatedGoal,
                });
              }
            },
          ),

          if (onDelete != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _confirmDelete(context),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                goal.isGroupGoal
                    ? const Icon(Icons.people, size: 40, color: Colors.blue)
                    : const Icon(Icons.flag, size: 40, color: Colors.green),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        goal.title,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        goal.isGroupGoal ? 'Group Goal' : 'Personal Goal',
                        style: TextStyle(
                          color: goal.isGroupGoal ? Colors.blue : Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Description
            Text(
              'Description',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(goal.description),
            const SizedBox(height: 24),

            // Details
            Wrap(
              spacing: 24,
              runSpacing: 16,
              children: [
                _buildDetailItem(
                  icon: Icons.calendar_today,
                  label: 'Due Date',
                  value: goal.dueDate != null
                      ? '${goal.dueDate!.toString().split(' ')[0]}'
                      : 'No due date',
                ),
                _buildDetailItem(
                  icon: Icons.person,
                  label: 'Created By',
                  value: users[goal.createdBy] ?? 'Unknown',
                ),
                _buildDetailItem(
                  icon: Icons.check_circle,
                  label: 'Status',
                  value: goal.isCompleted ? 'Completed' : 'In Progress',
                  valueColor: goal.isCompleted ? Colors.green : Colors.orange,
                ),
                if (goal.isGroupGoal)
                  _buildDetailItem(
                    icon: Icons.people,
                    label: 'Participants',
                    value: '${goal.participants.length} members',
                  ),
              ],
            ),
            const SizedBox(height: 24),

            // Participants
            if (goal.isGroupGoal) ...[
              const Text(
                'Participants',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: goal.participants.map((userId) {
                  return Chip(
                    avatar: CircleAvatar(
                      child: Text(users[userId]?.substring(0, 1) ?? '?'),
                    ),
                    label: Text(users[userId] ?? 'Unknown'),
                    backgroundColor: userId == goal.createdBy
                        ? Colors.blue[100]
                        : Colors.grey[200],
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
            ],

            // Completion Button
            if (!goal.isCompleted && onToggleComplete != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: ElevatedButton.icon(
                  onPressed: onToggleComplete,
                  icon: const Icon(Icons.check),
                  label: const Text('Mark as Complete'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Goal'),
        content: const Text('Are you sure you want to delete this goal?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // Just close dialog
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // close dialog
              Navigator.pop(context, {
                'action': 'delete',
              }); // THEN pop detail screen with result
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return SizedBox(
      width: 150,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: Colors.grey),
              const SizedBox(width: 8),
              Text(label, style: const TextStyle(color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              color: valueColor ?? Colors.black,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
