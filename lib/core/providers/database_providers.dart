import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../database/app_database.dart';
import '../database/tables/finance_tables.dart';
import '../database/dao/budget_dao.dart';
import '../database/dao/loan_dao.dart';
import '../database/dao/transaction_dao.dart';
import '../database/dao/wallet_dao.dart';

part 'database_providers.g.dart';

// ---------------------------------------------------------------------------
// Core: the database instance, kept alive for the app's lifetime.
// Still code-generated — this one builds fine.
// ---------------------------------------------------------------------------

@Riverpod(keepAlive: true)
AppDatabase appDatabase(Ref ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
}

// ---------------------------------------------------------------------------
// DAOs — also fine with code generation, since they don't return
// Stream<List<GeneratedClass>> directly.
// ---------------------------------------------------------------------------

@Riverpod(keepAlive: true)
WalletDao walletDao(Ref ref) => ref.watch(appDatabaseProvider).walletDao;

@Riverpod(keepAlive: true)
BudgetDao budgetDao(Ref ref) => ref.watch(appDatabaseProvider).budgetDao;

@Riverpod(keepAlive: true)
LoanDao loanDao(Ref ref) => ref.watch(appDatabaseProvider).loanDao;

@Riverpod(keepAlive: true)
TransactionDao transactionDao(Ref ref) =>
    ref.watch(appDatabaseProvider).transactionDao;

// ---------------------------------------------------------------------------
// Ready-made streams for the UI.
//
// Hand-written (classic) providers, NOT @riverpod-generated — this avoids a
// known riverpod_generator bug where @riverpod functions returning
// Stream<List<SomeGeneratedClass>> (Drift row classes included) fail with
// "InvalidTypeException: The type is invalid and cannot be converted to
// code." See https://github.com/rrousselGit/riverpod/issues/4370 and
// https://github.com/rrousselGit/riverpod/issues/4363.
//
// Usage in a widget is identical either way:
//   final wallets = ref.watch(allWalletsProvider);
//   wallets.when(data: ..., loading: ..., error: ...);
// ---------------------------------------------------------------------------

final allWalletsProvider = StreamProvider<List<Wallet>>((ref) {
  return ref.watch(walletDaoProvider).watchAllWallets();
});

final allLoansProvider = StreamProvider<List<Loan>>((ref) {
  return ref.watch(loanDaoProvider).watchAllLoans();
});

final upcomingInstallmentsProvider =
    StreamProvider.family<List<LoanInstallment>, int>((ref, days) {
  return ref.watch(loanDaoProvider).watchUpcoming(days: days);
});

final walletBudgetsProvider =
    StreamProvider.family<List<Budget>, int>((ref, walletId) {
  return ref.watch(budgetDaoProvider).watchBudgetsForWallet(walletId);
});

final budgetProgressProvider =
    StreamProvider.family<BudgetProgress, int>((ref, budgetId) async* {
  final dao = ref.watch(budgetDaoProvider);
  final budget = await (dao.select(dao.budgets)
        ..where((b) => b.id.equals(budgetId)))
      .getSingle();
  yield* dao.watchBudgetProgress(budget);
});

final walletTransactionsProvider =
    StreamProvider.family<List<WalletTransaction>, int>((ref, walletId) {
  return ref.watch(transactionDaoProvider).watchForWallet(walletId);
});