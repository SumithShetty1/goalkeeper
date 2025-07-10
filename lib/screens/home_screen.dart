import 'package:flutter/material.dart';
import 'package:goalkeeper/models/goal.dart';
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
  final List<Widget> _pages = [
    const BucketListScreen(),
    const GroupGoalsScreen(),
    const ProfileScreen(),
  ];

  final List<Goal> _goals = [
    Goal(
      id: '1',
      title: 'Learn Flutter',
      description: 'Build a complete app',
      dueDate: DateTime.now().add(const Duration(days: 30)),
    ),
    Goal(
      id: '2',
      title: 'Visit Japan',
      description: 'See cherry blossoms in Kyoto',
      dueDate: DateTime.now().add(const Duration(days: 180)),
    ),
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
                    builder: (context) => const CreateGoalScreen(),
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
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'My Goals',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_alt),
            label: 'Group Goals',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class BucketListScreen extends StatelessWidget {
  const BucketListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final homeState = context.findAncestorStateOfType<_HomeScreenState>();
    
    return ListView.builder(
      itemCount: homeState?._goals.length ?? 0,
      itemBuilder: (context, index) {
        final goal = homeState!._goals[index];
        return GoalCard(
          goal: goal,
          onToggleComplete: () => homeState._toggleGoalCompletion(index),
        );
      },
    );
  }
}

class GoalCard extends StatelessWidget {
  final Goal goal;
  final VoidCallback onToggleComplete;

  const GoalCard({
    super.key,
    required this.goal,
    required this.onToggleComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: ListTile(
        leading: Checkbox(
          value: goal.isCompleted,
          onChanged: (_) => onToggleComplete(),
        ),
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
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.share),
          onPressed: () {
            // Implement share functionality
          },
        ),
        onTap: () {
          // Navigate to goal detail screen
        },
      ),
    );
  }
}
