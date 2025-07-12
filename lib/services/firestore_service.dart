import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:goalkeeper/models/goal.dart';
import 'package:goalkeeper/models/user.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Users Collection
  static const String usersCollection = 'users';

  // Goals Collection
  static const String goalsCollection = 'goals';

  // Get current user document
  Future<User?> getUser(String userId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection(usersCollection)
          .doc(userId)
          .get();
      return doc.exists
          ? User.fromMap(doc.data() as Map<String, dynamic>)
          : null;
    } catch (e) {
      print('Error fetching user: $e');
      return null;
    }
  }

  // Get all goals for a user (personal + group)
  Stream<List<Goal>> getGoalsForUser(String userId) {
    return _firestore
        .collection(goalsCollection)
        .where('participants', arrayContains: userId)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Goal.fromMap(doc.data())).toList(),
        );
  }

  // Add a new goal
  Future<void> addGoal(Goal goal) async {
    await _firestore.collection(goalsCollection).doc(goal.id).set(goal.toMap());
  }

  // Update a goal
  Future<void> updateGoal(Goal goal) async {
    await _firestore
        .collection(goalsCollection)
        .doc(goal.id)
        .update(goal.toMap());
  }

  // Delete a goal
  Future<void> deleteGoal(String goalId) async {
    await _firestore.collection(goalsCollection).doc(goalId).delete();
  }

  // Toggle goal completion status
  Future<void> toggleGoalCompletion(String goalId, bool isCompleted) async {
    await _firestore.collection(goalsCollection).doc(goalId).update({
      'isCompleted': !isCompleted,
    });
  }
}
