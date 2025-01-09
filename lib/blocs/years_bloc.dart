import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class YearsBloc extends ChangeNotifier {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  int _selctedYear = 3;
  int get selctedYear => _selctedYear;

  List<int> years = [
    3,
    4,
    5,
  ];
  void changeselctedYear(int value) {
    _selctedYear = value;
    notifyListeners();
  }
}
