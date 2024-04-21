import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:tripsathihackathon/models/expense.dart';

class ExpenseItem extends StatelessWidget {
  final String expenseId;

  const ExpenseItem(Expense expens, {Key? key, required this.expenseId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('user_expenses')  // Main collection
          .doc(expenseId)  // Document with user's UID
          .collection('expenses')  // Subcollection for user's expenses
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        return ListView(
          children: snapshot.data!.docs.map((DocumentSnapshot document) {
            Map<String, dynamic> data = document.data() as Map<String, dynamic>;
            Expense expense = Expense(
              id: document.id,
              title: data['title'],
              amount: data['amount'],
              date: data['date'].toDate(),
              category: Category.values.firstWhere(
                    (e) => e.toString() == 'Category.${data['category']}',
              ), uid: '',
            );
            return ExpenseItemCard(expense: expense);
          }).toList(),
        );
      },
    );
  }
}

class ExpenseItemCard extends StatelessWidget {
  const ExpenseItemCard({Key? key, required this.expense}) : super(key: key);

  final Expense expense;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(expense.title),
            const SizedBox(height: 4),
            Row(
              children: [
                Text('Rs. ${expense.amount.toStringAsFixed(2)}'),
                const Spacer(),
                Row(
                  children: [
                    Icon(categoryIcons[expense.category]),
                    const SizedBox(width: 8),
                    Text(DateFormat.yMd().format(expense.date)), // Using DateFormat to format the date
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}