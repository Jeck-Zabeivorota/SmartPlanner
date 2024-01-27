import 'package:flutter/material.dart';
import 'package:smart_planner/Instruments/validation.dart';
import 'filter.dart';
import '../../Database/Models/item_model.dart';
import '../Widgets/chips.dart';
import '../Widgets/checkbox.dart';
import '../Widgets/time_field.dart';
import '../Widgets/date_field.dart';

class FilterViewModel {
  final void Function(void Function()) onUpdate;

  // bindings

  final ChipsController<Category> categoriesControl = ChipsController(
    chipsData: {
      Category.task: 'Задача',
      Category.holiday: 'Свято',
      Category.birthday: 'День народження',
      Category.notification: 'Оповіщення',
      Category.meet: 'Зустріч',
    },
  );

  final ChipsController<Priority> prioritetsControl = ChipsController(
    chipsData: {
      Priority.low: 'Низький',
      Priority.medium: 'Середній',
      Priority.high: 'Високий',
    },
  );

  final CheckBoxController isStartDateTimeControl = CheckBoxController(),
      isEndDateTimeControl = CheckBoxController();

  final DateFieldController startDateControl =
          DateFieldController.fromDateTime(DateTime.now()),
      endDateControl = DateFieldController.fromDateTime(DateTime.now());
  final TimeFieldController startTimeControl =
          TimeFieldController.fromDateTime(DateTime.now()),
      endTimeControl = TimeFieldController.fromDateTime(DateTime.now());

  final TextEditingController titleControl = TextEditingController();

  final ChipsController<Repead> repeadControl = ChipsController(
    chipsData: {
      Repead.once: 'Один раз',
      Repead.day: 'Кожен день',
      Repead.week: 'Кожен тиждень',
      Repead.month: 'Кожного місяця',
      Repead.year: 'Кожного року',
    },
  );

  // methods

  void save(BuildContext context) {
    DateTime? startDatetime = isStartDateTimeControl.isCheck
        ? DateTime(
            startDateControl.year,
            startDateControl.month,
            startDateControl.day,
            startTimeControl.hour,
            startTimeControl.minute,
          )
        : null;

    DateTime? endDatetime = isEndDateTimeControl.isCheck
        ? DateTime(
            endDateControl.year,
            endDateControl.month,
            endDateControl.day,
            endTimeControl.hour,
            endTimeControl.minute,
          )
        : null;

    if (startDatetime != null &&
        endDatetime != null &&
        startDatetime.isAfter(endDatetime)) {
      Validation.showErrorMessage(
        context,
        'Початкові дата та час випереджає кінцеві дату та час',
      );
      return;
    }

    Filter filter = Filter(
      categories: categoriesControl.activeKeys,
      prioritets: prioritetsControl.activeKeys,
      startDatetime: startDatetime,
      endDatetime: endDatetime,
      title: titleControl.text,
      repeads: repeadControl.activeKeys,
    );

    Navigator.pop(context, filter);
  }

  // Initialization

  FilterViewModel({required this.onUpdate, required Filter filter}) {
    if (filter.isDefault) return;

    categoriesControl.activeKeys.addAll(filter.categories);
    prioritetsControl.activeKeys.addAll(filter.prioritets);
    if (filter.startDatetime != null) {
      isStartDateTimeControl.isCheck = true;
      startDateControl.setValues(filter.startDatetime!);
      startTimeControl.setValues(filter.startDatetime!);
    }
    if (filter.endDatetime != null) {
      isEndDateTimeControl.isCheck = true;
      endDateControl.setValues(filter.endDatetime!);
      endTimeControl.setValues(filter.endDatetime!);
    }
    titleControl.text = filter.title;
    repeadControl.activeKeys.addAll(filter.repeads);

    onUpdate(() {});
  }
}
