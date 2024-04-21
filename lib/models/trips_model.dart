import 'package:flutter/material.dart';

class Trip {
  final String uid;
  final String place;
  final DateTime timestamp;

  Trip({
    required this.uid,
    required this.place,
    required this.timestamp,
  });
}

class Interest {
  final String uid;
  final List<String> names;

  Interest({
    required this.uid,
    required this.names,
  });
}
