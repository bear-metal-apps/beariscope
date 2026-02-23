import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

class NumberTextField extends StatelessWidget {
  final String labelText;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;

  const NumberTextField({
    super.key,
    required this.labelText,
    this.controller,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(labelText: labelText),
      keyboardType: TextInputType.number,
      onChanged: onChanged,
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.digitsOnly,
      ],
    );
  }
}

class RadioButton extends StatefulWidget {
  const RadioButton({
    super.key,
    required this.options,
    this.initialValue,
    this.onChanged,
    this.height,
    this.variable,
  });

  final List<String> options;
  final String? initialValue;
  final ValueChanged<String?>? onChanged;
  final double? height;
  final String? variable;

  @override
  State<RadioButton> createState() => _RadioButtonState();
}

class _RadioButtonState extends State<RadioButton> {
  late String? _selectedValue = widget.variable;

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.initialValue ?? widget.options.firstOrNull;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children:
          widget.options.map((option) {
            return ListTile(
              title: Text(option),
              leading: Radio<String>(
                value: option,
                groupValue: _selectedValue,
                onChanged: (String? value) {
                  setState(() {
                    _selectedValue = value;
                  });
                  widget.onChanged?.call(value);
                },
              ),
            );
          }).toList(),
    );
  }
}

class MultipleChoice extends StatefulWidget {
  const MultipleChoice({
    super.key,
    required this.options,
    this.initialSelection,
    this.onSelectionChanged,
    this.label,
    this.variable,
  });

  final List<String> options;
  final List<String>? initialSelection;
  final ValueChanged<Set<String>>? onSelectionChanged;
  final String? label;
  final Set<String>? variable;

  @override
  State<MultipleChoice> createState() => _MultipleChoiceState();
}

class _MultipleChoiceState extends State<MultipleChoice> {
  late Set<String> _selection = widget.variable ?? <String>{};

  @override
  void initState() {
    super.initState();
    if (widget.initialSelection != null) {
      _selection = widget.initialSelection!.toSet();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        if (widget.label != null) ...[
          const SizedBox(height: 20),
          Text(widget.label!),
          const SizedBox(height: 10),
        ],
        SegmentedButton<String>(
          multiSelectionEnabled: true,
          emptySelectionAllowed: true,
          showSelectedIcon: false,
          selected: _selection,
          onSelectionChanged: (Set<String> newSelection) {
            setState(() {
              _selection = newSelection;
            });
            widget.onSelectionChanged?.call(newSelection);
          },
          segments:
              widget.options
                  .map(
                    (option) => ButtonSegment<String>(
                      value: option,
                      label: Text(option),
                    ),
                  )
                  .toList(),
        ),
      ],
    );
  }
}

class DropdownButtonOneChoice extends StatefulWidget {
  const DropdownButtonOneChoice({
    super.key,
    required this.options,
    this.initialValue,
    this.onChanged,
    this.label,
    this.variable,
  });

  final List<String> options;
  final String? initialValue;
  final ValueChanged<String?>? onChanged;
  final String? label;
  final String? variable;

  @override
  State<DropdownButtonOneChoice> createState() => _DropdownButtonState();
}

class _DropdownButtonState extends State<DropdownButtonOneChoice> {
  late String? _selectedValue = widget.variable;

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.initialValue ?? widget.options.firstOrNull;
  }

  @override
  Widget build(BuildContext context) {
    return DropdownMenu<String>(
      label: widget.label != null ? Text(widget.label!) : null,
      initialSelection: _selectedValue,
      onSelected: (String? value) {
        setState(() {
          _selectedValue = value;
        });
        widget.onChanged?.call(value);
      },
      dropdownMenuEntries:
          widget.options.map<DropdownMenuEntry<String>>((String value) {
            return DropdownMenuEntry<String>(value: value, label: value);
          }).toList(),
    );
  }
}

class SegmentedSlider extends StatefulWidget {
  const SegmentedSlider({
    super.key,
    required this.min,
    required this.max,
    required this.divisions,
    this.initialValue,
    this.onChanged,
    this.label,
    this.variable,
  });

  final double min;
  final double max;
  final int divisions;
  final double? initialValue;
  final ValueChanged<double>? onChanged;
  final String? label;
  final double? variable;

  @override
  State<SegmentedSlider> createState() => _SegmentedSliderState();
}

class _SegmentedSliderState extends State<SegmentedSlider> {
  late double? _currentValue = widget.variable;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.initialValue ?? widget.min;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (widget.label != null) ...[
          Text(widget.label!),
          const SizedBox(height: 8),
        ],
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 16,
          children: <Widget>[
            Slider(
              value: _currentValue ?? 0,
              min: widget.min,
              max: widget.max,
              divisions: widget.divisions,
              label: _currentValue?.round().toString(),
              onChanged: (double value) {
                setState(() {
                  _currentValue = value;
                });
                widget.onChanged?.call(value);
              },
            ),
          ],
        ),
      ],
    );
  }
}
