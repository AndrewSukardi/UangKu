import 'package:UangKu/theme/theme_extensions.dart';
import 'package:flutter/material.dart';
import 'package:UangKu/utils/ui_helper.dart';
import 'package:UangKu/utils/router_icon.dart';
import 'package:intl/intl.dart';
import 'package:UangKu/features/form_data/transaction_form_data.dart';
import 'package:UangKu/utils/icon_assets.dart';

/// The shared "amount + type" page: a tab bar to pick Expense / Income /
/// Transfer, plus the entry view for whichever tab is active.
///
/// This is a [StatelessWidget] on purpose — all of its state (the amount,
/// the selected type) already lives in [formData], a ChangeNotifier. It
/// rebuilds itself via [AnimatedBuilder] whenever that data changes, so it
/// doesn't need (and shouldn't own) any local State.
class TransactionStep extends StatelessWidget {
  final TransactionFormData formData;

  const TransactionStep({super.key, required this.formData});

  static const List<String> _labels = ["Expense", "Income", "Transfer"];
  static const double _padding = 3;

  int get _activeIndex => TransactionType.values.indexOf(formData.type);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: formData,
      builder: (context, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTabBar(context),
            const SizedBox(height: 16),
            _buildActiveView(),
          ],
        );
      },
    );
  }

  Widget _buildActiveView() {
    switch (formData.type) {
      case TransactionType.expense:
        return TransactionEntryView(
          formData: formData,
          type: TransactionType.expense,
        );
      case TransactionType.income:
        return TransactionEntryView(
          formData: formData,
          type: TransactionType.income,
        );
      case TransactionType.transfer:
        return TransactionEntryView(
          formData: formData,
          type: TransactionType.transfer,
        );
    }
  }

  Widget _buildTabBar(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final innerWidth = constraints.maxWidth - (_padding * 2);
        final tabWidth = innerWidth / _labels.length;

        return Container(
          height: 44,
          padding: const EdgeInsets.all(_padding),
          decoration: BoxDecoration(
            color: context.extra.grayColor,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Stack(
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                left: tabWidth * _activeIndex,
                width: tabWidth,
                top: 0,
                bottom: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.onPrimary,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                children: List.generate(_labels.length, (index) {
                  return Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () =>
                          formData.setType(TransactionType.values[index]),
                      child: Center(
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 250),
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: context.colors.onSurface,
                          ),
                          child: Text(_labels[index]),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Amount entry + quick-add chips for Expense / Income. Stateless: the
/// amount lives in `formData.amount`, and NumberInputBox listens to that
/// notifier directly, so this widget never needs to rebuild on its own.
class TransactionEntryView extends StatelessWidget {
  final TransactionFormData formData;
  final TransactionType type;

  const TransactionEntryView({
    super.key,
    required this.formData,
    required this.type,
  });

  static const List<int> _quickValues = [
    1000,
    5000,
    10000,
    20000,
    50000,
    100000,
  ];

  Color _numberColor(BuildContext context) {
    switch (type) {
      case TransactionType.expense:
        return context.extra.error;
      case TransactionType.income:
        return context.extra.success;
      case TransactionType.transfer:
        return context.colors.secondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _numberColor(context);

    return Column(
      children: [
        NumberInputBox(
          label: "AMOUNT",
          numberColor: color,
          prefixColor: color,
          minValue: 0,
          maxValue: 10000000000000000,
          amountNotifier: formData.amount,
          backgroundColor: context.colors.secondaryContainer,
          labelColor: context.colors.onSurface,
          onChanged: (val) {},
        ),
        const SizedBox(height: 18),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "QUICK ADD",
            style: context.text.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: context.extra.grayText,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _quickValues.map((v) {
              return ActionChip(
                elevation: 3,
                shadowColor: context.colors.shadow.withValues(alpha: 0.2),
                backgroundColor: context.colors.secondaryContainer,
                padding: EdgeInsets.zero,
                labelPadding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 6,
                ),
                visualDensity: VisualDensity.compact,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: context.colors.secondaryContainer,
                    width: 1,
                  ),
                ),
                label: Text(
                  "+${NumberFormat.decimalPattern('id_ID').format(v)}",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: context.colors.onSurface,
                  ),
                ),
                onPressed: () => formData.amount.value += v,
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class TransferView extends StatelessWidget {
  const TransferView({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Text(
        "You'll choose the accounts on the next step.",
        textAlign: TextAlign.center,
        style: context.text.bodyMedium?.copyWith(color: context.extra.grayText),
      ),
    );
  }
}

class _CategoryOption {
  final String label; // sent to the form
  final String iconPath; // IconAssets.<name>.path

  const _CategoryOption({required this.label, required this.iconPath});
}

class CategoryStep extends StatelessWidget {
  final TransactionFormData formData;
  const CategoryStep({super.key, required this.formData});

  static final List<_CategoryOption> _expenseCategories = [
    _CategoryOption(label: 'Groceries', iconPath: IconAssets.cart.path),
    _CategoryOption(label: 'Food', iconPath: IconAssets.food.path),
    _CategoryOption(label: 'Transport', iconPath: IconAssets.transport.path),
    _CategoryOption(
      label: 'Entertainment',
      iconPath: IconAssets.clapperboard.path,
    ),
    _CategoryOption(label: 'Health', iconPath: IconAssets.medicalBag.path),
    _CategoryOption(label: 'Utilities', iconPath: IconAssets.utilities.path),
    _CategoryOption(label: 'Shopping', iconPath: IconAssets.box.path),
    _CategoryOption(label: 'Fitness', iconPath: IconAssets.fitness.path),
    _CategoryOption(label: 'Education', iconPath: IconAssets.book.path),
    _CategoryOption(label: 'Travel', iconPath: IconAssets.plane.path),
    _CategoryOption(label: 'Giving', iconPath: IconAssets.moneyHand.path),
    _CategoryOption(label: 'Other', iconPath: IconAssets.other.path),
  ];

  static final List<_CategoryOption> _incomeCategories = [
    _CategoryOption(label: 'Salary', iconPath: IconAssets.briefcase.path),
    _CategoryOption(label: 'Bonus', iconPath: IconAssets.moneyBag.path),
    _CategoryOption(label: 'Gift', iconPath: IconAssets.gift.path),
    _CategoryOption(
      label: 'Investment',
      iconPath: IconAssets.increaseChart.path,
    ),
    _CategoryOption(label: 'Freelance', iconPath: IconAssets.money.path),
    _CategoryOption(label: 'Other', iconPath: IconAssets.other.path),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: context.extra.error.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: context.extra.error, // Adjust opacity as needed
              width: 1, // Border thickness
            ),
            boxShadow: [
              BoxShadow(
                color: context.colors.shadow.withValues(alpha: 0.05),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Expenses Category",
                style: context.text.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 2),
              Text("What did you spend on ?", style: context.text.bodySmall),
            ],
          ),
        ),
        const SizedBox(height: 12), // Changed from width to height
        AnimatedBuilder(
          animation: formData,
          builder: (context, _) {
            final categories = formData.type == TransactionType.income
                ? _incomeCategories
                : _expenseCategories;

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              itemCount: categories.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 50 / 35,
              ),
              itemBuilder: (context, index) {
                final option = categories[index];
                final selected = formData.category == option.label;

                return GestureDetector(
                  onTap: () {
                    formData.category = option.label;
                    formData.notifyListeners();
                  },
                  child: RouterIconText(
                    assetPath: option.iconPath,
                    background: context.colors.secondaryContainer,
                    label: option.label,
                    selected: selected,
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}
