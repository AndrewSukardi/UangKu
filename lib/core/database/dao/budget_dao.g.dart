// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'budget_dao.dart';

// ignore_for_file: type=lint
mixin _$BudgetDaoMixin on DatabaseAccessor<AppDatabase> {
  $WalletsTable get wallets => attachedDatabase.wallets;
  $CategoriesTable get categories => attachedDatabase.categories;
  $BudgetsTable get budgets => attachedDatabase.budgets;
  $LoansTable get loans => attachedDatabase.loans;
  $LoanInstallmentsTable get loanInstallments =>
      attachedDatabase.loanInstallments;
  $TransactionsTable get transactions => attachedDatabase.transactions;
  BudgetDaoManager get managers => BudgetDaoManager(this);
}

class BudgetDaoManager {
  final _$BudgetDaoMixin _db;
  BudgetDaoManager(this._db);
  $$WalletsTableTableManager get wallets =>
      $$WalletsTableTableManager(_db.attachedDatabase, _db.wallets);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db.attachedDatabase, _db.categories);
  $$BudgetsTableTableManager get budgets =>
      $$BudgetsTableTableManager(_db.attachedDatabase, _db.budgets);
  $$LoansTableTableManager get loans =>
      $$LoansTableTableManager(_db.attachedDatabase, _db.loans);
  $$LoanInstallmentsTableTableManager get loanInstallments =>
      $$LoanInstallmentsTableTableManager(
        _db.attachedDatabase,
        _db.loanInstallments,
      );
  $$TransactionsTableTableManager get transactions =>
      $$TransactionsTableTableManager(_db.attachedDatabase, _db.transactions);
}
