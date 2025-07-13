import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:goalkeeper/models/goal.dart';
import 'package:goalkeeper/screens/goals/bucket_list_screen.dart';
import 'package:goalkeeper/screens/goals/create_goal_screen.dart';
import 'package:goalkeeper/screens/goals/group_goals_screen.dart';
import 'package:goalkeeper/screens/profile/profile_screen.dart';
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
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF667eea), Color(0xFF764ba2), Color(0xFFf093fb)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Row(
              children: [
                Image.asset('assets/goalkeeper-logo.png', height: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: _isSearching
                      ? TextField(
                          controller: _searchController,
                          autofocus: true,
                          decoration: const InputDecoration(
                            hintText: 'Search goals...',
                            hintStyle: TextStyle(color: Colors.white70),
                            border: InputBorder.none,
                          ),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                          onChanged: (value) {
                            setState(() {
                              _searchQuery = value.toLowerCase();
                            });
                          },
                        )
                      : const Text(
                          'GoalKeeper',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ],
            ),
            actions: _currentIndex == 2
                ? []
                : [
                    _isSearching
                        ? IconButton(
                            icon: const Icon(Icons.close, color: Colors.white),
                            onPressed: _stopSearch,
                          )
                        : IconButton(
                            icon: const Icon(Icons.search, color: Colors.white),
                            onPressed: _startSearch,
                          ),
                  ],
          ),
        ),
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

                final personalGoals = filteredGoals
                    .where((g) => !g.isGroupGoal)
                    .toList();
                final groupGoals = filteredGoals
                    .where((g) => g.isGroupGoal)
                    .toList();

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
          ? Container(
              height: 60,
              width: 60,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: FloatingActionButton(
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
                backgroundColor: Colors.transparent,
                elevation: 0,
                hoverElevation: 0,
                focusElevation: 0,
                highlightElevation: 0,
                splashColor: Colors.transparent,
                child: const Icon(Icons.add, size: 30, color: Colors.white),
              ),
            )
          : null,

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        backgroundColor: Colors.white,
        selectedItemColor: Color(0xFF667eea), 
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
        unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal),
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
