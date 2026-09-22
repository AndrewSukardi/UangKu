import 'package:flutter/material.dart';

enum TransactionType { expense, income, transfer }

/// Identifies which page of content a wizard step shows. Keeping this as
/// an enum (instead of a raw index) means the step list can change length
/// without anything downstream breaking.
enum TxStep { amountType, category, details, transferDetails, confirmation }

class TransactionFormData extends ChangeNotifier {
  TransactionType type = TransactionType.expense;
  final ValueNotifier<int> amount = ValueNotifier<int>(0);

  // Expense / income only.
  String? category;
  String? note;

  // Transfer only.
  String? fromAccount;
  String? toAccount;

  DateTime date = DateTime.now();

  TransactionFormData() {
    // Bubble amount changes up so anything listening to the whole form
    // (e.g. the wizard's Next button) rebuilds too.
    amount.addListener(notifyListeners);
  }

  void setType(TransactionType newType) {
    if (type == newType) return;
    type = newType;
    notifyListeners();
  }

  /// The steps that apply for the currently selected [type].
  /// Every flow starts with the shared amount/type page (that's where the
  /// Expense/Income/Transfer tab selector lives). Transfer then swaps
  /// Category + Details for a single "from/to account" page.
  List<TxStep> get steps {
    switch (type) {
      case TransactionType.transfer:
        return const [
          TxStep.amountType,
          TxStep.transferDetails,
          TxStep.confirmation,
        ];
      case TransactionType.expense:
      case TransactionType.income:
        return const [
          TxStep.amountType,
          TxStep.category,
          TxStep.details,
          TxStep.confirmation,
        ];
    }
  }

  bool isStepValid(TxStep step) {
    switch (step) {
      case TxStep.amountType:
        return amount.value > 0;
      case TxStep.category:
        return category != null && category!.isNotEmpty;
      case TxStep.details:
        return true; // note is optional
      case TxStep.transferDetails:
        return amount.value > 0 &&
            fromAccount != null &&
            toAccount != null &&
            fromAccount != toAccount;
      case TxStep.confirmation:
        return true;
    }
  }

  /// Shape this form needs to be in to hand to a repository / DB insert.
  Map<String, dynamic> toMap() => {
        'type': type.name,
        'amount': amount.value,
        'category': type == TransactionType.transfer ? null : category,
        'note': type == TransactionType.transfer ? null : note,
        'from_account': type == TransactionType.transfer ? fromAccount : null,
        'to_account': type == TransactionType.transfer ? toAccount : null,
        'date': date.toIso8601String(),
      };

  @override
  void dispose() {
    amount.dispose();
    super.dispose();
  }
}