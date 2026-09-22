import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/finance_tables.dart';

part 'wallet_dao.g.dart';

/// Every combination of filters you might want on the wallet list.
/// All fields are optional — leave one null/empty to not filter by it.
///
/// Add a new field here whenever you need a new filterable condition;
/// you never need a new DAO method for it.
class WalletFilter {
  final List<WalletType>? types;
  final bool? isArchived; // null = both archived and active
  final String? nameContains; // case-insensitive substring match
  final double? minBalance;
  final double? maxBalance;
  final bool? hasCreditLimit; // true = credit cards only, false = non-credit

  const WalletFilter({
    this.types,
    this.isArchived = false, // default: hide archived, like your old method
    this.nameContains,
    this.minBalance,
    this.maxBalance,
    this.hasCreditLimit,
  });

  /// Copy with a few fields changed — handy for building up a filter as the
  /// user taps chips, e.g. `filter = filter.copyWith(types: [selected])`.
  WalletFilter copyWith({
    List<WalletType>? types,
    bool? isArchived,
    String? nameContains,
    double? minBalance,
    double? maxBalance,
    bool? hasCreditLimit,
  }) {
    return WalletFilter(
      types: types ?? this.types,
      isArchived: isArchived ?? this.isArchived,
      nameContains: nameContains ?? this.nameContains,
      minBalance: minBalance ?? this.minBalance,
      maxBalance: maxBalance ?? this.maxBalance,
      hasCreditLimit: hasCreditLimit ?? this.hasCreditLimit,
    );
  }

  static const none = WalletFilter(isArchived: null); // everything, no filter
}

@DriftAccessor(tables: [Wallets])
class WalletDao extends DatabaseAccessor<AppDatabase> with _$WalletDaoMixin {
  WalletDao(super.db);

  /// One query method for every filter combination. Build the `where`
  /// clause from whichever fields on [filter] are set; leave the rest out.
  SimpleSelectStatement<Wallets, Wallet> _filtered(WalletFilter filter) {
    final query = select(wallets);

    query.where((w) {
      Expression<bool> condition = const Constant(true);

      if (filter.isArchived != null) {
        condition = condition & w.isArchived.equals(filter.isArchived!);
      }
      if (filter.types != null && filter.types!.isNotEmpty) {
        condition = condition & w.type.isInValues(filter.types!);
      }
      if (filter.nameContains != null && filter.nameContains!.isNotEmpty) {
        condition = condition & w.name.lower().contains(
              filter.nameContains!.toLowerCase(),
            );
      }
      if (filter.minBalance != null) {
        condition = condition & w.balance.isBiggerOrEqualValue(filter.minBalance!);
      }
      if (filter.maxBalance != null) {
        condition = condition & w.balance.isSmallerOrEqualValue(filter.maxBalance!);
      }
      if (filter.hasCreditLimit != null) {
        condition = filter.hasCreditLimit!
            ? condition & w.creditLimit.isNotNull()
            : condition & w.creditLimit.isNull();
      }

      return condition;
    });

    return query;
  }

  /// Live list for any filter, e.g.:
  ///   watchWallets(const WalletFilter(types: [WalletType.creditCard]))
  ///   watchWallets(WalletFilter(nameContains: 'BCA', isArchived: false))
  Stream<List<Wallet>> watchWallets([WalletFilter filter = const WalletFilter()]) {
    return _filtered(filter).watch();
  }

  /// One-shot version of the same thing.
  Future<List<Wallet>> getWallets([WalletFilter filter = const WalletFilter()]) {
    return _filtered(filter).get();
  }

  // ── Kept as convenience wrappers so existing call sites don't break ────

  /// Equivalent to `watchWallets(WalletFilter(isArchived: includeArchived ? null : false))`.
  Stream<List<Wallet>> watchAllWallets({bool includeArchived = false}) {
    return watchWallets(WalletFilter(isArchived: includeArchived ? null : false));
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