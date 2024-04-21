import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:tripsathihackathon/models/expense.dart';// Replace 'your_package' with the correct package name

class NewExpense extends StatefulWidget {
  const NewExpense({Key? key, required this.onAddExpense}) : super(key: key);

  final void Function(Expense) onAddExpense;

  @override
  State<NewExpense> createState() => _NewExpenseState();
}

class _NewExpenseState extends State<NewExpense> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  DateTime? _selectedDate;
  Category? _selectedCategory =
      Category.values.first; // Initialize with the first category
  bool _canAddExpense = false;
  late String _userUid;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _titleController.addListener(_validateExpense);
    _amountController.addListener(_validateExpense);
  }

  void _fetchUserData() {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _userUid = user.uid;
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _presentDatePicker() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
      _validateExpense();
    }
  }

  void _validateExpense() {
    setState(() {
      _canAddExpense = _titleController.text.isNotEmpty &&
          _amountController.text.isNotEmpty &&
          _selectedDate != null &&
          _selectedCategory != null;
    });
  }

  void _submitExpenseData() async {
    final enteredTitle = _titleController.text;
    final enteredAmount = double.tryParse(_amountController.text);

    if (enteredTitle.isEmpty ||
        enteredAmount == null ||
        enteredAmount <= 0 ||
        _selectedDate == null ||
        _selectedCategory == null ||
        _userUid.isEmpty) {
      return;
    }

    final currentTime = DateTime.now();

    final newExpense = Expense(
      id: FirebaseFirestore.instance.collection('expenses').doc().id,
      title: enteredTitle,
      amount: enteredAmount,
      date: _selectedDate!
          .add(Duration(hours: currentTime.hour, minutes: currentTime.minute)),
      category: _selectedCategory!,
      uid: _userUid,
    );

    try {
      await FirebaseFirestore.instance
          .collection('user_expenses')
          .doc(_userUid)
          .collection('expenses')
          .doc(newExpense.id)
          .set(newExpense.toMap());

      widget.onAddExpense(newExpense);
      Navigator.of(context).pop();
    } catch (error) {
      print("Error adding expense: $error");
      // Handle error appropriately, like showing a snackbar or dialog
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.only(top: 45),
          child: Text('Add Expense'),
        ),
        titleSpacing: 20,
        toolbarHeight: 100,
        centerTitle: true,
        leadingWidth: 60,
        leading: Padding(
          padding: const EdgeInsets.only(top: 50),
          child: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          color: Colors.white, // Set the background color of the container
          child: Card(
            color: Color.fromARGB(255, 255, 255, 255),
            elevation: 5,
            child: Padding(
              padding: EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  TextField(
                    decoration: InputDecoration(labelText: 'Title'),
                    controller: _titleController,
                    onChanged: (_) => _validateExpense(),
                    onSubmitted: (_) => _submitExpenseData(),
                  ),
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Amount',
                    ),
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    onChanged: (_) => _validateExpense(),
                    onSubmitted: (_) => _submitExpenseData(),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _selectedDate == null
                              ? 'No Date Chosen!'
                              : 'Picked Date: ${DateFormat.yMd().format(_selectedDate!)}',
                        ),
                      ),
                      TextButton(
                        onPressed: _presentDatePicker,
                        child: Text(
                          'Choose Date',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.blue),
                        ),
                      ),
                    ],
                  ),
                  DropdownButton<Category>(
                    value: _selectedCategory,
                    items: Category.values.map((category) {
                      return DropdownMenuItem<Category>(
                        value: category,
                        child: Text(category.toString().split('.').last),
                      );
                    }).toList(),
                    onChanged: (Category? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedCategory = newValue;
                          _validateExpense();
                        });
                      }
                    },
                  ),
                  ElevatedButton(
                    onPressed: _canAddExpense ? _submitExpenseData : null,
                    child: Text('Add Expense'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
