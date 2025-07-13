import 'package:flutter/material.dart';
import 'package:goalkeeper/models/goal.dart';
import 'package:goalkeeper/screens/goals/create_goal_screen.dart';
import 'package:goalkeeper/screens/goals/goal_detail_screen.dart';

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
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
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
                onEdit(updatedGoal);
              } else if (result['action'] == 'delete') {
                onDelete();
              }
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (showCheckbox)
                      Checkbox(
                        value: goal.isCompleted,
                        onChanged: (_) => onToggleComplete(),
                        activeColor: const Color(0xFF667eea),
                      ),
                    if (leadingIcon != null)
                      Padding(
                        padding: const EdgeInsets.only(right: 10.0),
                        child: Icon(leadingIcon, color: Color(0xFF667eea), size: 24),
                      ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            goal.title,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  color: Colors.black87,
                                ),
                          ),
                          if (goal.description.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 6.0),
                              child: Text(
                                goal.description,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      fontSize: 16,
                                      color: Colors.black54,
                                    ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                        ],
                      ),
                    ),
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert, color: Colors.black54),
                      onSelected: (value) async {
                        if (value == 'edit') {
                          final updatedGoal = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CreateGoalScreen(
                                currentUserId: goal.createdBy['email'] ?? '',
                                currentUserName: goal.createdBy['name'] ?? '',
                                existingGoal: goal,
                              ),
                            ),
                          );

                          if (updatedGoal != null && updatedGoal is Goal) {
                            onEdit(updatedGoal);
                          }
                        }
                        if (value == 'delete') onDelete();
                      },
                      itemBuilder: (context) => const [
                        PopupMenuItem(value: 'edit', child: Text('Edit Goal')),
                        PopupMenuItem(value: 'delete', child: Text('Delete Goal')),
                      ],
                    ),
                  ],
                ),
                if (goal.dueDate != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 18, color: Colors.grey),
                        const SizedBox(width: 6),
                        Text(
                          'Due: ${goal.dueDate!.toString().split(' ')[0]}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontSize: 14,
                              ),
                        ),
                      ],
                    ),
                  ),
                if (showParticipants && users != null)
                  _buildParticipantsRow(goal, users!),
                if (goal.isGroupGoal)
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Text(
                      'Created by: ${goal.createdBy['name'] ?? 'Unknown'}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontStyle: FontStyle.italic,
                            color: Colors.black54,
                            fontSize: 14,
                          ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildParticipantsRow(Goal goal, Map<String, String> users) {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Participants:', style: TextStyle(fontSize: 13)),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: goal.participants.map((participant) {
              final email = participant['email'] ?? '';
              final name = participant['name'] ?? 'Unknown';
              final isCreator = goal.createdBy['email'] == email;

              return Chip(
                label: Text(name, style: const TextStyle(fontSize: 13)),
                visualDensity: VisualDensity.compact,
                backgroundColor: isCreator ? Colors.blue[100] : Colors.grey[200],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
