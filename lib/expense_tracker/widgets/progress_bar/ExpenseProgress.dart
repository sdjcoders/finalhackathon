import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tripsathihackathon/models/budget.dart';


class ExpenseProgressCard extends StatefulWidget {
  final double totalExpenses;
  final void Function(double) onMaxBudgetChanged;

  ExpenseProgressCard({
    required this.totalExpenses,
    required this.onMaxBudgetChanged,
  });

  @override
  _ExpenseProgressCardState createState() => _ExpenseProgressCardState();
}

class _ExpenseProgressCardState extends State<ExpenseProgressCard> {
  late double _maxBudget;
  late int _tripDuration;
  double dailyExpense = 0;
  late FirebaseService _firebaseService;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _firebaseService = FirebaseService();
    _maxBudget = 0;
    _tripDuration = 1;
    _fetchBudget();
  }

  Future<void> _fetchBudget() async {
    setState(() {
      _isLoading = true;
    });

    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        Budget? budget = await _firebaseService.getBudget(user.uid);
        if (budget != null) {
          setState(() {
            _maxBudget = budget.totalBudget;
            _tripDuration = budget.tripDuration;
            dailyExpense = _maxBudget / _tripDuration;
          });
        }
      }
    } catch (e) {
      print("Error fetching budget: $e");
      // Handle error, show snackbar, or retry logic
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateBudget() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        Budget budget = Budget(
          userId: user.uid,
          totalBudget: _maxBudget,
          tripDuration: _tripDuration,
        );
        await _firebaseService
            .updateBudget(budget); // Use updateBudget instead of addBudget
      }
    } catch (e) {
      print("Error updating budget: $e");
      // Handle error, show snackbar, or retry logic
    }
  }

  @override
  Widget build(BuildContext context) {
    double totalSpent = widget.totalExpenses;
    double dailyBudget = _maxBudget / _tripDuration;
    double totalBudget = _maxBudget;

    return _isLoading
        ? Center(
      child: CircularProgressIndicator(),
    )
        : SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Card(
          color: Colors.white,
          elevation: 5,
          margin: EdgeInsets.all(10),
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Trip Expenses Progress',
                  style: TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Text(
                  'Total Expenses: Rs ${totalSpent.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        initialValue: _maxBudget.toStringAsFixed(2),
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Total Trip Budget (Rs)',
                        ),
                        onChanged: (value) {
                          setState(() {
                            _maxBudget = double.tryParse(value) ?? 0.0;
                            dailyExpense = _maxBudget / _tripDuration;
                            widget.onMaxBudgetChanged(_maxBudget);
                          });
                        },
                        onEditingComplete:
                        _updateBudget, // Call _updateBudget when editing is complete
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        initialValue: _tripDuration.toString(),
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Trip Duration (days)',
                        ),
                        onChanged: (value) {
                          setState(() {
                            _tripDuration =
                                int.tryParse(value) ?? _tripDuration;
                            dailyExpense = _maxBudget / _tripDuration;
                          });
                        },
                        onEditingComplete:
                        _updateBudget, // Call _updateBudget when editing is complete
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                _buildProgressBar("Total", totalSpent, totalBudget),
                SizedBox(height: 10),
                _buildProgressBar("Daily", totalSpent, dailyBudget),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBar(String label, double spent, double budget) {
    double progress = budget != 0 ? spent / budget : 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label Expenses',
          style: TextStyle(fontSize: 16),
        ),
        SizedBox(height: 5),
        Stack(
          children: [
            Container(
              height: 10,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            AnimatedContainer(
              duration: Duration(milliseconds: 500),
              height: 10,
              width: MediaQuery.of(context).size.width * progress,
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          ],
        ),
        SizedBox(height: 5),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Spent: Rs ${spent.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 12),
            ),
            Text(
              'Budget: Rs ${budget.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
      ],
    );
  }
}
