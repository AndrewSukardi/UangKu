import 'package:UangKu/theme/theme_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:UangKu/features/sheet/step_sheet.dart';
import 'package:UangKu/features/form_data/transaction_form_data.dart';
import 'package:UangKu/utils/icon_assets.dart';
import 'package:UangKu/features/sheet/trasanction_sheet.dart';
import 'package:UangKu/utils/router_icon.dart';

import 'package:UangKu/core/providers/database_providers.dart'; // walletDaoProvider
import 'package:UangKu/features/form_data/wallet_form_data.dart';
import 'package:UangKu/features/sheet/wallet_sheet.dart';

enum AddType { transaction, budget, credit }

class AddItem {
  final String title;
  final AddType type;
  final Widget leading;
  final String subtitle;
  const AddItem(this.title, this.type, this.leading, this.subtitle);
}

class ActionSheet extends ConsumerStatefulWidget {
  final bool isRouter;
  final String titleRouter;
  final AddType? type;

  const ActionSheet({
    super.key,
    required this.isRouter,
    this.titleRouter = '',
    this.type,
  });

  @override
  ConsumerState<ActionSheet> createState() => _ActionSheetState();
}

class _ActionSheetState extends ConsumerState<ActionSheet> {
  int currentStep = 0;

  bool _saving = false;

  // Created lazily so the router page (isRouter: true) never allocates a
  // form it doesn't need.
  TransactionFormData? _formData;
  TransactionFormData get formData => _formData ??= TransactionFormData();

  WalletFormData? _walletFormData;
  WalletFormData get walletForm => _walletFormData ??= WalletFormData();

  Listenable get _activeForm =>
      widget.type == AddType.credit ? walletForm : formData;

  @override
  void dispose() {
    _formData?.dispose();
    _walletFormData?.dispose();
    super.dispose();
  }

  List<ActionSheetStep> get _transactionSteps {
    return formData.steps.map((step) {
      switch (step) {
        case TxStep.amountType:
          return ActionSheetStep(
            title: "Amount & type",
            content: TransactionStep(formData: formData),
            isValid: () => formData.isStepValid(TxStep.amountType),
          );
        case TxStep.category:
          return ActionSheetStep(
            title: "Category",
            content: CategoryStep(formData: formData),
            isValid: () => formData.isStepValid(TxStep.category),
          );
        case TxStep.details:
          return ActionSheetStep(
            title: "Details",
            content: DetailsStep(formData: formData),
            isValid: () => formData.isStepValid(TxStep.details),
          );
        case TxStep.transferDetails:
          return ActionSheetStep(
            title: "Transfer",
            content: TransferDetailsStep(formData: formData),
            isValid: () => formData.isStepValid(TxStep.transferDetails),
          );
        case TxStep.confirmation:
          return ActionSheetStep(
            title: "Confirmation",
            content: ConfirmationStep(formData: formData),
            isValid: () => formData.isStepValid(TxStep.confirmation),
          );
      }
    }).toList();
  }

  List<ActionSheetStep> get _walletSteps {
    return walletForm.steps.map((step) {
      switch (step) {
        case WalletStep.details:
          return ActionSheetStep(
            title: "Wallet details",
            content: WalletDetailsStep(formData: walletForm),
            isValid: () => walletForm.isStepValid(WalletStep.details),
          );
        case WalletStep.billing:
          return ActionSheetStep(
            title: "Billing cycle",
            content: WalletBillingStep(formData: walletForm),
            isValid: () => walletForm.isStepValid(WalletStep.billing),
          );
        case WalletStep.confirmation:
          return ActionSheetStep(
            title: "Confirmation",
            content: WalletConfirmationStep(formData: walletForm),
            isValid: () => walletForm.isStepValid(WalletStep.confirmation),
          );
      }
    }).toList();
  }

  // Budget / credit don't have dedicated form data yet — placeholder flow
  // so the sheet still opens and doesn't crash.
  // TODO: replace with real BudgetFormData / CreditFormData-backed steps.
  static const _placeholderSteps = [
    ActionSheetStep(
      title: "Details",
      content: PlaceholderStep(label: "Name"),
    ),
    ActionSheetStep(
      title: "Confirm",
      content: PlaceholderStep(label: "Confirm"),
    ),
  ];

  List<ActionSheetStep> get steps {
    switch (widget.type) {
      case AddType.transaction:
        return _transactionSteps;
      case AddType.budget:
        return _placeholderSteps;
      case AddType.credit:
        return _walletSteps;
      default:
        return const [];
    }
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      if (widget.type == AddType.credit) {
        final companion = walletForm.toCompanion();
        debugPrint('Saving wallet: $companion');
        final id = await ref.read(walletDaoProvider).addWallet(companion);
        debugPrint('Inserted wallet id: $id');
      }
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e, st) {
      debugPrint('Save failed: $e\n$st');
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not save: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.isRouter ? _buildRouter() : _buildSteps();
  }

  Widget _buildRouter() {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    final items = [
      AddItem(
        "Add Transaction",
        AddType.transaction,
        RouterIcon(
          assetPath: IconAssets.transaction.path,
          background: Colors.green.shade50,
        ),
        "Record an expense or income",
      ),
      AddItem(
        "Set New Budget",
        AddType.budget,
        RouterIcon(
          assetPath: IconAssets.budget.path,
          background: Colors.blue.shade50,
        ),
        "Create a category spending limit",
      ),
      AddItem(
        "Add Credit / Loan",
        AddType.credit,
        RouterIcon(
          assetPath: IconAssets.creditCard.path,
          background: Colors.amber.shade50,
        ),
        "Track a new card, debt, or bill",
      ),
    ];

    return AnimatedPadding(
      duration: const Duration(milliseconds: 200),
      padding: EdgeInsets.only(bottom: keyboardHeight),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 75,
                height: 3,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
              const SizedBox(height: 6),
              const StepHeader(
                title: "Quick Add",
                subtitle: "What would you like to do ?",
                showCloseButton: false,
                showIndicatorStep: false,
              ),
              const SizedBox(height: 12),
              ...items.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: item.leading,
                    title: Text(
                      item.title,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      item.subtitle,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    horizontalTitleGap: 8,
                    titleTextStyle: Theme.of(context).textTheme.labelMedium,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.grey.shade300, width: 2),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        builder: (_) => ActionSheet(
                          isRouter: false,
                          titleRouter: item.title,
                          type: item.type,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSteps() {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    // Rebuilds whenever the form data changes, so the Next/Save button's
    // enabled state always reflects the current step's validity.
    return AnimatedBuilder(
      animation: _activeForm,
      builder: (context, _) {
        final currentSteps = steps;
        if (currentSteps.isEmpty) return const SizedBox.shrink();
        if (currentStep >= currentSteps.length)
          currentStep = currentSteps.length - 1;

        final isLastStep = currentStep == currentSteps.length - 1;
        final canProceed = currentSteps[currentStep].isValid?.call() ?? true;

        return AnimatedPadding(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.only(bottom: keyboardHeight),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 75,
                    height: 3,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                  StepHeader(
                    title: widget.titleRouter,
                    subtitle: currentSteps[currentStep].title,
                    currentStep: currentStep,
                    totalSteps: currentSteps.length,
                    activeColor: context.colors.primary,
                    showCloseButton: false,
                  ),
                  const SizedBox(height: 24),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: KeyedSubtree(
                      key: ValueKey(currentStep),
                      child: currentSteps[currentStep].content,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: ElevatedButton(
                          onPressed: () {
                            if (currentStep > 0) {
                              setState(() => currentStep--);
                            } else {
                              Navigator.pop(context);
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                builder: (_) =>
                                    const ActionSheet(isRouter: true),
                              );
                            }
                          },
                          child: Text(
                            currentStep > 0 ? "Back" : "Change",
                            style: context.text.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: canProceed
                                ? context.colors.primary
                                : context.extra.grayColor,
                            foregroundColor: canProceed
                                ? Colors.black
                                : Colors.grey.shade300,
                          ),
                          onPressed: !canProceed
                              ? null
                              : () {
                                  FocusScope.of(context).unfocus();
                                  if (!isLastStep) {
                                    setState(() => currentStep++);
                                  } else {
                                    _save();
                                  }
                                },
                          child: Text(
                            isLastStep ? "Save" : "Next",
                            style: context.text.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
