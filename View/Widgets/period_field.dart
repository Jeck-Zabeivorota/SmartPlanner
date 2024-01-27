import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smart_planner/Instruments/date_duration.dart';
import '../elements.dart';

class PeriodField extends StatefulWidget {
  final DateDuration controller;

  const PeriodField({super.key, required this.controller});

  @override
  State<PeriodField> createState() => _PeriodFieldState();
}

class _PeriodFieldState extends State<PeriodField> {
  late final TextEditingController _daysControl, _monthsControl, _yearsControl;

  @override
  void initState() {
    super.initState();
    _daysControl =
        TextEditingController(text: widget.controller.days.toString());
    _monthsControl =
        TextEditingController(text: widget.controller.months.toString());
    _yearsControl =
        TextEditingController(text: widget.controller.years.toString());
  }

  @override
  void dispose() {
    super.dispose();
    _daysControl.dispose();
    _monthsControl.dispose();
    _yearsControl.dispose();
  }

  void onChanged(TextEditingController control) {
    if (control.text.isEmpty) control.text = '0';
    if (_daysControl == control) {
      widget.controller.days = int.parse(control.text);
    } else if (_monthsControl == control) {
      widget.controller.months = int.parse(control.text);
    } else {
      widget.controller.years = int.parse(control.text);
    }
  }

  TextField _createField(
    TextEditingController controller,
    double width,
  ) =>
      TextField(
        onChanged: (_) => onChanged(controller),
        controller: controller,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: TextStyles.text(),
        decoration: InputDecorations.field(width: width),
      );

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Templates.field(
          label: 'Дни',
          child: _createField(_daysControl, 40),
        ),
        const SizedBox(width: 5),
        Templates.field(
          label: 'Месяци',
          child: _createField(_monthsControl, 40),
        ),
        const SizedBox(width: 5),
        Templates.field(
          label: 'Года',
          child: _createField(_yearsControl, 60),
        ),
      ],
    );
  }
}
