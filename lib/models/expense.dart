import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

final formatter = DateFormat.yMd();

enum Category { Accommodation, Transportation, FoodAndDining, ActivitiesAndEntertainment }

const categoryIcons = {
  Category.Accommodation: Icons.account_balance_wallet_outlined,
  Category.Transportation: Icons.directions_car,
  Category.FoodAndDining: Icons.restaurant,
  Category.ActivitiesAndEntertainment: Icons.movie,
};

class Expense {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final Category category;
  final String uid;

  Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
    required this.uid,
  });

  String get formattedDate => formatter.format(date);

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'],
      title: map['title'],
      amount: map['amount'].toDouble(),
      date: DateTime.parse(map['date']),
      category: Category.values.firstWhere((e) => e.toString() == map['category']),
      uid: map['uid'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'date': date.toIso8601String(),
      'category': category.toString(),
      'uid': uid,
    };
  }
}

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addExpense(Expense expense) async {
    try {
      await _firestore
          .collection('user_expenses')  // Main collection
          .doc(expense.uid)       // Document with user's UID
          .collection('expenses')  // Subcollection for user's expenses
          .doc(expense.id)        // Document for this specific expense
          .set(expense.toMap());
    } catch (e) {
      print("Error adding expense: $e");
      throw e;
    }
  }

  Future<void> removeExpense(String userId, String expenseId) async {
    try {
      await _firestore
          .collection('user_expenses')  // Main collection
          .doc(userId)       // Document with user's UID
          .collection('expenses')  // Subcollection for user's expenses
          .doc(expenseId)        // Document for this specific expense
          .delete();
    } catch (e) {
      print("Error removing expense: $e");
      throw e;
    }
  }
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense Tracker',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  final FirebaseService _firebaseService = FirebaseService();

  @override
  Widget build(BuildContext context) {
    // This is just for testing. You should call _firebaseService.addExpense
    // when the user wants to add an expense from your UI.
    final expense = Expense(
      id: '1',
      title: 'Groceries',
      amount: 50.0,
      date: DateTime.now(),
      category: Category.FoodAndDining,
      uid: '',
    );

    _firebaseService.addExpense(expense).then((_) {
      print('Expense added successfully');
    }).catchError((error) {
      print('Error adding expense: $error');
    });

    return Container();
  }
}
