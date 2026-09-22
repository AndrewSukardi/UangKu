import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/finance_tables.dart';

part 'transaction_dao.g.dart';

@DriftAccessor(tables: [Transactions, Wallets])
class TransactionDao extends DatabaseAccessor<AppDatabase>
    with _$TransactionDaoMixin {
  TransactionDao(super.db);

  Stream<List<WalletTransaction>> watchForWallet(int walletId, {int limit = 100}) {
    return (select(transactions)
          ..where((t) => t.walletId.equals(walletId))
          ..orderBy([(t) => OrderingTerm.desc(t.date)])
          ..limit(limit))
        .watch();
  }

  /// Adds a transaction and keeps wallet balance(s) in sync. Atomic.
  Future<int> addTransaction(TransactionsCompanion txn) {
    return transaction(() async {
      final id = await into(transactions).insert(txn);
      await _applyBalanceChange(txn, reverse: false);
      return id;
    });
  }

  /// Deletes a transaction and reverses its effect on wallet balance(s).
  Future<void> deleteTransaction(int id) {
    return transaction(() async {
      final txn =
          await (select(transactions)..where((t) => t.id.equals(id))).getSingle();
      await (delete(transactions)..where((t) => t.id.equals(id))).go();

      await _applyBalanceChange(
        TransactionsCompanion.insert(
          walletId: txn.walletId,
          type: txn.type,
          amount: txn.amount,
          date: txn.date,
          transferToWalletId: Value(txn.transferToWalletId),
        ),
        reverse: true,
      );
    });
  }

  Future<void> _applyBalanceChange(
    TransactionsCompanion txn, {
    required bool reverse,
  }) async {
    final sign = reverse ? -1 : 1;
    final walletId = txn.walletId.value;
    final amount = txn.amount.value;

    switch (txn.type.value) {
      case TransactionType.income:
        await _adjust(walletId, amount * sign);
        break;
      case TransactionType.expense:
        await _adjust(walletId, -amount * sign);
        break;
      case TransactionType.transfer:
        await _adjust(walletId, -amount * sign);
        final toId = txn.transferToWalletId.value;
        if (toId != null) await _adjust(toId, amount * sign);
        break;
    }
  }

  Future<void> _adjust(int walletId, double delta) async {
    final wallet =
        await (select(wallets)..where((w) => w.id.equals(walletId))).getSingle();
    await (update(wallets)..where((w) => w.id.equals(walletId)))
        .write(WalletsCompanion(balance: Value(wallet.balance + delta)));
  }
}