import 'package:flutter/material.dart';
import 'package:smart_planner/Database/Models/q_state_model.dart';
import '../../Instruments/validation.dart';
import '../../Instruments/nlp.dart';
import '../../Database/fast_hive.dart';
import '../../Database/Models/item_model.dart';
import '../Widgets/chips.dart';
import '../Widgets/time_field.dart';
import '../Widgets/date_field.dart';

class ItemViewModel {
  final void Function(void Function()) onUpdate;
  final int? id;
  QStateModel? state;
  bool _isHolidayOrBirthday = false, _isShowFields = false;

  // bindings

  bool get isShowFields => _isShowFields;

  final TextEditingController titleControl = TextEditingController();

  final ChipsController<Category> categoryControl = ChipsController(
    chipsData: {
      Category.task: 'Задача',
      Category.holiday: 'Свято',
      Category.birthday: 'День народження',
      Category.notification: 'Оповіщення',
      Category.meet: 'Зустріч',
    },
    activeKeys: [Category.task],
  );

  final DateFieldController dateControl =
      DateFieldController.fromDateTime(DateTime.now());
  final TimeFieldController timeControl =
      TimeFieldController.fromDateTime(DateTime.now());

  final ChipsController<Priority> priorityControl = ChipsController(
    chipsData: {
      Priority.low: 'Низький',
      Priority.medium: 'Середній',
      Priority.high: 'Високий',
    },
    activeKeys: [Priority.medium],
    colorActive: priotityColors[Priority.medium],
  );

  final ChipsController<Repead> repeadControl = ChipsController(
    chipsData: {
      Repead.once: 'Один раз',
      Repead.day: 'Кожен день',
      Repead.week: 'Кожен тиждень',
      Repead.month: 'Кожного місяця',
      Repead.year: 'Кожного року',
    },
    activeKeys: [Repead.once],
  );

  bool get isHolidayOrBirthday => _isHolidayOrBirthday;

  // methods

  void changeCategory(Category category) {
    onUpdate(() => _isHolidayOrBirthday =
        category == Category.holiday || category == Category.birthday);
  }

  void setPriorityChipColor(Priority priority) =>
      priorityControl.colorActive = priotityColors[priority];

  void save(BuildContext context) async {
    if (titleControl.text.isEmpty) {
      Validation.showErrorMessage(context, 'Назва не введена');
      return;
    }

    Priority priority =
        _isHolidayOrBirthday ? Priority.none : priorityControl.activeKeys.first;

    if (state != null && priority != Priority.none) {
      state!.updateQ(priority);
      await FastHive.put(state!);
    }

    ItemModel model = ItemModel(
      id: id,
      title: titleControl.text,
      datetime: DateTimeData(
        datetime: DateTime(
          dateControl.year,
          dateControl.month,
          dateControl.day,
          timeControl.hour,
          timeControl.minute,
        ),
        repead:
            _isHolidayOrBirthday ? Repead.year : repeadControl.activeKeys.first,
      ),
      category: categoryControl.activeKeys.first,
      priority: priority,
    );

    await FastHive.put(model);

    // ignore: use_build_context_synchronously
    Navigator.pop(context, true);
  }

  void dispose() {
    titleControl.dispose();
  }

  // Initialization

  Future<void> _setFields({ItemModel? model, String? request}) async {
    _isShowFields = true;

    if (model == null) {
      if (request == null) return;
      NLPResult result = await NLP.getResult(request);
      model = result.model;
      state = result.state;
    }

    titleControl.text = model.title;
    categoryControl.setChip(model.category);
    dateControl.setValues(model.datetime.nextDateTime);
    timeControl.hour = model.datetime.hour;
    timeControl.minute = model.datetime.minute;

    _isHolidayOrBirthday = model.isHolidayOrBirthday;
    if (!_isHolidayOrBirthday) {
      priorityControl.setChip(model.priority);
      repeadControl.setChip(model.datetime.repead);
      setPriorityChipColor(model.priority);
    }
  }

  ItemViewModel({required this.onUpdate, ItemModel? model, String? request})
      : id = model?.id {
    _setFields(model: model, request: request).then((_) => onUpdate(() {}));
  }
}
