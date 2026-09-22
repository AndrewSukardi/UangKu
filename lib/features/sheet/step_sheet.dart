import 'package:UangKu/theme/theme_extensions.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:UangKu/features/form_data/transaction_form_data.dart';

/// A single page inside [ActionSheet]'s wizard.
class ActionSheetStep {
  final String title;
  final Widget content;

  /// Whether the wizard is allowed to move past this step. Defaults to
  /// always-valid for steps that don't need it (e.g. confirmation).
  final bool Function()? isValid;

  const ActionSheetStep({
    required this.title,
    required this.content,
    this.isValid,
  });
}

/// Header shown at the top of every ActionSheet page: a title, a subtitle,
/// and — for wizard pages — a row of step-progress bars.
class StepHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final int currentStep;
  final int totalSteps;
  final Color? activeColor;
  final bool showCloseButton;
  final bool showIndicatorStep;

  const StepHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.currentStep = 0,
    this.totalSteps = 1,
    this.activeColor,
    this.showCloseButton = true,
    this.showIndicatorStep = true,
  });

  @override
  Widget build(BuildContext context) {
    final active = activeColor ?? context.colors.primary;
    final inactive = context.extra.grayColor;
    final subtitle_color = context.extra.grayText;
    // final inactive = Colors.black;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            // Title
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.text.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // Step indicator
            if (showIndicatorStep && totalSteps > 1) ...[
              const SizedBox(width: 12),
              _StepIndicator(
                currentStep: currentStep,
                totalSteps: totalSteps,
                activeColor: active,
                inactiveColor: inactive,
              ),
            ],

            // Close button
            if (showCloseButton)
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
          ],
        ),

        const SizedBox(height: 2),

        Text(
          subtitle,
          style: context.text.bodySmall?.copyWith(
            color: subtitle_color,
          ),
        ),
      ],
    );
  }
}

class _StepIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final Color activeColor;
  final Color inactiveColor;

  const _StepIndicator({
    required this.currentStep,
    required this.totalSteps,
    required this.activeColor,
    required this.inactiveColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(totalSteps, (index) {
        final isCurrent = index == currentStep;
        // final isCompleted = index < currentStep;
        // final isActive = isCurrent || isCompleted; // for showing color to previous step
        final isActive = isCurrent; // only active 

        return Padding(
          padding: EdgeInsets.only(right: index != totalSteps - 1 ? 4 : 0),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            width: isCurrent ? 24 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: isActive ? activeColor : inactiveColor,
              borderRadius: BorderRadius.circular(100),
            ),
          ),
        );
      }),
    );
  }
}


/// Simple placeholder page for flows (budget, credit) that don't have
/// dedicated form data yet. Swap these out once those flows are built.
class PlaceholderStep extends StatelessWidget {
  final String label;
  const PlaceholderStep({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return TextField(decoration: InputDecoration(labelText: label));
  }
}



/// Optional note field, shared by the Expense / Income flows.
class DetailsStep extends StatefulWidget {
  final TransactionFormData formData;
  const DetailsStep({super.key, required this.formData});

  @override
  State<DetailsStep> createState() => _DetailsStepState();
}

class _DetailsStepState extends State<DetailsStep> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.formData.note);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      maxLines: 3,
      decoration: const InputDecoration(
        labelText: 'Note (optional)',
        border: OutlineInputBorder(),
      ),
      onChanged: (val) => widget.formData.note = val,
    );
  }
}


/// From / to account picker for the Transfer flow.
class TransferDetailsStep extends StatelessWidget {
  final TransactionFormData formData;
  const TransferDetailsStep({super.key, required this.formData});

  // TODO: replace with real accounts pulled from the wallet repository.
  static const _accounts = ['Cash', 'Bank BCA', 'Bank Mandiri', 'E-Wallet'];

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: formData,
      builder: (context, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<String>(
              initialValue: formData.fromAccount,
              decoration: const InputDecoration(labelText: 'From'),
              items: _accounts
                  .map((a) => DropdownMenuItem(value: a, child: Text(a)))
                  .toList(),
              onChanged: (val) {
                formData.fromAccount = val;
                formData.notifyListeners();
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: formData.toAccount,
              decoration: const InputDecoration(labelText: 'To'),
              items: _accounts
                  .where((a) => a != formData.fromAccount)
                  .map((a) => DropdownMenuItem(value: a, child: Text(a)))
                  .toList(),
              onChanged: (val) {
                formData.toAccount = val;
                formData.notifyListeners();
              },
            ),
          ],
        );
      },
    );
  }
}

/// Final review page shown before saving.
class ConfirmationStep extends StatelessWidget {
  final TransactionFormData formData;
  const ConfirmationStep({super.key, required this.formData});

  @override
  Widget build(BuildContext context) {
    final currency =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return AnimatedBuilder(
      animation: formData,
      builder: (context, _) {
        final rows = <MapEntry<String, String>>[
          MapEntry('Type', formData.type.name),
          MapEntry('Amount', currency.format(formData.amount.value)),
          if (formData.type != TransactionType.transfer) ...[
            MapEntry('Category', formData.category ?? '-'),
            MapEntry(
                'Note', (formData.note?.isNotEmpty ?? false) ? formData.note! : '-'),
          ] else ...[
            MapEntry('From', formData.fromAccount ?? '-'),
            MapEntry('To', formData.toAccount ?? '-'),
          ],
        ];

        return Column(
          children: rows
              .map(
                (r) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        r.key,
                        style: context.text.bodyMedium
                            ?.copyWith(color: context.extra.grayText),
                      ),
                      Text(
                        r.value,
                        style: context.text.bodyMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        );
      },
    );
  }
}