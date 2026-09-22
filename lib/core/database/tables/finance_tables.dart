import 'package:drift/drift.dart';

// =========================================================================
// ENUMS
// =========================================================================

enum WalletType { cash, bankAccount, eWallet, creditCard }

enum TransactionType { income, expense, transfer }

/// debt        = hutang (you owe money)
/// receivable  = piutang (someone owes you)
/// installment = financed purchase / cicilan with its own billing cycle
enum LoanType { debt, receivable, installment }

enum LoanStatus { active, paidOff, defaulted, cancelled }

enum BudgetPeriod { weekly, monthly, custom }

// =========================================================================
// WALLETS  (cash, bank, e-wallet, credit card all live here)
// =========================================================================

@DataClassName('Wallet')
class Wallets extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  IntColumn get type => intEnum<WalletType>()();
  TextColumn get currency => text().withDefault(const Constant('IDR'))();
  TextColumn get lastFour => text().withLength(min: 4, max: 4).nullable()();

  /// Cash/bank/e-wallet: actual balance.
  /// Credit card: outstanding used amount (0 = fully paid off).
  RealColumn get balance => real().withDefault(const Constant(0))();

  /// Only set when type == creditCard.
  RealColumn get creditLimit => real().nullable()();

  /// "Tanggal cetak" — day of month (1-31) the statement is generated.
  IntColumn get statementDay => integer().nullable()();

  /// "Tanggal jatuh tempo" — day of month (1-31) payment is due.
  IntColumn get dueDay => integer().nullable()();

  TextColumn get colorHex => text().nullable()();
  TextColumn get icon => text().nullable()();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

// =========================================================================
// CATEGORIES
// =========================================================================

@DataClassName('Category')
class Categories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  IntColumn get type => intEnum<TransactionType>()(); // income or expense
  IntColumn get parentId =>
      integer().nullable().references(Categories, #id)();
  TextColumn get icon => text().nullable()();
  TextColumn get colorHex => text().nullable()();
}

// =========================================================================
// TRANSACTIONS
// =========================================================================

@DataClassName('WalletTransaction')
class Transactions extends Table {
  IntColumn get id => integer().autoIncrement()();

  @ReferenceName('transactions')
  IntColumn get walletId => integer().references(Wallets, #id)();

  IntColumn get categoryId =>
      integer().nullable().references(Categories, #id)();
  IntColumn get type => intEnum<TransactionType>()();
  RealColumn get amount => real()();

  /// Only used when type == transfer.
  @ReferenceName('incomingTransfers')
  IntColumn get transferToWalletId =>
      integer().nullable().references(Wallets, #id)();

  /// If this transaction IS a loan disbursement or installment payment,
  /// link it back so it shows up in both the wallet ledger and the loan.
  IntColumn get loanId => integer().nullable().references(Loans, #id)();
  IntColumn get loanInstallmentId =>
      integer().nullable().references(LoanInstallments, #id)();

  DateTimeColumn get date => dateTime()();
  TextColumn get note => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

// =========================================================================
// BUDGETS  (spending limit attached to a specific wallet)
// =========================================================================

@DataClassName('Budget')
class Budgets extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();

  IntColumn get walletId => integer().references(Wallets, #id)();

  /// Optional — narrow the budget to one category within that wallet.
  IntColumn get categoryId =>
      integer().nullable().references(Categories, #id)();

  RealColumn get limitAmount => real()();
  IntColumn get period => intEnum<BudgetPeriod>()();

  /// For weekly/monthly: which day of the week/month it resets on.
  IntColumn get resetDay => integer().nullable()();

  /// For period == custom.
  DateTimeColumn get startDate => dateTime().nullable()();
  DateTimeColumn get endDate => dateTime().nullable()();

  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

// =========================================================================
// LOANS  (hutang / piutang / cicilan — paid FROM a wallet, not a wallet itself)
// =========================================================================

@DataClassName('Loan')
class Loans extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()(); // "Kredit Motor", "Pinjaman ke Budi", etc.
  IntColumn get type => intEnum<LoanType>()();
  IntColumn get status =>
      intEnum<LoanStatus>().withDefault(const Constant(0))();

  RealColumn get principalAmount => real()();
  RealColumn get interestRate => real().nullable()(); // % per period
  IntColumn get tenor => integer().nullable()(); // total installments, if any

  DateTimeColumn get startDate => dateTime()();

  /// "Tanggal cetak" — day of month the invoice/statement is issued,
  /// applied each billing period.
  IntColumn get statementDay => integer()();

  /// "Tanggal jatuh tempo" — fixed day of month, or an offset (days) from
  /// the statement date. Use whichever matches the lender's format.
  IntColumn get dueDay => integer().nullable()();
  IntColumn get dueDateOffsetDays => integer().nullable()();

  /// The wallet that normally pays this loan (can be overridden per
  /// installment in LoanInstallments.paidWalletId).
  IntColumn get defaultPaymentWalletId =>
      integer().nullable().references(Wallets, #id)();

  TextColumn get note => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

// =========================================================================
// LOAN INSTALLMENTS  (one row per billing period, with both due dates)
// =========================================================================

@DataClassName('LoanInstallment')
class LoanInstallments extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get loanId => integer().references(Loans, #id)();
  IntColumn get installmentNumber => integer()();

  DateTimeColumn get statementDate => dateTime()(); // tanggal cetak
  DateTimeColumn get dueDate => dateTime()(); // tanggal jatuh tempo

  RealColumn get amountDue => real()();
  RealColumn get principalPortion => real().nullable()();
  RealColumn get interestPortion => real().nullable()();
  RealColumn get lateFee => real().withDefault(const Constant(0))();

  BoolColumn get isPaid => boolean().withDefault(const Constant(false))();
  DateTimeColumn get paidAt => dateTime().nullable()();
  RealColumn get paidAmount => real().nullable()();

  /// May differ from Loans.defaultPaymentWalletId (e.g. paid from a
  /// different wallet just this once).
  IntColumn get paidWalletId =>
      integer().nullable().references(Wallets, #id)();

  @override
  List<Set<Column>> get uniqueKeys => [
        {loanId, installmentNumber},
      ];
}