import 'package:flutter/material.dart';
import 'package:goalkeeper/models/goal.dart';
import 'package:goalkeeper/screens/create_goal_screen.dart';
import 'package:goalkeeper/widgets/goal_card.dart';

class BucketListScreen extends StatefulWidget {
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
  State<BucketListScreen> createState() => _BucketListScreenState();
}

class _BucketListScreenState extends State<BucketListScreen> {
  void _editGoal(BuildContext context, int index) async {
    final updatedGoal = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateGoalScreen(
          currentUserId: widget.goals[index].createdBy,
          existingGoal: widget.goals[index],
        ),
      ),
    );

    if (updatedGoal != null) {
      widget.onUpdateGoal(index, updatedGoal);
    }
  }

  void _confirmDelete(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Goal'),
          content: const Text('Are you sure you want to delete this goal?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                widget.onDeleteGoal(index);
                Navigator.pop(context);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.goals.length,
      itemBuilder: (context, index) {
        return GoalCard(
          goal: widget.goals[index],
          onToggleComplete: () => widget.onToggleComplete(index),
          onEdit: () => _editGoal(context, index),
          onDelete: () => _confirmDelete(context, index),
        );
      },
    );
  }
}
