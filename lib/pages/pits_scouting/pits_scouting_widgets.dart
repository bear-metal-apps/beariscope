import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

class NumberTextField extends StatefulWidget {
  const NumberTextField({super.key});

  @override
  State<StatefulWidget> createState() {
    return _NumberTextFieldState();
  }
}

class _NumberTextFieldState extends State<NumberTextField> {
  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(labelText: "Enter number"),
      keyboardType: TextInputType.number,
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.digitsOnly,
      ],
    );
  }
}

class RadioButton extends StatefulWidget {
  const RadioButton({super.key});

  @override
  State<RadioButton> createState() => _RadioButtonState();
}

enum ScoutingOption { choice1, choice2 }

class _RadioButtonState extends State<RadioButton> {
  ScoutingOption? _option = ScoutingOption.choice1;

  @override
  Widget build(BuildContext context) {
    return RadioGroup<ScoutingOption>(
      groupValue: _option,
      onChanged: (ScoutingOption? value) {
        setState(() {
          _option = value;
        });
      },
      child: const Column(
        children: <Widget>[
          ListTile(
            title: Text('Placeholder 1'),
            leading: Radio<ScoutingOption>(value: ScoutingOption.choice1),
          ),
          ListTile(
            title: Text('Placeholder 2'),
            leading: Radio<ScoutingOption>(value: ScoutingOption.choice2),
          ),
        ],
      ),
    );
  }
}

enum ScoutOption { one, two, three, four, five }

const List<(ScoutOption, String)> scoutChooseOptions = <(ScoutOption, String)>[
  (ScoutOption.one, 'Option 1'),
  (ScoutOption.two, 'Option 2'),
  (ScoutOption.three, 'Option 3'),
  (ScoutOption.four, 'Option 4'),
  (ScoutOption.five, 'Option 5'),
];

class MultipleChoice extends StatefulWidget {
  const MultipleChoice({super.key});

  @override
  State<MultipleChoice> createState() => _MultipleChoiceState();
}

class _MultipleChoiceState extends State<MultipleChoice> {
  Set<ScoutOption> _multipleChoiceSelection = <ScoutOption>{ScoutOption.three};

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        const SizedBox(height: 20),
        const Text('Multiple Choice'),
        const SizedBox(height: 10),
        SegmentedButton<ScoutOption>(
          multiSelectionEnabled: true,
          emptySelectionAllowed: true,
          showSelectedIcon: false,
          selected: _multipleChoiceSelection,
          onSelectionChanged: (Set<ScoutOption> newSelection) {
            setState(() {
              _multipleChoiceSelection = newSelection;
            });
          },
          segments: const <ButtonSegment<ScoutOption>>[
            ButtonSegment<ScoutOption>(
              value: ScoutOption.one,
              label: Text('One'),
            ),
            ButtonSegment<ScoutOption>(
              value: ScoutOption.two,
              label: Text('Two'),
            ),
            ButtonSegment<ScoutOption>(
              value: ScoutOption.three,
              label: Text('Three'),
            ),
            ButtonSegment<ScoutOption>(
              value: ScoutOption.four,
              label: Text('Four'),
            ),
            ButtonSegment<ScoutOption>(
              value: ScoutOption.five,
              label: Text('Five'),
            ),
          ],
        ),
      ],
    );
  }
}

const List<String> list = <String>['One', 'Two', 'Three', 'Four'];

class DropdownButtonOneChoice extends StatefulWidget {
  const DropdownButtonOneChoice({super.key});
  @override
  State<DropdownButtonOneChoice> createState() => _DropdownButtonState();
}

class _DropdownButtonState extends State<DropdownButtonOneChoice> {
  String dropdownValue = list.first;

  @override
  Widget build(BuildContext context) {
    return DropdownMenu<String>(
      initialSelection: dropdownValue,
      onSelected: (String? value) {
        setState(() {
          dropdownValue = value!;
        });
      },
      dropdownMenuEntries: list.map<DropdownMenuEntry<String>>((String value) {
        return DropdownMenuEntry<String>(
          value: value,
          label: value,
        );
      }).toList(),
    );
  }
}
class SegmentedSlider extends StatefulWidget {
  const SegmentedSlider({super.key});

  @override
  State<SegmentedSlider> createState() => _SegmentedSliderState();
}
class _SegmentedSliderState extends State<SegmentedSlider> {
  double _currentDiscreteSliderValue = 60;
  bool year2023 = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 16,
          children: <Widget>[
            Slider(
              value: _currentDiscreteSliderValue,
              max: 100,
              divisions: 5,
              label: _currentDiscreteSliderValue.round().toString(),
              onChanged: (double value) {
                setState(() {
                  _currentDiscreteSliderValue = value;
                });
              },
            ),
          ],
        ),
      ],
    );
  }
}