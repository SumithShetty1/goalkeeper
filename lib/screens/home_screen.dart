import 'package:flutter/material.dart';
import 'package:goalkeeper/models/goal.dart';
import 'package:goalkeeper/screens/bucket_list_screen.dart';
import 'package:goalkeeper/screens/create_goal_screen.dart';
import 'package:goalkeeper/screens/group_goals_screen.dart';
import 'package:goalkeeper/screens/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final List<Goal> _goals = [
    Goal(
      id: '1',
      title: 'Learn Flutter',
      description: 'Build a complete app',
      dueDate: DateTime.now().add(const Duration(days: 30)),
      createdBy: 'currentUserId',
      isGroupGoal: false,
    ),
    Goal(
      id: '2',
      title: 'Visit Japan',
      description: 'See cherry blossoms in Kyoto',
      dueDate: DateTime.now().add(const Duration(days: 180)),
      createdBy: 'currentUserId',
      isGroupGoal: false,
    ),
  ];

  List<Widget> get _pages => [
        BucketListScreen(
          goals: _goals,
          onUpdateGoal: _updateGoal,
          onDeleteGoal: _deleteGoal,
          onToggleComplete: _toggleGoalCompletion,
        ),
        const GroupGoalsScreen(),
        const ProfileScreen(),
      ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _addNewGoal(Goal newGoal) {
    setState(() {
      _goals.add(newGoal);
    });
  }

  void _updateGoal(int index, Goal updatedGoal) {
    setState(() {
      _goals[index] = updatedGoal;
    });
  }

  void _deleteGoal(int index) {
    setState(() {
      _goals.removeAt(index);
    });
  }

  void _toggleGoalCompletion(int index) {
    setState(() {
      _goals[index] = _goals[index].copyWith(
        isCompleted: !_goals[index].isCompleted,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GoalKeeper'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Implement search functionality
            },
          ),
        ],
      ),
      body: _pages[_currentIndex],
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
              onPressed: () async {
                final newGoal = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CreateGoalScreen(
                      currentUserId: 'currentUserId', // Replace with actual user ID
                    ),
                  ),
                );
                if (newGoal != null) {
                  _addNewGoal(newGoal);
                }
              },
              child: const Icon(Icons.add),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'My Goals'),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_alt),
            label: 'Group Goals',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
