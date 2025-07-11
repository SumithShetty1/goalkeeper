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

  final List<Goal> _personalGoals = [];
  final List<Goal> _groupGoals = [
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

  final Map<String, String> users = const {
    'user1': 'Alice',
    'user2': 'Bob',
    'user3': 'Charlie',
    'user4': 'Diana',
    'currentUserId': 'You',
  };

  List<Widget> get _pages => [
    BucketListScreen(
      goals: _personalGoals,
      onUpdateGoal: _updatePersonalGoal,
      onDeleteGoal: _deletePersonalGoal,
      onToggleComplete: _togglePersonalGoal,
    ),
    GroupGoalsScreen(
      goals: _groupGoals,
      users: users,
      onUpdateGoal: _updateGroupGoal,
      onDeleteGoal: _deleteGroupGoal,
      onToggleComplete: _toggleGroupGoal,
    ),
    const ProfileScreen(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  // Personal Goal Handlers
  void _addNewPersonalGoal(Goal newGoal) {
    setState(() {
      _personalGoals.add(newGoal);
    });
  }

  void _updatePersonalGoal(int index, Goal updatedGoal) {
    setState(() {
      _personalGoals[index] = updatedGoal;
    });
  }

  void _deletePersonalGoal(int index) {
    setState(() {
      _personalGoals.removeAt(index);
    });
  }

  void _togglePersonalGoal(int index) {
    setState(() {
      _personalGoals[index] = _personalGoals[index].copyWith(
        isCompleted: !_personalGoals[index].isCompleted,
      );
    });
  }

  // Group Goal Handlers
  void _updateGroupGoal(int index, Goal updatedGoal) {
    setState(() {
      _groupGoals[index] = updatedGoal;
    });
  }

  void _deleteGroupGoal(int index) {
    setState(() {
      _groupGoals.removeAt(index);
    });
  }

  void _toggleGroupGoal(int index) {
    setState(() {
      _groupGoals[index] = _groupGoals[index].copyWith(
        isCompleted: !_groupGoals[index].isCompleted,
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
              // TODO: Implement search
            },
          ),
        ],
      ),
      body: _pages[_currentIndex],
      floatingActionButton: (_currentIndex == 0 || _currentIndex == 1)
          ? FloatingActionButton(
              onPressed: () async {
                final newGoal = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CreateGoalScreen(
                      currentUserId: 'currentUserId',
                      isGroupGoal: _currentIndex == 1, // true for group tab
                    ),
                  ),
                );

                if (newGoal != null && newGoal is Goal) {
                  if (_currentIndex == 0) {
                    _addNewPersonalGoal(newGoal);
                  } else if (_currentIndex == 1) {
                    setState(() {
                      _groupGoals.add(newGoal);
                    });
                  }
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
