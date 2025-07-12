import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:goalkeeper/models/goal.dart';
import 'package:goalkeeper/screens/bucket_list_screen.dart';
import 'package:goalkeeper/screens/create_goal_screen.dart';
import 'package:goalkeeper/screens/group_goals_screen.dart';
import 'package:goalkeeper/screens/profile_screen.dart';
import 'package:goalkeeper/services/firestore_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSearching = false;

  String get currentUserEmail => _auth.currentUser?.email ?? '';
  String get currentUserName => _auth.currentUser?.displayName ?? 'You';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
      _searchQuery = '';
      _searchController.clear();
      _isSearching = false;
    });
  }

  void _startSearch() {
    setState(() {
      _isSearching = true;
    });
  }

  void _stopSearch() {
    setState(() {
      _searchQuery = '';
      _searchController.clear();
      _isSearching = false;
    });
  }

  Future<void> _addNewGoal(Goal goal) async {
    await _firestoreService.addGoal(goal);
  }

  Future<void> _updateGoal(Goal goal) async {
    await _firestoreService.updateGoal(goal);
  }

  Future<void> _deleteGoal(String goalId) async {
    await _firestoreService.deleteGoal(goalId);
  }

  Future<void> _toggleGoalComplete(Goal goal) async {
    await _firestoreService.toggleGoalCompletion(goal.id, goal.isCompleted);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search goals...',
                  border: InputBorder.none,
                ),
                style: const TextStyle(color: Colors.black, fontSize: 18),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.toLowerCase();
                  });
                },
              )
            : const Text('GoalKeeper'),
        actions: _currentIndex == 2
            ? []
            : [
                _isSearching
                    ? IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: _stopSearch,
                      )
                    : IconButton(
                        icon: const Icon(Icons.search),
                        onPressed: _startSearch,
                      )
              ],
      ),
      body: _currentIndex == 2
          ? const ProfileScreen()
          : StreamBuilder<List<Goal>>(
              stream: _firestoreService.getGoalsForUser(currentUserEmail),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No goals yet'));
                }

                final allGoals = snapshot.data!;

                final filteredGoals = allGoals.where((goal) {
                  final query = _searchQuery.trim();
                  if (query.isEmpty) return true;
                  final title = goal.title.toLowerCase();
                  final description = goal.description.toLowerCase();
                  return title.contains(query) || description.contains(query);
                }).toList();

                final personalGoals =
                    filteredGoals.where((g) => !g.isGroupGoal).toList();
                final groupGoals =
                    filteredGoals.where((g) => g.isGroupGoal).toList();

                final users = {
                  for (final g in groupGoals)
                    for (final p in g.participants) p['email']!: p['name']!,
                  for (final g in groupGoals)
                    g.createdBy['email']!: g.createdBy['name']!,
                  currentUserEmail: currentUserName,
                };

                return _currentIndex == 0
                    ? BucketListScreen(
                        goals: personalGoals,
                        onUpdateGoal: (index, updatedGoal) =>
                            _updateGoal(updatedGoal),
                        onDeleteGoal: (index) =>
                            _deleteGoal(personalGoals[index].id),
                        onToggleComplete: (index) =>
                            _toggleGoalComplete(personalGoals[index]),
                      )
                    : GroupGoalsScreen(
                        goals: groupGoals,
                        users: users,
                        onUpdateGoal: (index, updatedGoal) =>
                            _updateGoal(updatedGoal),
                        onDeleteGoal: (index) =>
                            _deleteGoal(groupGoals[index].id),
                        onToggleComplete: (index) =>
                            _toggleGoalComplete(groupGoals[index]),
                      );
              },
            ),
      floatingActionButton: (_currentIndex == 0 || _currentIndex == 1)
          ? FloatingActionButton(
              onPressed: () async {
                final newGoal = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CreateGoalScreen(
                      currentUserId: currentUserEmail,
                      currentUserName: currentUserName,
                      isGroupGoal: _currentIndex == 1,
                    ),
                  ),
                );

                if (newGoal != null && newGoal is Goal) {
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
