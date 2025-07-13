import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:goalkeeper/models/goal.dart';
import 'package:goalkeeper/models/user.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String usersCollection = 'users';
  static const String goalsCollection = 'goals';

  // Add this method to FirestoreService
  Future<void> createUser(User user) async {
    await _firestore.collection(usersCollection).doc(user.id).set(user.toMap());
  }

  // Fetch user by email
  Future<User?> getUserByEmail(String email) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection(usersCollection)
          .doc(email)
          .get();
      return doc.exists
          ? User.fromMap(doc.data() as Map<String, dynamic>)
          : null;
    } catch (e) {
      print('Error fetching user: $e');
      return null;
    }
  }

  // Fetch multiple users by email
  Future<List<User>> getUsersByEmails(List<String> emails) async {
    final userDocs = await Future.wait(
      emails.map(
        (email) => _firestore.collection(usersCollection).doc(email).get(),
      ),
    );
    return userDocs
        .where((doc) => doc.exists)
        .map((doc) => User.fromMap(doc.data()!))
        .toList();
  }

  // Add or remove friend
  Future<void> toggleFriend(
    String currentUserEmail,
    String friendEmail,
    bool isFriend,
  ) async {
    final userRef = _firestore
        .collection(usersCollection)
        .doc(currentUserEmail);
    await userRef.update({
      'friends': isFriend
          ? FieldValue.arrayRemove([friendEmail])
          : FieldValue.arrayUnion([friendEmail]),
    });
  }

  Future<void> updateUserProfile(
    String email,
    String name,
    String profileImage,
  ) async {
    await _firestore.collection(usersCollection).doc(email).update({
      'name': name,
      'profileImage': profileImage,
    });
  }

  // Get all goals where user's email is in participants
  Stream<List<Goal>> getGoalsForUser(String userEmail) {
    return _firestore
        .collection(goalsCollection)
        .where('participants', arrayContains: userEmail)
        .snapshots()
        .asyncMap((snapshot) async {
          List<Goal> goals = [];
          for (var doc in snapshot.docs) {
            final goalData = doc.data();

            // Get creator details
            final creator = await getUserByEmail(goalData['createdBy']);

            // Get participants' user details
            List<Map<String, String>> participants = [];
            for (String email in List<String>.from(goalData['participants'])) {
              final user = await getUserByEmail(email);
              if (user != null) {
                participants.add({'email': email, 'name': user.name});
              }
            }

            goals.add(
              Goal(
                id: doc.id,
                title: goalData['title'],
                description: goalData['description'],
                isCompleted: goalData['isCompleted'] ?? false,
                dueDate: goalData['dueDate']?.toDate(),
                createdAt: goalData['createdAt']?.toDate() ?? DateTime.now(),
                createdBy: {
                  'email': goalData['createdBy'],
                  'name': creator?.name ?? 'Unknown',
                },
                isGroupGoal: goalData['isGroupGoal'] ?? false,
                participants: participants,
              ),
            );
          }

          return goals;
        });
  }

  // Add a new goal (store only email strings for participants and creator)
  Future<void> addGoal(Goal goal) async {
    await _firestore.collection(goalsCollection).doc(goal.id).set({
      'title': goal.title,
      'description': goal.description,
      'isCompleted': goal.isCompleted,
      'dueDate': goal.dueDate,
      'createdAt': goal.createdAt,
      'createdBy': goal.createdBy['email'], // store only email
      'isGroupGoal': goal.isGroupGoal,
      'participants': goal.participants
          .map((p) => p['email'])
          .toList(), // only emails
    });
  }

  // Update a goal
  Future<void> updateGoal(Goal goal) async {
    await _firestore.collection(goalsCollection).doc(goal.id).update({
      'title': goal.title,
      'description': goal.description,
      'isCompleted': goal.isCompleted,
      'dueDate': goal.dueDate,
      'isGroupGoal': goal.isGroupGoal,
      'participants': goal.participants.map((p) => p['email']).toList(),
    });
  }

  // Delete a goal
  Future<void> deleteGoal(String goalId) async {
    await _firestore.collection(goalsCollection).doc(goalId).delete();
  }

  // Toggle goal completion
  Future<void> toggleGoalCompletion(String goalId, bool isCompleted) async {
    await _firestore.collection(goalsCollection).doc(goalId).update({
      'isCompleted': !isCompleted,
    });
  }
}
