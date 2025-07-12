import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FriendProfileScreen extends StatelessWidget {
  final String friendEmail;

  const FriendProfileScreen({super.key, required this.friendEmail});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Friend Profile')),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('users').doc(friendEmail).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Friend data not found.'));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage(data['profileImage'] ?? ''),
                ),
                const SizedBox(height: 16),
                Text(data['name'] ?? 'Unknown', style: const TextStyle(fontSize: 24)),
                const SizedBox(height: 8),
                Text(data['email'] ?? friendEmail, style: const TextStyle(color: Colors.grey)),
              ],
            ),
          );
        },
      ),
    );
  }
}
