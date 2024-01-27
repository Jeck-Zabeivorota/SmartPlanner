import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../elements.dart';

class TimeFieldController {
  late int _hour, _minute;

  int get hour => _hour;
  int get minute => _minute;

  set hour(int value) {
    if (value < 0 || value > 23) throw Exception('incorrect hours: $value');
    _hour = value;
  }

  set minute(int value) {
    if (value < 0 || value > 59) throw Exception('incorrect minutes: $value');
    _minute = value;
  }

  DateTime get time => DateTime(1, 1, 1, _hour, _minute);

  void setValues(DateTime date) {
    _hour = date.hour;
    _minute = date.minute;
  }

  TimeFieldController([int hour = 1, int minute = 1]) {
    this.hour = hour;
    this.minute = minute;
  }

  TimeFieldController.fromDateTime(DateTime date) {
    setValues(date);
  }
}

class TimeField extends StatefulWidget {
  final TimeFieldController controller;

  const TimeField({super.key, required this.controller});

  @override
  State<TimeField> createState() => _TimeFieldState();
}

class _TimeFieldState extends State<TimeField> {
  final _hourController = TextEditingController(),
      _minuteController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    _hourController.dispose();
    _minuteController.dispose();
  }

  void onChanged(TextEditingController control) {
    if (control.text.isEmpty) {
      control.text = '0';
    }

    int value = int.parse(control.text);
    if (value < 0) {
      value = 0;
      control.text = '0';
    }

    if (control == _hourController) {
      if (value > 23) {
        value = 23;
        control.text = value.toString();
      }
      widget.controller.hour = value;
    } else {
      if (value > 59) {
        value = 59;
        control.text = value.toString();
      }
      widget.controller.minute = value;
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
    _hourController.text = widget.controller.hour.toString();
    _minuteController.text = widget.controller.minute.toString();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Templates.field(
          label: 'Години',
          child: _createField(_hourController, 40),
        ),
        const SizedBox(width: 5),
        Padding(
          padding: const EdgeInsets.only(top: 22),
          child: Text(':', style: TextStyles.text(isBold: true)),
        ),
        const SizedBox(width: 5),
        Templates.field(
          label: 'Хвилини',
          child: _createField(_minuteController, 40),
        ),
      ],
    );
  }
}
