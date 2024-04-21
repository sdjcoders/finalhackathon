import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tripsathihackathon/models/expense.dart';

class ExpenseItem extends StatelessWidget {
  const ExpenseItem({
    Key? key,
    required this.expense,
    required this.onRemove,
  }) : super(key: key);

  final Expense expense;
  final void Function(Expense) onRemove;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(expense.id),
      direction: DismissDirection.horizontal,
      onDismissed: (direction) {
        onRemove(expense); // Call onRemove callback
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Deleted ${expense.title}'),
            action: SnackBarAction(
              label: 'Undo',
              onPressed: () {
                // Implement functionality to undo deletion
              },
            ),
          ),
        );
      },
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20.0),
        child: Icon(Icons.delete, color: Colors.white),
      ),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(expense.title),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    'Rs. ${expense.amount.toStringAsFixed(2)}',
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Icon(Icons.category), // Replace with your category icon logic
                      const SizedBox(width: 8),
                      Text(expense.formattedDate),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FilteredExpensesPage extends StatelessWidget {
  final List<Expense> filteredExpenses;
  final void Function(Expense) onRemove; // Define onRemove callback

  const FilteredExpensesPage({
    Key? key,
    required this.filteredExpenses,
    required this.onRemove,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Filtered Expenses'),
      ),
      body: filteredExpenses.isEmpty
          ? Center(
        child: Text('No expenses found.'),
      )
          : ListView.builder(
        itemCount: filteredExpenses.length,
        itemBuilder: (context, index) {
          final expense = filteredExpenses[index];
          return ExpenseItem(
            expense: expense,
            onRemove: onRemove,
          );
        },
      ),
    );
  }
}

class Expenses extends StatelessWidget {
  const Expenses({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Tracker'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Column(
          children: [
            _buildSquareButton('Daily Expenses', context, 'Daily'),
            const SizedBox(height: 8),
            _buildSquareButton('All Expenses', context, 'All'),
          ],
        ),
      ),
    );
  }

  Widget _buildSquareButton(
      String text, BuildContext context, String filter) {
    return SizedBox(
      width: 130,
      height: 50,
      child: ElevatedButton(
        onPressed: () {
          _navigateToFilteredExpensesPage(context, filter);
        },
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
        child: Text(text),
      ),
    );
  }

  void _navigateToFilteredExpensesPage(
      BuildContext context, String filter) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // Handle case when user is not logged in
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('user_expenses') // Main collection
              .doc(user.uid) // Document with user's UID
              .collection('expenses') // Subcollection for user's expenses
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            final expenses = snapshot.data!.docs.map((doc) {
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

            List<Expense> filteredExpenses;
            if (filter == 'All') {
              filteredExpenses = expenses;
            } else {
              filteredExpenses = _filterDailyExpenses(expenses, DateTime.now());
            }

            return FilteredExpensesPage(
              filteredExpenses: filteredExpenses,
              onRemove: (expense) {
                // Implement logic to remove expense from the database
                FirebaseFirestore.instance
                    .collection('user_expenses') // Main collection
                    .doc(user.uid) // Document with user's UID
                    .collection('expenses') // Subcollection for user's expenses
                    .doc(expense.id) // Document for this specific expense
                    .delete();
              },
            );
          },
        ),
      ),
    );
  }

  List<Expense> _filterDailyExpenses(List<Expense> expenses, DateTime date) {
    return expenses.where((expense) => isSameDay(expense.date, date)).toList();
  }

  bool isSameDay(DateTime d1, DateTime d2) {
    return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
  }
}

void main() {
  runApp(MaterialApp(
    home: Expenses(),
  ));
}
