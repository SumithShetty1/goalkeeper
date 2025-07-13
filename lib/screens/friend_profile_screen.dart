import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:goalkeeper/models/goal.dart';
import 'package:goalkeeper/screens/all_friends_screen.dart';
import 'package:goalkeeper/screens/profile_screen.dart';
import 'package:goalkeeper/widgets/goal_card.dart';

class FriendProfileScreen extends StatefulWidget {
  final String friendEmail;

  const FriendProfileScreen({super.key, required this.friendEmail});

  @override
  State<FriendProfileScreen> createState() => _FriendProfileScreenState();
}

class _FriendProfileScreenState extends State<FriendProfileScreen> {
  late Future<Map<String, dynamic>> _friendDataFuture;
  late Future<List<Goal>> _sharedGoalsFuture;
  final String currentUserEmail =
      FirebaseAuth.instance.currentUser?.email ?? '';

  @override
  void initState() {
    super.initState();
    _friendDataFuture = _fetchFriendData();
    _sharedGoalsFuture = _fetchSharedGoals();
  }

  Future<Map<String, dynamic>> _fetchFriendData() async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.friendEmail)
        .get();

    if (!doc.exists) throw Exception('User not found');

    final data = doc.data()!;
    data['email'] = widget.friendEmail;
    return data;
  }

  Future<List<Map<String, dynamic>>> _fetchFriendsList(
    List<String> friendIds,
  ) async {
    if (friendIds.isEmpty) return [];

    final firestore = FirebaseFirestore.instance;
    final friendDocs = await Future.wait(
      friendIds.map((id) => firestore.collection('users').doc(id).get()),
    );

    return friendDocs.where((doc) => doc.exists).map((doc) {
      final data = doc.data()!;
      data['email'] = doc.id;
      return data;
    }).toList();
  }

  Future<List<Goal>> _fetchSharedGoals() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('goals')
        .where('participants', arrayContains: widget.friendEmail)
        .get();

    final List<Goal> sharedGoals = [];

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final List<String> participants = List<String>.from(data['participants']);

      // Check if current user is also a participant
      if (!participants.contains(currentUserEmail)) continue;

      // Fetch user details for creator and participants
      final createdByEmail = data['createdBy'];
      final creatorDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(createdByEmail)
          .get();

      final createdByName = creatorDoc.data()?['name'] ?? 'Unknown';

      final List<Map<String, String>> participantsDetailed = [];
      for (var email in participants) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(email)
            .get();
        final name = userDoc.data()?['name'] ?? 'Unknown';
        participantsDetailed.add({'email': email, 'name': name});
      }

      data['id'] = doc.id;

      sharedGoals.add(
        Goal(
          id: doc.id,
          title: data['title'],
          description: data['description'],
          isCompleted: data['isCompleted'] ?? false,
          dueDate: data['dueDate']?.toDate(),
          createdAt: data['createdAt']?.toDate() ?? DateTime.now(),
          createdBy: {'email': createdByEmail, 'name': createdByName},
          isGroupGoal: data['isGroupGoal'] ?? false,
          participants: participantsDetailed,
        ),
      );
    }

    return sharedGoals;
  }

  Future<void> _toggleFriend(bool isFriend) async {
    final userDoc = FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserEmail);
    final friendDoc = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.friendEmail);

    if (isFriend) {
      await userDoc.update({
        'friends': FieldValue.arrayRemove([widget.friendEmail]),
      });
      await friendDoc.update({
        'friends': FieldValue.arrayRemove([currentUserEmail]),
      });
    } else {
      await userDoc.update({
        'friends': FieldValue.arrayUnion([widget.friendEmail]),
      });
      await friendDoc.update({
        'friends': FieldValue.arrayUnion([currentUserEmail]),
      });
    }

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
      appBar: AppBar(title: const Text('Friend Profile')),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _friendDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return const Center(child: CircularProgressIndicator());
          if (!snapshot.hasData)
            return const Center(child: Text('Friend not found.'));

          final data = snapshot.data!;
          final name = data['name'] ?? 'Unknown';
          final profileImage = data['profileImage'] ?? '';
          final email = data['email'];
          final friendIds = List<String>.from(data['friends'] ?? []);
          final isFriend = friendIds.contains(currentUserEmail);
          final joinDateStr = data['joinedDate'] ?? '';
          final joinDate = DateTime.tryParse(joinDateStr) ?? DateTime.now();
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
                        ElevatedButton(
                          onPressed: () => _toggleFriend(isFriend),
                          child: Text(
                            isFriend ? 'Remove Friend' : 'Add Friend',
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
                                    return GestureDetector(
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
                                              backgroundImage: NetworkImage(
                                                friend['profileImage'] ?? '',
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(friend['name'] ?? 'Friend'),
                                          ],
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
                Text(
                  'Shared Goals',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
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
                            await FirebaseFirestore.instance
                                .collection('goals')
                                .doc(goal.id)
                                .update({'isCompleted': !goal.isCompleted});
                            setState(() {
                              _sharedGoalsFuture = _fetchSharedGoals();
                            });
                          },
                          onEdit: (updatedGoal) async {
                            // Save updated goal to Firestore directly
                            await FirebaseFirestore.instance
                                .collection('goals')
                                .doc(updatedGoal.id)
                                .update({
                                  'title': updatedGoal.title,
                                  'description': updatedGoal.description,
                                  'dueDate': updatedGoal.dueDate,
                                  'isCompleted': updatedGoal.isCompleted,
                                  'isGroupGoal': updatedGoal.isGroupGoal,
                                  'participants': updatedGoal.participants
                                      .map((p) => p['email'])
                                      .toList(),
                                });

                            setState(() {
                              _sharedGoalsFuture = _fetchSharedGoals();
                            });
                          },
                          onDelete: () async {
                            await FirebaseFirestore.instance
                                .collection('goals')
                                .doc(goal.id)
                                .delete();

                            setState(() {
                              _sharedGoalsFuture = _fetchSharedGoals();
                            });
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
