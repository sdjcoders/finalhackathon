import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tripsathihackathon/models/expense.dart' as ExpenseModel;
import 'package:tripsathihackathon/expense_tracker/widgets/expenses/expense_item.dart';
import 'package:tripsathihackathon/models/expense.dart';

class ExpensesList extends StatelessWidget {
  const ExpensesList({
    Key? key,
    required this.onRemoveExpense,
  }) : super(key: key);

  final void Function(Expense expense) onRemoveExpense;

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // Handle case when user is not logged in
      return Container(); // or show a login screen
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('user_expenses')
          .doc(user.uid)
          .collection('expenses')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }
        final List<Expense> expenses = snapshot.data!.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return Expense(
            id: doc.id,
            title: data['title'],
            amount: data['amount'],
            date: data['date'].toDate(),
            category: Category.values.firstWhere(
              (e) => e.toString() == 'Category.${data['category']}',
            ),
            uid: user.uid,
          );
        }).toList();

        return ListView.builder(
          itemCount: expenses.length,
          itemBuilder: (context, index) => Dismissible(
            key: ValueKey(expenses[index].id),
            background: Container(
              color:
                  Colors.blue.shade100, // Change background color to blue shade
              margin: Theme.of(context).cardTheme?.margin,
            ),
            onDismissed: (direction) {
              // Remove expense from the database
              onRemoveExpense(expenses[index]);
            },
            child: ExpenseItem(
              expenses[index],
              expenseId: '',
            ),
          ),
        );
      },
    );
  }
}
