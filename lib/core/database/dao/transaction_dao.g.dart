// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_dao.dart';

// ignore_for_file: type=lint
mixin _$TransactionDaoMixin on DatabaseAccessor<AppDatabase> {
  $WalletsTable get wallets => attachedDatabase.wallets;
  $CategoriesTable get categories => attachedDatabase.categories;
  $LoansTable get loans => attachedDatabase.loans;
  $LoanInstallmentsTable get loanInstallments =>
      attachedDatabase.loanInstallments;
  $TransactionsTable get transactions => attachedDatabase.transactions;
  TransactionDaoManager get managers => TransactionDaoManager(this);
}

class TransactionDaoManager {
  final _$TransactionDaoMixin _db;
  TransactionDaoManager(this._db);
  $$WalletsTableTableManager get wallets =>
      $$WalletsTableTableManager(_db.attachedDatabase, _db.wallets);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db.attachedDatabase, _db.categories);
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
