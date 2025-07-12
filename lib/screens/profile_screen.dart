import 'package:flutter/material.dart';
import 'package:goalkeeper/screens/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Center(child: Text("User not logged in"));

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(user.email).get(),
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
          return const Center(child: Text('User data not found.'));
        }

        final userData = userSnapshot.data!.data() as Map<String, dynamic>;

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('goals')
              .where('participants', arrayContains: user.email)
              .snapshots(),
          builder: (context, goalsSnapshot) {
            if (goalsSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final goals = goalsSnapshot.data?.docs ?? [];
            final totalGoals = goals.length;
            final completedGoals = goals.where(
              (doc) => (doc.data() as Map<String, dynamic>)['isCompleted'] == true,
            ).length;

            return ListView(
              children: [
                UserProfileHeader(
                  userData: userData,
                  totalGoals: totalGoals,
                  completedGoals: completedGoals,
                ),
                FriendsSection(
                  friendIds: List<String>.from(userData['friends'] ?? []),
                ),
                const SettingsSection(),
              ],
            );
          },
        );
      },
    );
  }
}

class UserProfileHeader extends StatelessWidget {
  final Map<String, dynamic> userData;
  final int totalGoals;
  final int completedGoals;

  const UserProfileHeader({
    super.key,
    required this.userData,
    required this.totalGoals,
    required this.completedGoals,
  });

  @override
  Widget build(BuildContext context) {
    final joinDate = DateTime.tryParse(userData['joinedDate'] ?? '') ?? DateTime.now();
    final years = DateTime.now().difference(joinDate).inDays ~/ 365;

    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundImage: NetworkImage(userData['profileImage'] ?? ''),
          ),
          const SizedBox(height: 16),
          Text(
            userData['name'] ?? 'Unknown',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Member since ${years > 0 ? '$years year${years > 1 ? 's' : ''}' : 'this year'}',
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatItem('Goals', totalGoals.toString()),
              _buildStatItem('Completed', completedGoals.toString()),
              _buildStatItem('Friends', (userData['friends']?.length ?? 0).toString()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(label, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }
}

class FriendsSection extends StatelessWidget {
  final List<String> friendIds;

  const FriendsSection({super.key, required this.friendIds});

  Future<List<Map<String, dynamic>>> _fetchFriendData() async {
    if (friendIds.isEmpty) return [];

    final firestore = FirebaseFirestore.instance;
    final friendDocs = await Future.wait(friendIds.map(
      (id) => firestore.collection('users').doc(id).get(),
    ));

    return friendDocs
        .where((doc) => doc.exists)
        .map((doc) => doc.data()! as Map<String, dynamic>)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Friends',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          FutureBuilder<List<Map<String, dynamic>>>(
            future: _fetchFriendData(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final friends = snapshot.data ?? [];
              return SizedBox(
                height: 100,
                child: friends.isEmpty
                    ? const Center(child: Text("No friends yet"))
                    : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: friends.length,
                        itemBuilder: (context, index) {
                          final friend = friends[index];
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Column(
                              children: [
                                CircleAvatar(
                                  radius: 30,
                                  backgroundImage: NetworkImage(friend['profileImage'] ?? ''),
                                ),
                                const SizedBox(height: 4),
                                Text(friend['name'] ?? 'Friend'),
                              ],
                            ),
                          );
                        },
                      ),
              );
            },
          ),
          TextButton(
            onPressed: () {
              // Navigate to full friends list
            },
            child: const Text('View All Friends'),
          ),
        ],
      ),
    );
  }
}

class SettingsSection extends StatelessWidget {
  const SettingsSection({super.key});

  void _signOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      if (!context.mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to sign out')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Settings',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Account Settings'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Notifications'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.help),
            title: const Text('Help & Support'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Log Out'),
            onTap: () => _signOut(context),
          ),
        ],
      ),
    );
  }
}
