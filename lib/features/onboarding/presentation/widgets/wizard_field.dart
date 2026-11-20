import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/tokens.dart';

const _fieldBorder = Color(0xFFE8DCCF);

/// `.field` — a 10px caps label over a 48px control, with the error message
/// under it (`frontend-conventions.md`: validate in the client, show the
/// message next to the field).
class WizardField extends StatelessWidget {
  const WizardField({
    super.key,
    required this.label,
    required this.child,
    this.error,
  });

  final String label;
  final Widget child;
  final String? error;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 7),
          child,
          if (error != null)
            Padding(
              padding: const EdgeInsets.only(top: 6, left: 2),
              child: Text(
                error!,
                style: const TextStyle(fontSize: 10, color: HFColors.primary),
              ),
            ),
        ],
      ),
    );
  }
}

/// The `input` of the pack: 48px tall, 11px radius, white, orange on focus.
class WizardInput extends StatelessWidget {
  const WizardInput({
    super.key,
    required this.controller,
    this.hint,
    this.keyboardType,
    this.maxLength,
    this.maxLines = 1,
    this.enabled = true,
    this.onChanged,
    this.inputFormatters,
  });

  final TextEditingController controller;
  final String? hint;
  final TextInputType? keyboardType;
  final int? maxLength;
  final int maxLines;
  final bool enabled;
  final ValueChanged<String>? onChanged;
  final List<TextInputFormatter>? inputFormatters;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLength: maxLength,
      maxLines: maxLines,
      enabled: enabled,
      onChanged: onChanged,
      inputFormatters: inputFormatters,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: HFColors.ink,
      ),
      decoration: InputDecoration(
        counterText: '',
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 11, color: Color(0xFFB2A69A)),
        filled: true,
        fillColor: enabled ? Colors.white : HFColors.soft,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 14,
        ),
        enabledBorder: _border(_fieldBorder),
        disabledBorder: _border(_fieldBorder),
        focusedBorder: _border(HFColors.primary, width: 1.5),
      ),
    );
  }

  static OutlineInputBorder _border(Color color, {double width = 1}) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(11),
        borderSide: BorderSide(color: color, width: width),
      );
}

/// The `select` of the pack, same box as [WizardInput].
class WizardDropdown<T> extends StatelessWidget {
  const WizardDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    this.hint,
  });

  final T? value;
  final Map<T, String> items;
  final ValueChanged<T?> onChanged;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      isExpanded: true,
      hint: hint == null
          ? null
          : Text(
              hint!,
              style: const TextStyle(fontSize: 11, color: Color(0xFFB2A69A)),
            ),
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: HFColors.ink,
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 14,
        ),
        enabledBorder: WizardInput._border(_fieldBorder),
        focusedBorder: WizardInput._border(HFColors.primary, width: 1.5),
      ),
      items: [
        for (final entry in items.entries)
          DropdownMenuItem(value: entry.key, child: Text(entry.value)),
      ],
      onChanged: onChanged,
    );
  }
}
