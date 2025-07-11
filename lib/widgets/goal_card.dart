import 'package:flutter/material.dart';
import 'package:goalkeeper/models/goal.dart';
import 'package:goalkeeper/screens/create_goal_screen.dart';
import 'package:goalkeeper/screens/goal_detail_screen.dart';

class GoalCard extends StatelessWidget {
  final Goal goal;
  final Map<String, String>? users;
  final VoidCallback onToggleComplete;
  final void Function(Goal updatedGoal) onEdit;
  final VoidCallback onDelete;
  final bool showCheckbox;
  final bool showParticipants;
  final IconData? leadingIcon;

  const GoalCard({
    super.key,
    required this.goal,
    this.users,
    required this.onToggleComplete,
    required this.onEdit,
    required this.onDelete,
    this.showCheckbox = true,
    this.showParticipants = false,
    this.leadingIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: InkWell(
        onTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => GoalDetailScreen(
                goal: goal,
                onUpdate: (updatedGoal) {
                  Navigator.pop(context, {
                    'action': 'update',
                    'goal': updatedGoal,
                  });
                },
                onDelete: () {
                  Navigator.pop(context, {'action': 'delete'});
                },
                onToggleComplete: () {
                  onToggleComplete();
                  Navigator.pop(context);
                },
              ),
            ),
          );

          if (result != null && result is Map) {
            if (result['action'] == 'update' && result['goal'] != null) {
              final updatedGoal = result['goal'] as Goal;
              onEdit(
                updatedGoal,
              ); // ✅ Properly call onEdit with the updated goal
            } else if (result['action'] == 'delete') {
              onDelete();
            }
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (showCheckbox)
                    Checkbox(
                      value: goal.isCompleted,
                      onChanged: (_) => onToggleComplete(),
                    ),
                  if (leadingIcon != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Icon(leadingIcon, color: Colors.blue),
                    ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          goal.title,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        if (goal.description.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(
                              goal.description,
                              style: Theme.of(context).textTheme.bodyMedium,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert),
                    onSelected: (value) async {
                      if (value == 'edit') {
                        final updatedGoal = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CreateGoalScreen(
                              currentUserId: goal.createdBy,
                              existingGoal: goal,
                            ),
                          ),
                        );

                        if (updatedGoal != null && updatedGoal is Goal) {
                          onEdit(
                            updatedGoal,
                          ); // ✅ Now update parent with edited goal
                        }
                      }
                      if (value == 'delete') onDelete();
                    },

                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Text('Edit Goal'),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text('Delete Goal'),
                      ),
                    ],
                  ),
                ],
              ),
              if (goal.dueDate != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        'Due: ${goal.dueDate!.toString().split(' ')[0]}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              if (showParticipants && users != null)
                _buildParticipantsRow(goal, users!),
              if (goal.isGroupGoal)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    'Created by: ${users?[goal.createdBy] ?? 'Unknown'}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildParticipantsRow(Goal goal, Map<String, String> users) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Participants:', style: TextStyle(fontSize: 12)),
          const SizedBox(height: 4),
          Wrap(
            spacing: 4,
            runSpacing: 4,
            children: goal.participants.map((userId) {
              return Chip(
                label: Text(users[userId] ?? 'Unknown'),
                visualDensity: VisualDensity.compact,
                backgroundColor: userId == goal.createdBy
                    ? Colors.blue[100]
                    : Colors.grey[200],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
