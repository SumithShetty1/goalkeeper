import 'package:flutter/material.dart';
import 'package:goalkeeper/screens/profile/account_settings_screen.dart';
import 'package:goalkeeper/screens/profile/all_friends_screen.dart';
import 'package:goalkeeper/screens/auth/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:goalkeeper/screens/profile/friend_profile_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Center(child: Text("User not logged in"));

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user.email)
          .snapshots(),
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
            final completedGoals = goals
                .where(
                  (doc) =>
                      (doc.data() as Map<String, dynamic>)['isCompleted'] ==
                      true,
                )
                .length;

            return ListView(
              children: [
                UserProfileHeader(
                  userData: userData,
                  totalGoals: totalGoals,
                  completedGoals: completedGoals,
                  email: user.email ?? '',
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
  final String email;

  const UserProfileHeader({
    super.key,
    required this.userData,
    required this.totalGoals,
    required this.completedGoals,
    required this.email,
  });

  @override
  Widget build(BuildContext context) {
    final joinDate =
        DateTime.tryParse(userData['joinedDate'] ?? '') ?? DateTime.now();
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
          const SizedBox(height: 4),
          Text(email, style: const TextStyle(color: Colors.grey)),
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
              _buildStatItem(
                'Friends',
                (userData['friends']?.length ?? 0).toString(),
              ),
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

class FriendsSection extends StatefulWidget {
  final List<String> friendIds;

  const FriendsSection({super.key, required this.friendIds});

  @override
  State<FriendsSection> createState() => _FriendsSectionState();
}

class _FriendsSectionState extends State<FriendsSection> {
  late Future<List<Map<String, dynamic>>> _friendFuture;

  @override
  void initState() {
    super.initState();
    _friendFuture = _fetchFriendData();
  }

  Future<List<Map<String, dynamic>>> _fetchFriendData() async {
    if (widget.friendIds.isEmpty) return [];

    final firestore = FirebaseFirestore.instance;
    final friendDocs = await Future.wait(
      widget.friendIds.map((id) => firestore.collection('users').doc(id).get()),
    );

    return friendDocs
        .where((doc) => doc.exists)
        .map((doc) => doc.data()!)
        .toList();
  }

  void _refreshFriends() {
    setState(() {
      _friendFuture = _fetchFriendData();
    });
  }

  void _showAddFriendDialog(BuildContext context) {
    final emailController = TextEditingController();
    final currentUser = FirebaseAuth.instance.currentUser;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Friend'),
        content: TextField(
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(labelText: 'Enter friend\'s email'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF667eea), Color(0xFF764ba2)],
              ),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF667eea).withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: () async {
                final enteredEmail = emailController.text.trim();
                if (enteredEmail.isEmpty ||
                    enteredEmail == currentUser?.email) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Enter a valid email')),
                  );
                  return;
                }

                final userDoc = FirebaseFirestore.instance
                    .collection('users')
                    .doc(currentUser!.email);
                final friendDoc = FirebaseFirestore.instance
                    .collection('users')
                    .doc(enteredEmail);

                final friendSnap = await friendDoc.get();
                if (!friendSnap.exists) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('User not found')),
                  );
                  return;
                }

                await userDoc.update({
                  'friends': FieldValue.arrayUnion([enteredEmail]),
                });

                await friendDoc.update({
                  'friends': FieldValue.arrayUnion([currentUser.email]),
                });

                Navigator.pop(context);
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Friend added!')));

                _refreshFriends();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child: const Text(
                'Add',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Friends',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.person_add),
                tooltip: 'Add Friend',
                onPressed: () => _showAddFriendDialog(context),
              ),
            ],
          ),
          const SizedBox(height: 8),
          FutureBuilder<List<Map<String, dynamic>>>(
            future: _friendFuture,
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
                          final friendEmail = widget.friendIds[index];

                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => FriendProfileScreen(
                                        friendEmail: friendEmail,
                                      ),
                                    ),
                                  );
                                },
                                child: Column(
                                  children: [
                                    CircleAvatar(
                                      radius: 30,
                                      backgroundImage:
                                          (friend['profileImage'] ?? '')
                                              .isNotEmpty
                                          ? NetworkImage(friend['profileImage'])
                                          : null,
                                      child:
                                          (friend['profileImage'] ?? '').isEmpty
                                          ? Text(
                                              friend['name']
                                                      ?.substring(0, 1)
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
              );
            },
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: () async {
                final friends = await _friendFuture;
                final currentUserEmail =
                    FirebaseAuth.instance.currentUser?.email ?? '';

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AllFriendsScreen(
                      friends: friends,
                      fromEmail: currentUserEmail,
                    ),
                  ),
                );
              },
              child: const Text('View All Friends'),
            ),
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to sign out')));
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
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AccountSettingsScreen(),
                ),
              );
            },
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
