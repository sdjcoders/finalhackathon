import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:tripsathihackathon/models/expense.dart' as ExpenseModel;

import 'package:tripsathihackathon/expense_tracker/widgets/expenses/FilteredExpensesPage.dart';
import 'package:tripsathihackathon/expense_tracker/widgets/charts/chart.dart';
import 'package:tripsathihackathon/expense_tracker/screens/new_expense.dart';
import 'package:tripsathihackathon/expense_tracker/widgets/progress_bar/ExpenseProgress.dart';

class Expenses extends StatefulWidget {
  const Expenses({Key? key}) : super(key: key);

  @override
  State<Expenses> createState() => _ExpensesState();
}

class _ExpensesState extends State<Expenses> {
  final List<ExpenseModel.Expense> _registeredExpenses = [];

  @override
  void initState() {
    super.initState();
    _fetchExpenses();
  }

  Future<void> _fetchExpenses() async {
    try {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('user_expenses')
            .doc(user.uid)
            .collection('expenses')
            .get();
        setState(() {
          _registeredExpenses.clear();
          _registeredExpenses.addAll(querySnapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return ExpenseModel.Expense(
              id: doc.id,
              title: data['title'],
              amount: data['amount'],
              date: (data['date'] as Timestamp)
                  .toDate(), // Convert Timestamp to DateTime
              category: ExpenseModel.Category.values.firstWhere(
                    (e) => e.toString() == 'Category.${data['category']}',
              ),
              uid: user.uid,
            );
          }).toList());
        });
      }
    } catch (e) {
      print('Error fetching expenses: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Tracker'),
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () {
              showModalBottomSheet(
                isScrollControlled: true,
                context: context,
                builder: (ctx) => NewExpense(onAddExpense: _addExpense),
              );
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Column(
            children: [
              _buildFilterOptions(),
              Chart(expenses: _registeredExpenses),
              ExpenseProgressCard(
                totalExpenses: _calculateYearlyTotal(),
                // Set initial max budget to 0.00
                onMaxBudgetChanged: (newBudget) {
                  // Handle max budget change if needed
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterOptions() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          SizedBox(width: 16),
          _buildSquareButton('Trip Expenses', () {
            _navigateToFilteredExpensesPage(_registeredExpenses);
          }),
          SizedBox(width: 8),
          _buildSquareButton('Daily Expenses', () {
            final filteredExpenses = _filterDailyExpenses(DateTime.now());
            _navigateToFilteredExpensesPage(filteredExpenses);
          }),
        ],
      ),
    );
  }

  Widget _buildSquareButton(String text, Function() onPressed) {
    return SizedBox(
      width: 130,
      height: 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            backgroundColor: Color.fromARGB(255, 13, 65, 117),
            foregroundColor: Colors.white

          // Change the background color to light blue accent[50]
        ),
        child: Text(text),
      ),
    );
  }

  void _addExpense(ExpenseModel.Expense expense) {
    try {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        FirebaseFirestore.instance
            .collection('user_expenses')
            .doc(user.uid)
            .collection('expenses')
            .doc(expense.id)
            .set({
          'id': expense.id,
          'uid': user.uid,
          'title': expense.title,
          'amount': expense.amount,
          'date': expense.date,
          'category': expense.category.toString().split('.').last,
        }).then((_) {
          setState(() {
            _registeredExpenses.add(expense);
          });
        }).catchError((error) {
          print('Error adding expense: $error');
        });
      }
    } catch (e) {
      print('Error adding expense: $e');
    }
  }

  void _removeExpense(ExpenseModel.Expense expense) {
    try {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        FirebaseFirestore.instance
            .collection('user_expenses')
            .doc(user.uid)
            .collection('expenses')
            .doc(expense.id)
            .delete()
            .then((_) {
          setState(() {
            _registeredExpenses.remove(expense);
          });
        }).catchError((error) {
          print('Error removing expense: $error');
        });
      }
    } catch (e) {
      print('Error removing expense: $e');
    }
  }

  List<ExpenseModel.Expense> _filterDailyExpenses(DateTime date) {
    return _registeredExpenses
        .where((expense) => isSameDay(expense.date, date))
        .toList();
  }

  double _calculateYearlyTotal() {
    return _registeredExpenses.fold(
        0.0, (sum, expense) => sum + expense.amount);
  }

  bool isSameDay(DateTime d1, DateTime d2) {
    return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
  }

  void _navigateToFilteredExpensesPage(
      List<ExpenseModel.Expense> filteredExpenses) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => FilteredExpensesPage(
              filteredExpenses: filteredExpenses, onRemove: _removeExpense)),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: Expenses(),
  ));
}
