import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smart_planner/Instruments/date_duration.dart';
import '../../extension_methods.dart';
import '../elements.dart';

class DateFieldController {
  late int _day, _month, _year;
  bool dayFieldIsVisible = true,
      monthFieldIsVisible = true,
      yearFieldIsVisible = true;

  int get day => _day;
  int get month => _month;
  int get year => _year;

  set day(int value) {
    int maxDay = DateDuration.daysInMonth(_month, _year);
    if (value < 1 || value > maxDay) throw Exception('incorrect day: $value');
    _day = value;
  }

  set month(int value) {
    if (value < 1 || value > 12) throw Exception('incorrect month: $value');
    _month = value;

    int maxDay = DateDuration.daysInMonth(_month, _year);
    if (_day > maxDay) _day = maxDay;
  }

  set year(int value) {
    if (value < 1 || value > 9999) throw Exception('incorrect year: $value');
    _year = value;

    int maxDay = DateDuration.daysInMonth(_month, _year);
    if (_day > maxDay) _day = maxDay;
  }

  DateTime get date => DateTime(_year, _month, _day);

  void setValues(DateTime date) {
    _day = date.day;
    _month = date.month;
    _year = date.year;
  }

  DateFieldController(int year, [int month = 1, int day = 1]) {
    if (year < 1 || year > 9999) throw Exception('incorrect year: $year');
    if (month < 1 || month > 12) throw Exception('incorrect month: $month');
    _year = year;
    _month = month;
    this.day = day;
  }

  DateFieldController.fromDateTime(DateTime date) {
    setValues(date);
  }
}

class DateField extends StatefulWidget {
  final DateFieldController controller;

  const DateField({super.key, required this.controller});

  @override
  State<DateField> createState() => _DateFieldState();
}

class _DateFieldState extends State<DateField> {
  final _dayController = TextEditingController(),
      _monthController = TextEditingController(),
      _yearController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    _dayController.dispose();
    _monthController.dispose();
    _yearController.dispose();
  }

  void onChanged(TextEditingController control) {
    if (control.text.isEmpty) {
      control.text = '1';
    }

    int value = int.parse(control.text);
    if (value < 1) {
      value = 1;
      control.text = '1';
    }

    if (control == _dayController) {
      final maxDay = DateDuration.daysInMonth(
          widget.controller.month, widget.controller.year);
      if (value > maxDay) {
        value = maxDay;
        control.text = value.toString();
      }
      widget.controller.day = value;
    } else if (control == _monthController) {
      if (value > 12) {
        value = 12;
        control.text = value.toString();
      }
      widget.controller.month = value;
    } else {
      if (value > 9999) {
        value = 9999;
        control.text = value.toString();
      }
      widget.controller.year = value;
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
    _dayController.text = widget.controller.day.toString();
    _monthController.text = widget.controller.month.toString();
    _yearController.text = widget.controller.year.toString();

    List<Widget> fields = [];

    if (widget.controller.dayFieldIsVisible) {
      fields.add(Templates.field(
        label: 'День',
        child: _createField(_dayController, 40),
      ));
    }

    if (widget.controller.monthFieldIsVisible) {
      fields.add(Templates.field(
        label: 'Місяць',
        child: _createField(_monthController, 40),
      ));
    }

    if (widget.controller.yearFieldIsVisible) {
      fields.add(Templates.field(
        label: 'Рік',
        child: _createField(_yearController, 60),
      ));
    }

    fields = fields.insertSepars(const SizedBox(width: 5));

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: fields,
    );
  }
}
