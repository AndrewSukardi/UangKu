import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import 'package:UangKu/theme/theme_extensions.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

/// What kind of value the field collects.
enum AppFieldType { text, number, currency, date }

/// One reusable labeled input for every form in the app.
///
/// Pick the kind with a named constructor:
///
///   AppField.text(...)      free text            -> TextEditingController
///   AppField.number(...)    digits only          -> TextEditingController
///   AppField.currency(...)  1.000.000 + "Rp"     -> ValueNotifier<int>
///   AppField.date(...)      tap to pick a date   -> ValueNotifier<DateTime?>
///
/// All of them share the same look:
///   • label above the field, with a red "*" when [isRequired]
///   • error text (or helper text) under the field, flush with the label
///   • red border while invalid; errors only show after the user interacts
class AppField extends StatefulWidget {
  final AppFieldType type;
  final String label;
  final bool isRequired;
  final String? hint;
  final String? helper;

  /// Extra rules on top of the automatic "is required" check.
  /// Receives the text currently shown in the field.
  final String? Function(String?)? validator;

  // text / number
  final TextEditingController? controller;
  final int? maxLength;
  final TextInputAction textInputAction;
  final TextCapitalization textCapitalization;

  // currency
  final ValueNotifier<int>? amount;
  final Color? accentColor;
  final String currencySymbol;
  final int maxDigits;

  // date
  final ValueNotifier<DateTime?>? date;
  final DateTime? firstDate;
  final DateTime? lastDate;

  const AppField._({
    super.key,
    required this.type,
    required this.label,
    this.isRequired = false,
    this.hint,
    this.helper,
    this.validator,
    this.controller,
    this.maxLength,
    this.textInputAction = TextInputAction.next,
    this.textCapitalization = TextCapitalization.none,
    this.amount,
    this.accentColor,
    this.currencySymbol = 'Rp',
    this.maxDigits = 15,
    this.date,
    this.firstDate,
    this.lastDate,
  });

  /// Free text (names, notes...).
  const AppField.text({
    Key? key,
    required String label,
    required TextEditingController controller,
    bool isRequired = false,
    String? hint,
    String? helper,
    String? Function(String?)? validator,
    int? maxLength,
    TextInputAction textInputAction = TextInputAction.next,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) : this._(
         key: key,
         type: AppFieldType.text,
         label: label,
         controller: controller,
         isRequired: isRequired,
         hint: hint,
         helper: helper,
         validator: validator,
         maxLength: maxLength,
         textInputAction: textInputAction,
         textCapitalization: textCapitalization,
       );

  /// Digits only (last 4 digits, day of month...). Use [maxLength] to cap it.
  const AppField.number({
    Key? key,
    required String label,
    required TextEditingController controller,
    bool isRequired = false,
    String? hint,
    String? helper,
    String? Function(String?)? validator,
    int? maxLength,
    TextInputAction textInputAction = TextInputAction.next,
  }) : this._(
         key: key,
         type: AppFieldType.number,
         label: label,
         controller: controller,
         isRequired: isRequired,
         hint: hint,
         helper: helper,
         validator: validator,
         maxLength: maxLength,
         textInputAction: textInputAction,
       );

  /// Money. Shows "Rp" and thousand separators while typing, and writes the
  /// plain integer into [amount]. A value of 0 is shown as an empty field
  /// with a "0" hint, so [isRequired] here only adds the asterisk; enforce
  /// "must be greater than 0" with [validator].
  const AppField.currency({
    Key? key,
    required String label,
    required ValueNotifier<int> amount,
    bool isRequired = false,
    String hint = '0',
    String? helper,
    String? Function(String?)? validator,
    Color? accentColor,
    String currencySymbol = 'Rp',
    int maxDigits = 15,
    TextInputAction textInputAction = TextInputAction.next,
  }) : this._(
         key: key,
         type: AppFieldType.currency,
         label: label,
         amount: amount,
         isRequired: isRequired,
         hint: hint,
         helper: helper,
         validator: validator,
         accentColor: accentColor,
         currencySymbol: currencySymbol,
         maxDigits: maxDigits,
         textInputAction: textInputAction,
       );

  /// Tap to open the date picker. Optional dates get a clear button.
  const AppField.date({
    Key? key,
    required String label,
    required ValueNotifier<DateTime?> date,
    bool isRequired = false,
    String hint = 'Select date',
    String? helper,
    String? Function(String?)? validator,
    DateTime? firstDate,
    DateTime? lastDate,
  }) : this._(
         key: key,
         type: AppFieldType.date,
         label: label,
         date: date,
         isRequired: isRequired,
         hint: hint,
         helper: helper,
         validator: validator,
         firstDate: firstDate,
         lastDate: lastDate,
       );

  @override
  State<AppField> createState() => _AppFieldState();
}

class _AppFieldState extends State<AppField> {
  static final NumberFormat _amountFormat = NumberFormat.decimalPattern(
    'id_ID',
  );
  static final DateFormat _dateFormat = DateFormat('d MMM yyyy', 'en');

  final GlobalKey<FormFieldState<String>> _fieldKey =
      GlobalKey<FormFieldState<String>>();

  late final TextEditingController _controller;
  bool _ownsController = false;

  @override
  void initState() {
    super.initState();
    switch (widget.type) {
      case AppFieldType.text:
      case AppFieldType.number:
        _controller = widget.controller!;
      case AppFieldType.currency:
        _ownsController = true;
        _controller = TextEditingController(
          text: _formatAmount(widget.amount!.value),
        );
        widget.amount!.addListener(_syncFromAmount);
      case AppFieldType.date:
        _ownsController = true;
        _controller = TextEditingController(
          text: _formatDate(widget.date!.value),
        );
        widget.date!.addListener(_syncFromDate);
    }
  }

  @override
  void dispose() {
    if (widget.type == AppFieldType.currency) {
      widget.amount!.removeListener(_syncFromAmount);
    }
    if (widget.type == AppFieldType.date) {
      widget.date!.removeListener(_syncFromDate);
    }
    if (_ownsController) _controller.dispose();
    super.dispose();
  }

  // ── value <-> text ───────────────────────────────────────────────────

  static String _formatAmount(int value) =>
      value <= 0 ? '' : _amountFormat.format(value);

  static String _formatDate(DateTime? value) =>
      value == null ? '' : _dateFormat.format(value);

  /// The notifier changed from outside (reset, quick-add...): update the text.
  void _syncFromAmount() {
    final text = _formatAmount(widget.amount!.value);
    if (_controller.text == text) return; // change came from typing
    _controller.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
    _fieldKey.currentState?.didChange(text);
  }

  void _syncFromDate() {
    final text = _formatDate(widget.date!.value);
    if (_controller.text == text) return;
    _controller.text = text;
    _fieldKey.currentState?.didChange(text);
  }

  void _onChanged(String text, FormFieldState<String> state) {
    if (widget.type == AppFieldType.currency) {
      final digits = text.replaceAll(RegExp(r'\D'), '');
      widget.amount!.value = int.tryParse(digits) ?? 0;
    }
    state.didChange(text);
  }

  Future<void> _pickDate() async {
    FocusScope.of(context).unfocus();
    final first = widget.firstDate ?? DateTime(1900);
    final last = widget.lastDate ?? DateTime(2100);
    var initial = widget.date!.value ?? DateTime.now();
    if (initial.isBefore(first)) initial = first;
    if (initial.isAfter(last)) initial = last;

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: first,
      lastDate: last,
    );
    if (picked != null) widget.date!.value = picked; // listener updates text
  }

  // ── validation ───────────────────────────────────────────────────────

  /// "STATEMENT DATE (TANGGAL CETAK)" -> "Statement date"
  String get _humanLabel {
    final base = widget.label
        .replaceAll(RegExp(r'\s*\(.*?\)'), '')
        .trim()
        .toLowerCase();
    if (base.isEmpty) return 'This field';
    return base[0].toUpperCase() + base.substring(1);
  }

  String? _validate(String? value) {
    final text = value?.trim() ?? '';
    // Currency can legitimately be 0, so it has no automatic empty check.
    if (widget.isRequired &&
        widget.type != AppFieldType.currency &&
        text.isEmpty) {
      return '$_humanLabel is required';
    }
    return widget.validator?.call(value);
  }

  // ── input config per type ────────────────────────────────────────────

  TextInputType? get _keyboardType => switch (widget.type) {
    AppFieldType.text => TextInputType.text,
    AppFieldType.number || AppFieldType.currency => TextInputType.number,
    AppFieldType.date => null,
  };

  List<TextInputFormatter>? get _formatters => switch (widget.type) {
    AppFieldType.number => [FilteringTextInputFormatter.digitsOnly],
    AppFieldType.currency => [_ThousandsFormatter(maxDigits: widget.maxDigits)],
    _ => null,
  };

  // ── UI ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isCurrency = widget.type == AppFieldType.currency;
    final isDate = widget.type == AppFieldType.date;
    final accent = widget.accentColor ?? context.colors.onSurface;
    final gray = context.extra.grayText;

    final radius = BorderRadius.circular(16);
    OutlineInputBorder border(Color color, [double width = 1]) =>
        OutlineInputBorder(
          borderRadius: radius,
          borderSide: BorderSide(color: color, width: width),
        );

    return FormField<String>(
      key: _fieldKey,
      initialValue: _controller.text,
      validator: _validate,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      builder: (state) {
        final hasError = state.hasError;
        final hasValue = _controller.text.isNotEmpty;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Label (+ red asterisk when required)
            Text.rich(
              TextSpan(
                text: widget.label,
                children: [
                  if (widget.isRequired)
                    TextSpan(
                      text: ' *',
                      style: TextStyle(color: context.extra.error),
                    ),
                ],
              ),
              style: context.text.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: context.colors.onSecondary,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _controller,
              readOnly: isDate,
              showCursor: isDate ? false : null,
              onTap: isDate ? _pickDate : null,
              onChanged: (text) => _onChanged(text, state),
              keyboardType: _keyboardType,
              inputFormatters: _formatters,
              maxLength: widget.maxLength,
              textInputAction: widget.textInputAction,
              textCapitalization: widget.textCapitalization,
              style: TextStyle(
                fontWeight: isCurrency ? FontWeight.w700 : FontWeight.w600,
                fontSize: isCurrency ? 18 : 16,
                color: isCurrency ? accent : context.colors.onSurface,
              ),
              decoration: InputDecoration(
                hintText: widget.hint,
                hintStyle: context.text.bodyLarge?.copyWith(
                  color: context.extra.grayText,
                ),
                counterText: '',
                filled: true,
                fillColor: context.colors.secondaryContainer,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 16,
                ),
                prefixIcon: isCurrency
                    ? Padding(
                        padding: const EdgeInsets.only(left: 18, right: 8),
                        child: Center(
                          widthFactor: 1,
                          heightFactor: 1,
                          child: Text(
                            widget.currencySymbol,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              color: accent,
                            ),
                          ),
                        ),
                      )
                    : null,
                prefixIconConstraints: const BoxConstraints(
                  minWidth: 0,
                  minHeight: 0,
                ),
                suffixIcon: isDate
                    ? Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: (hasValue && !widget.isRequired)
                            ? IconButton(
                                onPressed: () => widget.date!.value = null,
                                icon: Icon(
                                  Icons.close_rounded,
                                  size: 20,
                                  color: gray,
                                ),
                              )
                            : Icon(
                                Icons.calendar_today_rounded,
                                size: 20,
                                color: gray,
                              ),
                      )
                    : null,
                border: border(Colors.transparent),
                enabledBorder: border(
                  hasError ? context.extra.error : Colors.transparent,
                ),
                focusedBorder: border(
                  hasError ? context.extra.error : context.colors.primary,
                  1.5,
                ),
              ),
            ),

            

            // Error replaces the helper text while the field is invalid.
            if (hasError) ...[
              const SizedBox(height: 6),

              Row(
                children: [
                Icon(PhosphorIconsRegular.warningCircle,color: context.extra.error, size: 14),
              const SizedBox(width: 4),
                  Text(
                state.errorText!,
                style: context.text.bodySmall?.copyWith(
                  color:context.extra.error ,
                ),
              ),
                ],
              )
              
            ]
            
            else if (widget.helper != null  && !hasValue) ...[
              const SizedBox(height: 6),
              Text(
                widget.helper!,
                style: context.text.bodySmall?.copyWith(color: context.extra.grayText),
              ),
            ]
          ],
        );
      },
    );
  }
}

/// Turns whatever is typed into digits with thousand separators
/// (1000000 -> 1.000.000). Leading zeros are dropped, and an empty result
/// means 0. Digits are capped at [maxDigits].
class _ThousandsFormatter extends TextInputFormatter {
  final int maxDigits;
  final NumberFormat _format = NumberFormat.decimalPattern('id_ID');

  _ThousandsFormatter({required this.maxDigits});

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    digits = digits.replaceFirst(RegExp(r'^0+'), '');
    if (digits.length > maxDigits) digits = digits.substring(0, maxDigits);
    if (digits.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }
    final text = _format.format(int.parse(digits));
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
