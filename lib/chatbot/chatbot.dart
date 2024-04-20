import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class chatbot extends StatefulWidget {
  const chatbot({super.key});

  @override
  State<chatbot> createState() => _chatbotState();
}

class _chatbotState extends State<chatbot> {
  @override
  Widget build(BuildContext context) {
    return Text('Hiii I am TripMan. How Can I help you');
  }
}
