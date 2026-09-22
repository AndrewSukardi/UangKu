import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';

import 'package:UangKu/core/database/app_database.dart';        
import 'package:UangKu/core/database/tables/finance_tables.dart'; 

/// Which page of the wizard is showing. The list of steps depends on the
/// selected wallet type (see [WalletFormData.steps]).
enum WalletStep { details, billing, confirmation }

class WalletFormData extends ChangeNotifier {
  /// Order must match the tab bar: Cash | Debit | Credit Card.
  static const List<WalletType> tabTypes = [
    WalletType.cash,
    WalletType.bankAccount,
    WalletType.creditCard,
  ];

  WalletType type = WalletType.cash;

  // Shared by all types.
  final TextEditingController nameController = TextEditingController();

  // Debit + credit card only.
  final TextEditingController lastFourController = TextEditingController();

  // Cash + debit only.
  final ValueNotifier<int> initialBalance = ValueNotifier<int>(0);

  // Credit card only.
  final ValueNotifier<int> creditLimit = ValueNotifier<int>(0);
  final TextEditingController statementDayController = TextEditingController();
  final TextEditingController dueDayController = TextEditingController();

  WalletFormData() {
    // Bubble every field change up so anything listening to the whole form
    // (the wizard's Next button, the confirmation card) rebuilds too.
    nameController.addListener(notifyListeners);
    lastFourController.addListener(notifyListeners);
    statementDayController.addListener(notifyListeners);
    dueDayController.addListener(notifyListeners);
    initialBalance.addListener(notifyListeners);
    creditLimit.addListener(notifyListeners);
  }

  // ── Type helpers ─────────────────────────────────────────────────────

  bool get isCash => type == WalletType.cash;
  bool get isDebit => type == WalletType.bankAccount;
  bool get isCredit => type == WalletType.creditCard;

  /// Debit and credit cards both have a "last 4 digits" field.
  bool get hasCardNumber => isDebit || isCredit;

  void setType(WalletType newType) {
    if (type == newType) return;
    type = newType;
    notifyListeners();
  }

  // ── Cleaned values ───────────────────────────────────────────────────

  String get name => nameController.text.trim();
  String get lastFour => lastFourController.text.trim();

  /// null when left blank (or not a number).
  int? get statementDay => int.tryParse(statementDayController.text.trim());
  int? get dueDay => int.tryParse(dueDayController.text.trim());

  // ── Steps ────────────────────────────────────────────────────────────

  /// Cash and debit are a single details page. Credit cards get an extra
  /// "billing cycle" page for the statement / due dates.
  List<WalletStep> get steps {
    if (isCredit) {
      return const [
        WalletStep.details,
        WalletStep.billing,
        WalletStep.confirmation,
      ];
    }
    return const [WalletStep.details, WalletStep.confirmation];
  }

  // ── Validation ───────────────────────────────────────────────────────
  // Each validator returns an error message, or null when the value is OK.
  // They're public so TextFormFields can use them directly.

  String? validateName(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Wallet name is required';
    if (v.length > 100) return 'Wallet name can be at most 100 characters';
    return null;
  }

  String? validateLastFour(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Last 4 digits are required';
    if (!RegExp(r'^\d{4}$').hasMatch(v)) return 'Enter exactly 4 digits';
    return null;
  }

  String? validateCreditLimit() {
    if (creditLimit.value <= 0) return 'Credit limit must be greater than 0';
    return null;
  }

  /// Statement / due date are optional: blank is fine, otherwise the value
  /// must be a whole number from 1 to 31.
  String? validateDayOfMonth(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return null;
    final day = int.tryParse(v);
    if (day == null || day < 1 || day > 31) {
      return 'Enter a day between 1 and 31';
    }
    return null;
  }

  bool isStepValid(WalletStep step) {
    switch (step) {
      case WalletStep.details:
        if (validateName(nameController.text) != null) return false;
        if (isCash) return true; // name + initial balance (0 is allowed)
        if (validateLastFour(lastFourController.text) != null) return false;
        if (isCredit) return validateCreditLimit() == null;
        return true; // debit
      case WalletStep.billing:
        return validateDayOfMonth(statementDayController.text) == null &&
            validateDayOfMonth(dueDayController.text) == null;
      case WalletStep.confirmation:
        return true;
    }
  }

  /// Every step that applies to the current type must be valid.
  bool get isValid => steps.every(isStepValid);

  // ── DB mapping ───────────────────────────────────────────────────────

  /// Ready for `walletDao.addWallet(...)`.
  ///
  /// For credit cards `balance` is the *outstanding used amount*, so a new
  /// card starts at 0 (nothing owed yet), matching your Wallets table docs.

  WalletsCompanion toCompanion() {
    return WalletsCompanion.insert(
      name: name,
      type: type,
      balance: Value(isCredit ? 0 : initialBalance.value.toDouble()),
      creditLimit: Value(isCredit ? creditLimit.value.toDouble() : null),
      lastFour: Value(hasCardNumber ? lastFour : null),
      statementDay: Value(isCredit ? statementDay : null),
      dueDay: Value(isCredit ? dueDay : null),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    lastFourController.dispose();
    statementDayController.dispose();
    dueDayController.dispose();
    initialBalance.dispose();
    creditLimit.dispose();
    super.dispose();
  }
}
