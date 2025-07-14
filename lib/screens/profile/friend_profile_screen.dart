import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:goalkeeper/models/goal.dart';
import 'package:goalkeeper/screens/profile/all_friends_screen.dart';
import 'package:goalkeeper/services/firestore_service.dart';
import 'package:goalkeeper/widgets/goal_card.dart';

class FriendProfileScreen extends StatefulWidget {
  final String friendEmail;

  const FriendProfileScreen({super.key, required this.friendEmail});

  @override
  State<FriendProfileScreen> createState() => _FriendProfileScreenState();
}

class _FriendProfileScreenState extends State<FriendProfileScreen> {
  final _firestoreService = FirestoreService();
  final String currentUserEmail =
      FirebaseAuth.instance.currentUser?.email ?? '';

  late Future<Map<String, dynamic>> _friendDataFuture;
  late Future<List<Goal>> _sharedGoalsFuture;

  @override
  void initState() {
    super.initState();
    _friendDataFuture = _fetchFriendData();
    _sharedGoalsFuture = _fetchSharedGoals();
  }

  Future<Map<String, dynamic>> _fetchFriendData() async {
    final user = await _firestoreService.getUserByEmail(widget.friendEmail);
    if (user == null) throw Exception('User not found');
    return {
      'email': user.id,
      'name': user.name,
      'profileImage': user.profileImage,
      'joinedDate': user.joinedDate.toIso8601String(),
      'friends': user.friends,
    };
  }

  Future<List<Map<String, dynamic>>> _fetchFriendsList(
    List<String> friendIds,
  ) async {
    final users = await _firestoreService.getUsersByEmails(friendIds);
    return users
        .map(
          (user) => {
            'email': user.id,
            'name': user.name,
            'profileImage': user.profileImage,
          },
        )
        .toList();
  }

  Future<List<Goal>> _fetchSharedGoals() async {
    final allGoals = await _firestoreService
        .getGoalsForUser(currentUserEmail)
        .first;
    return allGoals.where((goal) {
      final participantEmails = goal.participants
          .map((p) => p['email'])
          .toList();
      return participantEmails.contains(widget.friendEmail);
    }).toList();
  }

  Future<void> _toggleFriend(bool isFriend) async {
    await _firestoreService.toggleFriend(
      currentUserEmail,
      widget.friendEmail,
      isFriend,
    );
    await _firestoreService.toggleFriend(
      widget.friendEmail,
      currentUserEmail,
      isFriend,
    );
    setState(() {
      _friendDataFuture = _fetchFriendData();
      _sharedGoalsFuture = _fetchSharedGoals();
    });
  }

  void _navigateToProfile(String email) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FriendProfileScreen(friendEmail: email),
      ),
    );
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
            title: const Text(
              'Friend Profile',
              style: TextStyle(color: Colors.white),
            ),
            iconTheme: const IconThemeData(color: Colors.white),
          ),
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _friendDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('Friend not found.'));
          }

          final data = snapshot.data!;
          final name = data['name'] ?? 'Unknown';
          final profileImage = data['profileImage'] ?? '';
          final email = data['email'];
          final friendIds = List<String>.from(data['friends'] ?? []);
          final isFriend = friendIds.contains(currentUserEmail);
          final joinDate =
              DateTime.tryParse(data['joinedDate']) ?? DateTime.now();
          final years = DateTime.now().difference(joinDate).inDays ~/ 365;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: NetworkImage(profileImage),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(email, style: const TextStyle(color: Colors.grey)),
                      const SizedBox(height: 8),
                      Text(
                        'Member since ${years > 0 ? '$years year${years > 1 ? 's' : ''}' : 'this year'}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 16),
                      if (email != currentUserEmail)
                        Container(
                          width: 180,
                          height: 48,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF667eea).withOpacity(0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: () => _toggleFriend(isFriend),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              isFriend ? 'Remove Friend' : 'Add Friend',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Friends (${friendIds.length})',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                FutureBuilder<List<Map<String, dynamic>>>(
                  future: _fetchFriendsList(friendIds),
                  builder: (context, friendsSnap) {
                    if (friendsSnap.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final friends = friendsSnap.data ?? [];

                    return friends.isEmpty
                        ? const Center(child: Text('No friends yet'))
                        : Column(
                            children: [
                              SizedBox(
                                height: 100,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: friends.length > 10
                                      ? 10
                                      : friends.length,
                                  itemBuilder: (context, index) {
                                    final friend = friends[index];
                                    return MouseRegion(
                                      cursor: SystemMouseCursors.click,
                                      child: GestureDetector(
                                        onTap: () =>
                                            _navigateToProfile(friend['email']),
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                            right: 12.0,
                                          ),
                                          child: Column(
                                            children: [
                                              CircleAvatar(
                                                radius: 30,
                                                backgroundImage:
                                                    (friend['profileImage'] ??
                                                            '')
                                                        .isNotEmpty
                                                    ? NetworkImage(
                                                        friend['profileImage'],
                                                      )
                                                    : null,
                                                child:
                                                    (friend['profileImage'] ??
                                                            '')
                                                        .isEmpty
                                                    ? Text(
                                                        friend['name']
                                                                ?.substring(
                                                                  0,
                                                                  1,
                                                                )
                                                                .toUpperCase() ??
                                                            '?',
                                                        style: const TextStyle(
                                                          fontSize: 20,
                                                        ),
                                                      )
                                                    : null,
                                              ),
                                              const SizedBox(height: 4),
                                              Text(friend['name'] ?? 'Friend'),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => AllFriendsScreen(
                                          friends: friends,
                                          fromEmail: email,
                                        ),
                                      ),
                                    );
                                  },
                                  child: const Text('View All Friends'),
                                ),
                              ),
                            ],
                          );
                  },
                ),
                const SizedBox(height: 24),
                const Text(
                  'Shared Goals',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                FutureBuilder<List<Goal>>(
                  future: _sharedGoalsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final sharedGoals = snapshot.data ?? [];

                    if (sharedGoals.isEmpty) {
                      return const Text('No shared goals found');
                    }

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: sharedGoals.length,
                      itemBuilder: (context, index) {
                        final goal = sharedGoals[index];
                        return GoalCard(
                          goal: goal,
                          showCheckbox: true,
                          showParticipants: true,
                          onToggleComplete: () async {
                            await _firestoreService.toggleGoalCompletion(
                              goal.id,
                              goal.isCompleted,
                            );
                            setState(
                              () => _sharedGoalsFuture = _fetchSharedGoals(),
                            );
                          },
                          onEdit: (updatedGoal) async {
                            await _firestoreService.updateGoal(updatedGoal);
                            setState(
                              () => _sharedGoalsFuture = _fetchSharedGoals(),
                            );
                          },
                          onDelete: () async {
                            await _firestoreService.deleteGoal(goal.id);
                            setState(
                              () => _sharedGoalsFuture = _fetchSharedGoals(),
                            );
                          },
                          users: {
                            for (var p in goal.participants)
                              if (p['email'] != null && p['name'] != null)
                                p['email']!: p['name']!,
                          },
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
