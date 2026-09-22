// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'loan_dao.dart';

// ignore_for_file: type=lint
mixin _$LoanDaoMixin on DatabaseAccessor<AppDatabase> {
  $WalletsTable get wallets => attachedDatabase.wallets;
  $LoansTable get loans => attachedDatabase.loans;
  $LoanInstallmentsTable get loanInstallments =>
      attachedDatabase.loanInstallments;
  $CategoriesTable get categories => attachedDatabase.categories;
  $TransactionsTable get transactions => attachedDatabase.transactions;
  LoanDaoManager get managers => LoanDaoManager(this);
}

class LoanDaoManager {
  final _$LoanDaoMixin _db;
  LoanDaoManager(this._db);
  $$WalletsTableTableManager get wallets =>
      $$WalletsTableTableManager(_db.attachedDatabase, _db.wallets);
  $$LoansTableTableManager get loans =>
      $$LoansTableTableManager(_db.attachedDatabase, _db.loans);
  $$LoanInstallmentsTableTableManager get loanInstallments =>
      $$LoanInstallmentsTableTableManager(
        _db.attachedDatabase,
        _db.loanInstallments,
      );
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db.attachedDatabase, _db.categories);
  $$TransactionsTableTableManager get transactions =>
      $$TransactionsTableTableManager(_db.attachedDatabase, _db.transactions);
}
