import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class NumberInputBox extends StatefulWidget {
  final String label;
  final int initialValue;
  final Color numberColor;
  final Color labelColor;
  final Color backgroundColor;
  final Color prefixColor;
  final String prefixText;
  final int? minValue;
  final int? maxValue;
  final ValueChanged<int>? onChanged;
  final ValueNotifier<int>? amountNotifier; // <-- external controller
  final bool showResetButton; // <-- toggle the reset button
  final Color resetIconColor;

  const NumberInputBox({
    super.key,
    required this.label,
    this.initialValue = 0,
    this.numberColor = const Color(0xFFFFB3B3),
    this.labelColor = const Color(0xFF8B95C9),
    this.prefixColor = const Color(0xFFFF6B6B),
    this.backgroundColor = const Color(0xFFF7F8FC),
    this.prefixText = "Rp",
    this.minValue,
    this.maxValue,
    this.onChanged,
    this.amountNotifier,
    this.showResetButton = true,
    this.resetIconColor = const Color(0xFF8B95C9),
  });

  @override
  State<NumberInputBox> createState() => _NumberInputBoxState();
}

class _NumberInputBoxState extends State<NumberInputBox> {
  late TextEditingController _controller;
  late int _value;
  final NumberFormat _formatter = NumberFormat.decimalPattern('id_ID');
  ValueNotifier<int>? _notifier;

  @override
  void initState() {
    super.initState();
    _value = widget.amountNotifier?.value ?? widget.initialValue;
    _controller = TextEditingController(text: _formatter.format(_value));

    _notifier = widget.amountNotifier;
    _notifier?.addListener(_onNotifierChanged);
  }

  @override
  void dispose() {
    _notifier?.removeListener(_onNotifierChanged);
    _controller.dispose();
    super.dispose();
  }

  // Called when something OUTSIDE (a quick-add chip) changes the notifier
  void _onNotifierChanged() {
    final newValue = _notifier!.value;
    if (newValue == _value) return; // avoid loop when we set it ourselves
    setState(() {
      _value = newValue;
      final formatted = _formatter.format(_value);
      _controller.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    });
    widget.onChanged?.call(_value);
  }

  double get _fontSize {
    final len = _controller.text.length;
    if (len <= 12) return 32;
    if (len <= 15) return 26;
    return 22;
  }

  double get _fontSizeLabel {
    final len = _controller.text.length;
    if (len <= 12) return 22;
    if (len <= 15) return 19;
    return 17;
  }

  void _setValue(int newValue) {
    if (widget.minValue != null && newValue < widget.minValue!) {
      newValue = widget.minValue!;
    }
    if (widget.maxValue != null && newValue > widget.maxValue!) {
      newValue = widget.maxValue!;
    }

    _value = newValue;
    final formatted = _formatter.format(_value);

    setState(() {
      _controller.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    });

    // Push the change out to the shared notifier (without re-triggering the listener loop)
    if (_notifier != null && _notifier!.value != _value) {
      _notifier!.value = _value;
    }
    widget.onChanged?.call(_value);
  }

  void _onChanged(String val) {
    final digitsOnly = val.replaceAll(RegExp(r'[^0-9]'), '');
    final newValue = digitsOnly.isEmpty ? 0 : int.parse(digitsOnly);
    _setValue(newValue);
  }

  void _onReset() {
    // Respect a minValue floor if one is set (e.g. minValue: 1000 -> reset goes to 1000, not 0)
    final target = widget.minValue ?? 0;
    _setValue(target);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: widget.backgroundColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              // Left spacer only appears if reset button is shown, to balance the icon on the right
              if (widget.showResetButton)
                SizedBox(
                  width: 16,
                ), // roughly matches icon width so label stays centered
              Expanded(
                child: Text(
                  widget.label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    color: widget.labelColor,
                  ),
                ),
              ),
              if (widget.showResetButton)
                GestureDetector(
                  onTap: _value == 0 ? null : _onReset,
                  child: Icon(
                    Icons.refresh_rounded,
                    size: 16,
                    color: _value == 0
                        ? widget.resetIconColor.withOpacity(0.3)
                        : widget.resetIconColor,
                  ),
                )
              else
                const SizedBox.shrink(),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 40,
            child: Stack(
              alignment: Alignment.center,
              children: [
                TextField(
                  controller: _controller,
                  textAlign: TextAlign.center,
                  textAlignVertical: TextAlignVertical
                      .center, // <-- centers text within the field's own box
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: TextStyle(
                    color: widget.numberColor,
                    fontWeight: FontWeight.bold,
                    fontSize: _fontSize,
                    height:
                        1.0, // <-- removes extra line-height padding above/below glyphs
                  ),
                  strutStyle: StrutStyle(
                    fontSize: _fontSize,
                    height: 1.0,
                    forceStrutHeight:
                        true, // <-- forces consistent line height, ignoring font metric quirks
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  onChanged: _onChanged,
                ),
                Positioned(
                  left: 0,
                  child: Text(
                    widget.prefixText,
                    style: TextStyle(
                      color: widget.prefixColor,
                      fontWeight: FontWeight.bold,
                      fontSize: _fontSizeLabel,
                      height: 1.0, // <-- match TextField's line height
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Container(height: 1, color: Colors.grey.shade200),
        ],
      ),
    );
  }
}

