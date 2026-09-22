import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'tables/finance_tables.dart';
import 'dao/wallet_dao.dart';
import 'dao/budget_dao.dart';
import 'dao/loan_dao.dart';
import 'dao/transaction_dao.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [Wallets, Categories, Transactions, Budgets, Loans, LoanInstallments],
  daos: [WalletDao, BudgetDao, LoanDao, TransactionDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // UPDATE DATABASE WIHOUT LOSING DATA, DONT FORGET INCEMERE SCHEMA VERSION
  // @override
  // MigrationStrategy get migration => MigrationStrategy(
  //   onCreate: (m) => m.createAll(),
  //   onUpgrade: (m, from, to) async {
  //     if (from < 2) {
  //       await m.addColumn(wallets, wallets.lastFour);
  //     }
  //   },
  // );

  static QueryExecutor _openConnection() {
    // drift_flutter picks the right backend (native/web) and stores the
    // db file in the app's own documents directory automatically.
    return driftDatabase(name: 'finance_app_db');
  }
}
