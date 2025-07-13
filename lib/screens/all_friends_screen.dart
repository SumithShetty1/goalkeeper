import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:goalkeeper/screens/friend_profile_screen.dart';
import 'package:goalkeeper/services/firestore_service.dart'; // ✅ Import FirestoreService

class AllFriendsScreen extends StatefulWidget {
  final List<Map<String, dynamic>> friends;
  final String fromEmail;

  const AllFriendsScreen({
    super.key,
    required this.friends,
    required this.fromEmail,
  });

  @override
  State<AllFriendsScreen> createState() => _AllFriendsScreenState();
}

class _AllFriendsScreenState extends State<AllFriendsScreen> {
  final String currentUserEmail =
      FirebaseAuth.instance.currentUser?.email ?? '';
  final TextEditingController _searchController = TextEditingController();

  final FirestoreService _firestoreService = FirestoreService();

  List<Map<String, dynamic>> _friends = [];
  List<Map<String, dynamic>> _filteredFriends = [];

  @override
  void initState() {
    super.initState();
    _loadFriends();
    _searchController.addListener(_filterFriends);
  }

  Future<void> _loadFriends() async {
    final user = await _firestoreService.getUserByEmail(widget.fromEmail);
    if (user == null) return;

    final users = await _firestoreService.getUsersByEmails(user.friends);

    final friends = users
        .map((u) => {
              'email': u.id,
              'name': u.name,
              'profileImage': u.profileImage,
            })
        .toList();

    setState(() {
      _friends = friends;
      _filteredFriends = friends;
    });
  }

  void _filterFriends() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredFriends = _friends.where((friend) {
        final name = (friend['name'] ?? '').toLowerCase();
        final email = (friend['email'] ?? '').toLowerCase();
        return name.contains(query) || email.contains(query);
      }).toList();
    });
  }

  void _toggleFriend(String friendEmail, bool isFriend) async {
    await _firestoreService.toggleFriend(currentUserEmail, friendEmail, isFriend);
    _loadFriends();
  }

  void _viewProfile(String friendEmail) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FriendProfileScreen(friendEmail: friendEmail),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isOwnProfile = currentUserEmail == widget.fromEmail;

    return Scaffold(
      appBar: AppBar(title: const Text("All Friends")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search friends',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredFriends.length,
              itemBuilder: (context, index) {
                final friend = _filteredFriends[index];
                final email = friend['email'];
                final name = friend['name'] ?? 'Unnamed';
                final profileImage = friend['profileImage'] ?? '';
                final isFriend = true;

                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(profileImage),
                  ),
                  title: Text(name),
                  subtitle: Text(email),
                  trailing: isOwnProfile
                      ? IconButton(
                          icon: Icon(
                            // ignore: dead_code
                            isFriend ? Icons.person_remove : Icons.person_add,
                            // ignore: dead_code
                            color: isFriend ? Colors.red : Colors.green,
                          ),
                          onPressed: () => _toggleFriend(email, isFriend),
                        )
                      : null,
                  onTap: () => _viewProfile(email),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
