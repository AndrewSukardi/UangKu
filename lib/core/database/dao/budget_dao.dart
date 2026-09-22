import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/finance_tables.dart';

part 'budget_dao.g.dart';

class BudgetProgress {
  final Budget budget;
  final double spent;

  BudgetProgress({required this.budget, required this.spent});

  double get remaining => budget.limitAmount - spent;

  double get percentUsed =>
      budget.limitAmount == 0 ? 0 : (spent / budget.limitAmount);
}

@DriftAccessor(tables: [Budgets, Transactions])
class BudgetDao extends DatabaseAccessor<AppDatabase> with _$BudgetDaoMixin {
  BudgetDao(super.db);

  Stream<List<Budget>> watchBudgetsForWallet(int walletId) {
    return (select(budgets)
          ..where(
              (b) => b.walletId.equals(walletId) & b.isActive.equals(true)))
        .watch();
  }

  Future<int> addBudget(BudgetsCompanion budget) => into(budgets).insert(budget);

  Future<bool> updateBudget(BudgetsCompanion budget) =>
      update(budgets).replace(budget);

  Future<int> deleteBudget(int id) =>
      (delete(budgets)..where((b) => b.id.equals(id))).go();

  /// Current period's [start, end) window for a budget, based on its type.
  (DateTime, DateTime) _currentPeriodRange(Budget budget) {
    final now = DateTime.now();
    switch (budget.period) {
      case BudgetPeriod.monthly:
        final day = budget.resetDay ?? 1;
        var start = DateTime(now.year, now.month, day);
        if (now.isBefore(start)) {
          start = DateTime(now.year, now.month - 1, day);
        }
        final end = DateTime(start.year, start.month + 1, start.day);
        return (start, end);

      case BudgetPeriod.weekly:
        final weekday = budget.resetDay ?? DateTime.monday;
        final diff = (now.weekday - weekday) % 7;
        final start = DateTime(now.year, now.month, now.day - diff);
        final end = start.add(const Duration(days: 7));
        return (start, end);

      case BudgetPeriod.custom:
        return (
          budget.startDate ?? DateTime(now.year, now.month, 1),
          budget.endDate ?? now.add(const Duration(days: 1)),
        );
    }
  }

  /// Live spent-vs-limit for a budget in its current period. Re-emits
  /// whenever a matching transaction is added, edited, or removed.
  Stream<BudgetProgress> watchBudgetProgress(Budget budget) {
    final (start, end) = _currentPeriodRange(budget);

    final query = select(transactions)
      ..where((t) =>
          t.walletId.equals(budget.walletId) &
          t.type.equalsValue(TransactionType.expense) &
          t.date.isBiggerOrEqualValue(start) &
          t.date.isSmallerThanValue(end));

    if (budget.categoryId != null) {
      query.where((t) => t.categoryId.equals(budget.categoryId!));
    }

    return query.watch().map((rows) {
      final spent = rows.fold<double>(0, (sum, t) => sum + t.amount);
      return BudgetProgress(budget: budget, spent: spent);
    });
  }
}