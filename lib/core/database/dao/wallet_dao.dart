import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/finance_tables.dart';

part 'wallet_dao.g.dart';

@DriftAccessor(tables: [Wallets])
class WalletDao extends DatabaseAccessor<AppDatabase> with _$WalletDaoMixin {
  WalletDao(super.db);

  Stream<List<Wallet>> watchAllWallets({bool includeArchived = false}) {
    final query = select(wallets);
    if (!includeArchived) {
      query.where((w) => w.isArchived.equals(false));
    }
    return query.watch();
  }

  Stream<Wallet> watchWallet(int id) {
    return (select(wallets)..where((w) => w.id.equals(id))).watchSingle();
  }

  Future<Wallet?> getWallet(int id) {
    return (select(wallets)..where((w) => w.id.equals(id))).getSingleOrNull();
  }

  Future<int> addWallet(WalletsCompanion wallet) {
    return into(wallets).insert(wallet);
  }

  Future<bool> updateWallet(WalletsCompanion wallet) {
    return update(wallets).replace(wallet);
  }

  Future<void> archiveWallet(int id) {
    return (update(wallets)..where((w) => w.id.equals(id))).write(
      const WalletsCompanion(isArchived: Value(true)),
    );
  }

  /// Adjusts balance by [delta] (positive = credit, negative = debit).
  /// Kept internal-ish — TransactionDao/LoanDao call this so balances stay
  /// in sync with the ledger; avoid calling it directly from UI code.
  Future<void> adjustBalance(int walletId, double delta) async {
    final wallet = await getWallet(walletId);
    if (wallet == null) return;
    await (update(wallets)..where((w) => w.id.equals(walletId))).write(
      WalletsCompanion(
        balance: Value(wallet.balance + delta),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// For credit cards: how much of the limit is still available.
  /// Returns null for non-credit-card wallets.
  Stream<double?> watchAvailableCredit(int walletId) {
    return watchWallet(walletId).map((w) {
      if (w.creditLimit == null) return null;
      return w.creditLimit! - w.balance;
    });
  }
}