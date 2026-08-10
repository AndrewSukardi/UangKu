import 'package:flutter/material.dart';

enum TransactionType { expense, income, transfer }

class TransactionFormData extends ChangeNotifier {
  TransactionType type = TransactionType.expense;
  final ValueNotifier<int> amount = ValueNotifier<int>(0);
  String? category;
  String? note;
  DateTime date = DateTime.now();

  TransactionFormData() {
    amount.addListener(notifyListeners); // bubble amount changes up
  }

  void setType(TransactionType newType) {
    if (type == newType) return;
    type = newType;
    notifyListeners();
  }

  bool get isAmountStepValid => amount.value > 0;
  bool get isCategoryStepValid => category != null && category!.isNotEmpty;
  bool get isDetailsStepValid => true; 

  bool isStepValid(int stepIndex) {
    switch (stepIndex) {
      case 0:
        return isAmountStepValid;
      case 1:
        return isCategoryStepValid;
      case 2:
        return isDetailsStepValid;
      default:
        return true; // confirmation step, nothing to validate
    }
  }


  Map<String, dynamic> toJson() => {
        'type': type.name,
        'amount': amount.value,
        'category': category,
        'note': note,
        'date': date.toIso8601String(),
      };

  @override
  void dispose() {
    amount.dispose();
    super.dispose();
  }
}