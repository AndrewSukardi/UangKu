import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/finance_tables.dart';

part 'loan_dao.g.dart';

@DriftAccessor(tables: [Loans, LoanInstallments, Transactions, Wallets])
class LoanDao extends DatabaseAccessor<AppDatabase> with _$LoanDaoMixin {
  LoanDao(super.db);

  Stream<List<Loan>> watchAllLoans({LoanStatus? status}) {
    final query = select(loans);
    if (status != null) {
      query.where((l) => l.status.equalsValue(status));
    }
    return query.watch();
  }

  Future<int> addLoan(LoansCompanion loan) => into(loans).insert(loan);

  Stream<List<LoanInstallment>> watchInstallments(int loanId) {
    return (select(loanInstallments)
          ..where((i) => i.loanId.equals(loanId))
          ..orderBy([(i) => OrderingTerm.asc(i.installmentNumber)]))
        .watch();
  }

  /// Unpaid installments due within the next [days] days, across all loans.
  /// Handy for a "upcoming bills" widget.
  Stream<List<LoanInstallment>> watchUpcoming({int days = 7}) {
    final now = DateTime.now();
    final until = now.add(Duration(days: days));
    return (select(loanInstallments)
          ..where((i) =>
              i.isPaid.equals(false) &
              i.dueDate.isBiggerOrEqualValue(now) &
              i.dueDate.isSmallerOrEqualValue(until))
          ..orderBy([(i) => OrderingTerm.asc(i.dueDate)]))
        .watch();
  }

  /// Generates a flat (equal-amount) installment schedule for a loan,
  /// each row carrying its own tanggal-cetak / tanggal-jatuh-tempo pair.
  ///
  /// Pass either [dueDay] (fixed day of month) or [dueDateOffsetDays]
  /// (days after the statement date) — whichever matches the lender.
  Future<void> generateFlatSchedule({
    required int loanId,
    required int tenor,
    required double amountPerInstallment,
    required DateTime firstStatementDate,
    required int statementDay,
    int? dueDay,
    int? dueDateOffsetDays,
  }) async {
    final rows = <LoanInstallmentsCompanion>[];

    for (var i = 0; i < tenor; i++) {
      final statementDate = DateTime(
        firstStatementDate.year,
        firstStatementDate.month + i,
        statementDay,
      );

      DateTime dueDate;
      if (dueDay != null) {
        dueDate = DateTime(statementDate.year, statementDate.month, dueDay);
        // If the due-day number is earlier than the statement day, the due
        // date actually falls in the following month (e.g. cetak tgl 25,
        // jatuh tempo tgl 10 next month).
        if (dueDate.isBefore(statementDate)) {
          dueDate = DateTime(statementDate.year, statementDate.month + 1, dueDay);
        }
      } else {
        dueDate = statementDate.add(Duration(days: dueDateOffsetDays ?? 15));
      }

      rows.add(LoanInstallmentsCompanion.insert(
        loanId: loanId,
        installmentNumber: i + 1,
        statementDate: statementDate,
        dueDate: dueDate,
        amountDue: amountPerInstallment,
      ));
    }

    await batch((b) => b.insertAll(loanInstallments, rows));
  }

  /// Pays an installment: records a ledger transaction against [walletId],
  /// debits that wallet's balance, and marks the installment paid.
  /// All three happen in one atomic transaction.
  Future<void> payInstallment({
    required int installmentId,
    required int walletId,
    required double amount,
    DateTime? paidAt,
    int? categoryId,
  }) {
    return transaction(() async {
      final installment = await (select(loanInstallments)
            ..where((i) => i.id.equals(installmentId)))
          .getSingle();

      final when = paidAt ?? DateTime.now();

      await into(transactions).insert(TransactionsCompanion.insert(
        walletId: walletId,
        type: TransactionType.expense,
        amount: amount,
        categoryId: Value(categoryId),
        loanId: Value(installment.loanId),
        loanInstallmentId: Value(installmentId),
        date: when,
      ));

      await (update(loanInstallments)..where((i) => i.id.equals(installmentId)))
          .write(LoanInstallmentsCompanion(
        isPaid: const Value(true),
        paidAt: Value(when),
        paidAmount: Value(amount),
        paidWalletId: Value(walletId),
      ));

      final wallet =
          await (select(wallets)..where((w) => w.id.equals(walletId))).getSingle();
      await (update(wallets)..where((w) => w.id.equals(walletId))).write(
        WalletsCompanion(balance: Value(wallet.balance - amount)),
      );
    });
  }
}