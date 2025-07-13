import 'package:flutter/material.dart';
import 'package:goalkeeper/models/goal.dart';
import 'package:goalkeeper/widgets/goal_card.dart';

class BucketListScreen extends StatelessWidget {
  final List<Goal> goals;
  final Function(int, Goal) onUpdateGoal;
  final Function(int) onDeleteGoal;
  final Function(int) onToggleComplete;

  const BucketListScreen({
    super.key,
    required this.goals,
    required this.onUpdateGoal,
    required this.onDeleteGoal,
    required this.onToggleComplete,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: goals.length,
      itemBuilder: (context, index) {
        return GoalCard(
          goal: goals[index],
          onToggleComplete: () => onToggleComplete(index),
          onEdit: (updatedGoal) =>
              onUpdateGoal(index, updatedGoal),
          onDelete: () => onDeleteGoal(index),
          showCheckbox: true,
          showParticipants: false,
          leadingIcon: Icons.flag,
        );
      },
    );
  }
}
