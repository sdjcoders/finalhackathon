import 'package:cloud_firestore/cloud_firestore.dart';

class Budget {
  final String userId;
  final double totalBudget;
  final int tripDuration;

  Budget({
    required this.userId,
    required this.totalBudget,
    required this.tripDuration,
  });

  factory Budget.fromMap(Map<String, dynamic> map) {
    return Budget(
      userId: map['userId'],
      totalBudget: map['totalBudget'].toDouble(),
      tripDuration: map['tripDuration'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'totalBudget': totalBudget,
      'tripDuration': tripDuration,
    };
  }
}

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> updateBudget(Budget budget) async {
    try {
      await _firestore
          .collection('user_budget') // Main collection
          .doc(budget.userId) // Document with user's UID
          .set(budget.toMap(), SetOptions(merge: true)); // Use merge:true to update existing document
    } catch (e) {
      print("Error updating budget: $e");
      throw e;
    }
  }

  Future<Budget?> getBudget(String userId) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> snapshot = await _firestore
          .collection('user_budget') // Main collection
          .doc(userId) // Document with user's UID
          .get();

      if (snapshot.exists) {
        return Budget.fromMap(snapshot.data()!);
      } else {
        return null;
      }
    } catch (e) {
      print("Error fetching budget: $e");
      throw e;
    }
  }
}
