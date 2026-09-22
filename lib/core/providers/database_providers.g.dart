// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(appDatabase)
final appDatabaseProvider = AppDatabaseProvider._();

final class AppDatabaseProvider
    extends $FunctionalProvider<AppDatabase, AppDatabase, AppDatabase>
    with $Provider<AppDatabase> {
  AppDatabaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appDatabaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appDatabaseHash();

  @$internal
  @override
  $ProviderElement<AppDatabase> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AppDatabase create(Ref ref) {
    return appDatabase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppDatabase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppDatabase>(value),
    );
  }
}

String _$appDatabaseHash() => r'59cce38d45eeaba199eddd097d8e149d66f9f3e1';

@ProviderFor(walletDao)
final walletDaoProvider = WalletDaoProvider._();

final class WalletDaoProvider
    extends $FunctionalProvider<WalletDao, WalletDao, WalletDao>
    with $Provider<WalletDao> {
  WalletDaoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'walletDaoProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$walletDaoHash();

  @$internal
  @override
  $ProviderElement<WalletDao> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  WalletDao create(Ref ref) {
    return walletDao(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WalletDao value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WalletDao>(value),
    );
  }
}

String _$walletDaoHash() => r'35f6b9850a0d33862d96390646dd53249f6a5f7e';

@ProviderFor(budgetDao)
final budgetDaoProvider = BudgetDaoProvider._();

final class BudgetDaoProvider
    extends $FunctionalProvider<BudgetDao, BudgetDao, BudgetDao>
    with $Provider<BudgetDao> {
  BudgetDaoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'budgetDaoProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$budgetDaoHash();

  @$internal
  @override
  $ProviderElement<BudgetDao> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  BudgetDao create(Ref ref) {
    return budgetDao(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BudgetDao value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BudgetDao>(value),
    );
  }
}

String _$budgetDaoHash() => r'ba014a23588469e48d0bbbb8bdff39c5a0fef6f4';

@ProviderFor(loanDao)
final loanDaoProvider = LoanDaoProvider._();

final class LoanDaoProvider
    extends $FunctionalProvider<LoanDao, LoanDao, LoanDao>
    with $Provider<LoanDao> {
  LoanDaoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'loanDaoProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$loanDaoHash();

  @$internal
  @override
  $ProviderElement<LoanDao> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  LoanDao create(Ref ref) {
    return loanDao(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LoanDao value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LoanDao>(value),
    );
  }
}

String _$loanDaoHash() => r'ef1068933b3720026eb0fa9538db5073027807fd';

@ProviderFor(transactionDao)
final transactionDaoProvider = TransactionDaoProvider._();

final class TransactionDaoProvider
    extends $FunctionalProvider<TransactionDao, TransactionDao, TransactionDao>
    with $Provider<TransactionDao> {
  TransactionDaoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'transactionDaoProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$transactionDaoHash();

  @$internal
  @override
  $ProviderElement<TransactionDao> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  TransactionDao create(Ref ref) {
    return transactionDao(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TransactionDao value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TransactionDao>(value),
    );
  }
}

String _$transactionDaoHash() => r'8636e91b875810a51b686e241d0b5f52cffac850';
