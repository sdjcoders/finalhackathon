import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tripsathihackathon/models/expense.dart';
import 'package:tripsathihackathon/expense_tracker/widgets/charts/chart_bar.dart';


class Chart extends StatelessWidget {
  const Chart({Key? key, required this.expenses}) : super(key: key);

  final List<Expense> expenses;

  List<ExpenseBucket> get buckets {
    return [
      ExpenseBucket.forCategory(expenses, Category.Accommodation),
      ExpenseBucket.forCategory(expenses, Category.Transportation),
      ExpenseBucket.forCategory(expenses, Category.FoodAndDining),
      ExpenseBucket.forCategory(expenses, Category.ActivitiesAndEntertainment),
    ];
  }

  double get maxTotalExpense {
    double maxTotalExpense = 0;

    for (final bucket in buckets) {
      if (bucket.totalExpenses > maxTotalExpense) {
        maxTotalExpense = bucket.totalExpenses;
      }
    }

    return maxTotalExpense;
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('user_expenses') // Main collection for user expenses
          .doc('user123') // Document with user's UID
          .collection('expenses') // Subcollection for user's expenses
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        final List<Expense> fetchedExpenses = snapshot.data!.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return Expense.fromMap(data);
        }).toList();

        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 8,
          ),
          width: double.infinity,
          height: 180,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Color.fromARGB(255, 13, 65, 117),
          ),
          child: Column(
            children: [
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    for (final bucket in buckets)
                      ChartBar(
                        fill: bucket.totalExpenses == 0
                            ? 0
                            : bucket.totalExpenses / maxTotalExpense,
                      )
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: buckets
                    .map(
                      (bucket) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Icon(
                          categoryIcons[bucket.category] ?? Icons.error,
                          color: Colors.white),
                    ),
                  ),
                )
                    .toList(),
              )
            ],
          ),
        );
      },
    );
  }
}

class ExpenseBucket {
  final Category category;
  final List<Expense> expenses;

  ExpenseBucket(this.category, this.expenses);

  double get totalExpenses {
    return expenses.fold(0, (sum, item) => sum + item.amount);
  }

  static ExpenseBucket forCategory(List<Expense> expenses, Category category) {
    final categoryExpenses =
    expenses.where((expense) => expense.category == category).toList();
    return ExpenseBucket(category, categoryExpenses);
  }
}
