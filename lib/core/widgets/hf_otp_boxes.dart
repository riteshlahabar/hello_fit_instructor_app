import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/tokens.dart';

/// `.otp` — single-digit boxes that advance on type and step back on
/// backspace, exactly like the script in the HTML page.
class OtpBoxes extends StatefulWidget {
  const OtpBoxes({
    super.key,
    this.length = 6,
    required this.onChanged,
    this.onCompleted,
  });

  final int length;
  final ValueChanged<String> onChanged;
  final ValueChanged<String>? onCompleted;

  @override
  State<OtpBoxes> createState() => _OtpBoxesState();
}

class _OtpBoxesState extends State<OtpBoxes> {
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _nodes;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(widget.length, (_) => TextEditingController());
    _nodes = List.generate(widget.length, (_) => FocusNode());
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final n in _nodes) {
      n.dispose();
    }
    super.dispose();
  }

  String get _value => _controllers.map((c) => c.text).join();

  void _onChanged(int index, String raw) {
    // A paste of the whole code lands in one box: spread it across the rest.
    if (raw.length > 1) {
      final digits = raw.replaceAll(RegExp(r'\D'), '');
      for (var i = 0; i < widget.length; i++) {
        _controllers[i].text = i < digits.length ? digits[i] : '';
      }
      _nodes[(digits.length - 1).clamp(0, widget.length - 1)].requestFocus();
    } else if (raw.isNotEmpty && index < widget.length - 1) {
      _nodes[index + 1].requestFocus();
    }

    widget.onChanged(_value);
    if (_value.length == widget.length) {
      _nodes[index].unfocus();
      widget.onCompleted?.call(_value);
    }
  }

  void _onKey(int index, KeyEvent event) {
    final isBackspace =
        event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace;
    if (isBackspace && _controllers[index].text.isEmpty && index > 0) {
      _controllers[index - 1].clear();
      _nodes[index - 1].requestFocus();
      widget.onChanged(_value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        for (var i = 0; i < widget.length; i++) ...[
          if (i > 0) const SizedBox(width: 9),
          Expanded(
            child: KeyboardListener(
              focusNode: FocusNode(skipTraversal: true),
              onKeyEvent: (event) => _onKey(i, event),
              child: _Box(
                controller: _controllers[i],
                node: _nodes[i],
                onChanged: (value) => _onChanged(i, value),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _Box extends StatelessWidget {
  const _Box({
    required this.controller,
    required this.node,
    required this.onChanged,
  });

  final TextEditingController controller;
  final FocusNode node;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 55,
      child: TextField(
        controller: controller,
        focusNode: node,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        onChanged: onChanged,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: HFColors.ink,
        ),
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: HFColors.white,
          contentPadding: EdgeInsets.zero,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(13),
            borderSide: const BorderSide(color: Color(0xFFE8DCCF)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(13),
            borderSide: const BorderSide(color: HFColors.primary, width: 1.5),
          ),
        ),
      ),
    );
  }
}
