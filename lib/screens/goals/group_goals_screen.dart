import 'package:flutter/material.dart';
import 'package:goalkeeper/models/goal.dart';
import 'package:goalkeeper/widgets/goal_card.dart';

class GroupGoalsScreen extends StatelessWidget {
  final List<Goal> goals;
  final Map<String, String> users;
  final Function(int, Goal) onUpdateGoal;
  final Function(int) onDeleteGoal;
  final Function(int) onToggleComplete;

  const GroupGoalsScreen({
    super.key,
    required this.goals,
    required this.users,
    required this.onUpdateGoal,
    required this.onDeleteGoal,
    required this.onToggleComplete,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: goals.length,
      itemBuilder: (context, index) {
        final goal = goals[index];
        return GoalCard(
          goal: goal,
          users: users,
          onToggleComplete: () => onToggleComplete(index),
          onEdit: (updatedGoal) => onUpdateGoal(index, updatedGoal),
          onDelete: () => onDeleteGoal(index),
          showCheckbox: true,
          showParticipants: true,
          leadingIcon: Icons.people,
        );
      },
    );
  }
}
