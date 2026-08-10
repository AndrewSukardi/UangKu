import 'package:UangKu/theme/theme_extensions.dart';
import 'package:flutter/material.dart';
import 'package:UangKu/utils/ui_helper.dart';
import 'package:intl/intl.dart';
import 'package:UangKu/features/form_data/transaction_form_data.dart';

enum TrasanctionFlowType { expense, income }

class TransactionStep extends StatefulWidget {

  final TransactionFormData formData;

  const TransactionStep({super.key, required this.formData});

  @override
  State<TransactionStep> createState() => _TransactionStepState();
}

class _TransactionStepState extends State<TransactionStep> {

  final List<String> _labels = ["Expense", "Income", "Transfer"];

  

  static const double _padding = 3;
  int get _activeIndex => TransactionType.values.indexOf(widget.formData.type);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildTabBar(context), // <- your existing LayoutBuilder/Stack code
        const SizedBox(height: 16),
        _buildActiveView(_activeIndex, widget.formData),
      ],
    );
  }

  Widget _buildActiveView(int index, TransactionFormData formData) {
    switch (index) {
      case 0:
        return TransactionEntryView(formData: formData, type: TrasanctionFlowType.expense);
      case 1:
        return TransactionEntryView(formData: formData, type: TrasanctionFlowType.income);
      case 2:
        return TransferView();
      default:
        return const SizedBox.shrink();
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
          // color: Colors.black,
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
                      onTap: () => setState(() => widget.formData.setType(TransactionType.values[index])),
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

class TransactionEntryView  extends StatefulWidget {

  final TransactionFormData formData;
  final TrasanctionFlowType type;
  const TransactionEntryView({super.key, required this.formData, required this.type});

  @override
  State<TransactionEntryView> createState() => _ExpenseViewState();
}

class _ExpenseViewState extends State<TransactionEntryView> {
  final ValueNotifier<int> _amount = ValueNotifier<int>(0);
  final List<int> _quickValues = [1000, 5000, 10000, 20000, 50000, 100000];

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  Color get _numberColor {
    switch (widget.type) {
      case TrasanctionFlowType.expense:
        return context.extra.error;
      case TrasanctionFlowType.income:
        return context.extra.success;
    }
  }


  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        NumberInputBox(
          label: "AMOUNT",
          numberColor: _numberColor,
          prefixColor: _numberColor,
          minValue: 0,
          maxValue: 10000000000000000,
          amountNotifier: widget.formData.amount, // <-- shared controller
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
          alignment: AlignmentGeometry.centerLeft,
          child: Wrap(
            spacing: 8,
            runSpacing: 8,

            children: _quickValues.map((v) {
              return ActionChip(
                elevation: 3,
                shadowColor: Colors.black.withValues(alpha: 0.2),
                backgroundColor: Colors.white,
                padding: EdgeInsets.zero, // <-- remove chip's own padding
                labelPadding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 6,
                ), // <-- control spacing directly
                visualDensity:
                    VisualDensity.compact, // <-- avoid inherited density skew
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: Colors.grey.shade300, width: 1),
                ),
                label: Text(
                  "+${NumberFormat.decimalPattern('id_ID').format(v)}",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                ),
                onPressed: () {
                  widget.formData.amount.value += v;
                },
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
    return const Text("Transfer View");
  }
}
