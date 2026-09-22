import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:UangKu/theme/theme_extensions.dart';
import 'package:UangKu/widgets/app_field.dart'; // adjust to where you save app_field.dart
import 'package:UangKu/features/form_data/wallet_form_data.dart';

final NumberFormat _rupiah = NumberFormat.currency(
  locale: 'id_ID',
  symbol: 'Rp ',
  decimalDigits: 0,
);

// ════════════════════════════════════════════════════════════════════════
// STEP 1 — tab bar (Cash | Debit | Credit Card) + fields for that type
// ════════════════════════════════════════════════════════════════════════

class WalletDetailsStep extends StatelessWidget {
  final WalletFormData formData;

  const WalletDetailsStep({super.key, required this.formData});

  static const List<String> _labels = ["Cash", "Debit", "Credit Card"];
  static const double _padding = 3;

  int get _activeIndex => WalletFormData.tabTypes.indexOf(formData.type);

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
            const SizedBox(height: 20),
            _WalletDetailsView(formData: formData),
          ],
        );
      },
    );
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
                          formData.setType(WalletFormData.tabTypes[index]),
                      child: Center(
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 250),
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: context.colors.onSurface,
                          ),
                          child: Text(
                            _labels[index],
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
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

/// The fields that change with the selected tab (* = required):
///   cash   -> name*, initial balance*
///   debit  -> name*, last 4 digits*, initial balance*
///   credit -> name*, last 4 digits*, credit limit*
class _WalletDetailsView extends StatelessWidget {
  final WalletFormData formData;

  const _WalletDetailsView({required this.formData});

  String get _nameHint {
    if (formData.isCredit) return 'e.g. Travel Credit Card';
    if (formData.isDebit) return 'e.g. Daily Debit Card';
    return 'e.g. Pocket Cash';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppField.text(
          key: const ValueKey('wallet-name'),
          label: 'WALLET NAME',
          isRequired: true,
          hint: _nameHint,
          controller: formData.nameController,
          validator: formData.validateName,
          maxLength: 100,
          textCapitalization: TextCapitalization.words,
        ),
        if (formData.hasCardNumber) ...[
          const SizedBox(height: 16),
          AppField.number(
            key: const ValueKey('last-four'),
            label: 'LAST 4 DIGITS',
            isRequired: true,
            hint: '1234',
            helper: 'Only the last 4 digits. Never enter the full card number.',
            controller: formData.lastFourController,
            validator: formData.validateLastFour,
            maxLength: 4,
          ),
        ],
        const SizedBox(height: 16),
        // Different keys so cash/debit and credit never share field state.
        if (formData.isCredit)
          AppField.currency(
            key: const ValueKey('credit-limit'),
            label: 'CREDIT LIMIT',
            isRequired: false,
            helper: 'The maximum amount your bank lets you spend on this card.',
            amount: formData.creditLimit,
            validator: (_) => formData.validateCreditLimit(),
            accentColor: context.colors.secondary,
          )
        else
          AppField.currency(
            key: const ValueKey('initial-balance'),
            label: 'INITIAL BALANCE',
            isRequired: false,
            amount: formData.initialBalance,
            accentColor: context.extra.success,
          ),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════════════════
// STEP 2 (credit card only) — billing cycle
// ════════════════════════════════════════════════════════════════════════

class WalletBillingStep extends StatelessWidget {
  final WalletFormData formData;

  const WalletBillingStep({super.key, required this.formData});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _InfoBanner(
          text: 'Optional. You can leave these blank and set them later '
              'when you edit the card.',
        ),
        const SizedBox(height: 20),
        AppField.number(
          key: const ValueKey('statement-day'),
          label: 'STATEMENT DATE (TANGGAL CETAK)',
          hint: 'e.g. 25',
          helper: 'The day of the month your bank prints your credit card '
              'statement (invoice).',
          controller: formData.statementDayController,
          validator: formData.validateDayOfMonth,
          maxLength: 2,
        ),
        const SizedBox(height: 16),
        AppField.number(
          key: const ValueKey('due-day'),
          label: 'DUE DATE (TANGGAL JATUH TEMPO)',
          hint: 'e.g. 15',
          helper: 'The day of the month your credit card payment must be '
              'made by.',
          controller: formData.dueDayController,
          validator: formData.validateDayOfMonth,
          maxLength: 2,
          textInputAction: TextInputAction.done,
        ),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════════════════
// LAST STEP — confirmation
// ════════════════════════════════════════════════════════════════════════

class WalletConfirmationStep extends StatelessWidget {
  final WalletFormData formData;

  const WalletConfirmationStep({super.key, required this.formData});

  String get _typeLabel {
    if (formData.isCredit) return 'Credit Card';
    if (formData.isDebit) return 'Debit';
    return 'Cash';
  }

  static String _ordinal(int n) {
    if (n >= 11 && n <= 13) return '${n}th';
    switch (n % 10) {
      case 1:
        return '${n}st';
      case 2:
        return '${n}nd';
      case 3:
        return '${n}rd';
      default:
        return '${n}th';
    }
  }

  String? _dayLabel(int? day) =>
      day == null ? null : 'Every month on the ${_ordinal(day)}';

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[
      _SummaryRow(label: 'Type', value: _typeLabel),
      _SummaryRow(label: 'Wallet name', value: formData.name),
      if (formData.hasCardNumber)
        _SummaryRow(label: 'Card number', value: '•••• ${formData.lastFour}'),
      if (formData.isCredit) ...[
        _SummaryRow(
          label: 'Credit limit',
          value: _rupiah.format(formData.creditLimit.value),
        ),
        _SummaryRow(
          label: 'Statement date',
          value: _dayLabel(formData.statementDay) ?? 'Not set',
          muted: formData.statementDay == null,
        ),
        _SummaryRow(
          label: 'Due date',
          value: _dayLabel(formData.dueDay) ?? 'Not set',
          muted: formData.dueDay == null,
        ),
      ] else
        _SummaryRow(
          label: 'Initial balance',
          value: _rupiah.format(formData.initialBalance.value),
        ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        WalletCardPreview(formData: formData),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
          decoration: BoxDecoration(
            color: context.colors.secondaryContainer,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              for (var i = 0; i < rows.length; i++) ...[
                if (i > 0)
                  Divider(
                    height: 1,
                    color: context.colors.onSurface.withValues(alpha: 0.08),
                  ),
                rows[i],
              ],
            ],
          ),
        ),
        if (formData.isCredit &&
            (formData.statementDay == null || formData.dueDay == null)) ...[
          const SizedBox(height: 14),
          const _InfoBanner(
            text: 'Statement and due dates can be added later by editing '
                'this card.',
          ),
        ],
      ],
    );
  }
}

/// The card you see on the confirmation page.
///  • debit / credit → bank-card look with "•••• •••• •••• 1234"
///  • cash           → simple green wallet card
class WalletCardPreview extends StatelessWidget {
  final WalletFormData formData;

  const WalletCardPreview({super.key, required this.formData});

  List<Color> get _gradient {
    if (formData.isCredit) {
      return const [Color(0xFF1F1B3A), Color(0xFF6A46B5)];
    }
    if (formData.isDebit) {
      return const [Color(0xFF0F3D5E), Color(0xFF1F86B5)];
    }
    return const [Color(0xFF14532D), Color(0xFF34A867)];
  }

  String get _typeLabel {
    if (formData.isCredit) return 'CREDIT';
    if (formData.isDebit) return 'DEBIT';
    return 'CASH';
  }

  IconData get _typeIcon {
    if (formData.hasCardNumber) return Icons.contactless_rounded;
    return Icons.account_balance_wallet_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final colors = _gradient;
    final valueLabel = formData.isCredit ? 'CREDIT LIMIT' : 'BALANCE';
    final value = formData.isCredit
        ? formData.creditLimit.value
        : formData.initialBalance.value;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutCubic,
      builder: (context, t, child) => Opacity(
        opacity: t,
        child: Transform.scale(scale: 0.92 + 0.08 * t, child: child),
      ),
      child: AspectRatio(
        aspectRatio: 1.586, // standard ID-1 card ratio
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: colors,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: colors.last.withValues(alpha: 0.35),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              children: [
                const Positioned(
                  top: -50,
                  right: -40,
                  child: _Circle(size: 170, opacity: 0.09),
                ),
                const Positioned(
                  bottom: -70,
                  left: -50,
                  child: _Circle(size: 200, opacity: 0.06),
                ),
                Padding(
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            _typeLabel,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.6,
                            ),
                          ),
                          const Spacer(),
                          Icon(_typeIcon, color: Colors.white70, size: 26),
                        ],
                      ),
                      const Spacer(),
                      if (formData.hasCardNumber) ...[
                        const _CardChip(),
                        const SizedBox(height: 12),
                        Text(
                          '••••  ••••  ••••  ${formData.lastFour}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 21,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 2,
                          ),
                        ),
                      ] else
                        const Text(
                          'Cash on hand',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      const Spacer(),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: _CardLabelValue(
                              label: 'WALLET NAME',
                              value: formData.name,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _CardLabelValue(
                              label: valueLabel,
                              value: _rupiah.format(value),
                              alignEnd: true,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════
// Small building blocks
// ════════════════════════════════════════════════════════════════════════

class _InfoBanner extends StatelessWidget {
  final String text;

  const _InfoBanner({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.colors.secondaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 18,
            color: context.extra.grayText,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: context.text.bodySmall?.copyWith(
                color: context.extra.grayText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool muted;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.muted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: context.text.bodyMedium?.copyWith(
              color: context.extra.grayText,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: context.text.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: muted ? context.extra.grayText : context.colors.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CardLabelValue extends StatelessWidget {
  final String label;
  final String value;
  final bool alignEnd;

  const _CardLabelValue({
    required this.label,
    required this.value,
    this.alignEnd = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white60,
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 3),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: alignEnd ? Alignment.centerRight : Alignment.centerLeft,
          child: Text(
            value,
            maxLines: 1,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _CardChip extends StatelessWidget {
  const _CardChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 32,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF5DA8F), Color(0xFFC9A24B)],
        ),
        border: Border.all(color: Colors.white24),
      ),
    );
  }
}

class _Circle extends StatelessWidget {
  final double size;
  final double opacity;

  const _Circle({required this.size, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: opacity),
      ),
    );
  }
}