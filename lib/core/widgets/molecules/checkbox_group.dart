import 'package:flutter/material.dart';

import '../atoms/app_checkbox.dart';

/// One selectable option in a [CheckboxGroup] — [value] is what gets added
/// to/removed from the selected set, [label] is what's shown next to the
/// checkbox.
class CheckboxOption<T> {
  const CheckboxOption({required this.value, required this.label});

  final T value;
  final String label;
}

/// A row/column of [AppCheckbox]es sharing one multi-select [selected] set.
///
/// [direction] switches between stacked ([Axis.vertical], the default) and
/// side-by-side ([Axis.horizontal]) layout; [spacing] controls the gap
/// between checkboxes along that axis and [runSpacing] the gap between
/// wrapped rows/columns if there isn't room for everything on one line —
/// both just forwarded to the underlying [Wrap].
class CheckboxGroup<T> extends StatelessWidget {
  const CheckboxGroup({
    super.key,
    required this.options,
    required this.selected,
    required this.onChanged,
    this.direction = Axis.vertical,
    this.spacing = 4,
    this.runSpacing = 0,
    this.activeColor,
  });

  final List<CheckboxOption<T>> options;
  final Set<T> selected;

  /// Called with the full updated selection whenever one checkbox toggles.
  final ValueChanged<Set<T>> onChanged;

  final Axis direction;
  final double spacing;
  final double runSpacing;
  final Color? activeColor;

  void _toggle(T value, bool checked) {
    final next = {...selected};
    if (checked) {
      next.add(value);
    } else {
      next.remove(value);
    }
    onChanged(next);
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      direction: direction,
      spacing: spacing,
      runSpacing: runSpacing,
      children: [
        for (final option in options)
          AppCheckbox(
            label: option.label,
            value: selected.contains(option.value),
            onChanged: (checked) => _toggle(option.value, checked),
            activeColor: activeColor,
          ),
      ],
    );
  }
}
