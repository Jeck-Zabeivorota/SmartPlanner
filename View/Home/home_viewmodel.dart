import 'package:flutter/material.dart';
import 'package:smart_planner/Database/Models/settings_model.dart';
import '../../Instruments/date_duration.dart';
import '../colors.dart';
import '../../Database/fast_hive.dart';
import '../../Database/Models/item_model.dart';
import '../Widgets/popups.dart';
import 'calendar.dart';
import '../Items/item_view.dart';
import '../Items/items_view.dart';
import '../Widgets/chips.dart';

class HomeViewModel {
  final void Function(void Function()) onUpdate;
  IconData _colorThemeIcon = Icons.dark_mode_outlined;
  List<ItemModel> _items = [], _holidayItems = [], _otherItems = [];
  String _selectedDateTitle = '';

  // bindings

  IconData get colorThemeIcon => _colorThemeIcon;

  final CalendarController calendarControl =
      CalendarController(selectedDate: DateTime.now());

  final ChipsController<int> holidaysControl = ChipsController(
    chipsData: {0: 'Свята'},
  );

  String get selectedDateTitle => _selectedDateTitle;

  List<ItemModel> get selectedDateItems =>
      holidaysControl.isNoOneActive() ? _otherItems : _holidayItems;

  // methods

  void updateModels() async {
    _items = await FastHive.getAll<ItemModel>();
    calendarControl.items = _items;
    updateSelectedDayItems();
  }

  void updateSelectedDayItems() {
    List<ItemModel> items = _items
        .where((item) => item.datetime.isToday(calendarControl.selectedDate))
        .toList();

    _holidayItems = items.where((item) => item.isHolidayOrBirthday).toList();
    _otherItems = items.where((item) => !item.isHolidayOrBirthday).toList();

    _holidayItems.sort((i1, i2) =>
        i1.datetime.nextDateTime.isBefore(i2.datetime.nextDateTime) ? -1 : 1);
    _otherItems.sort((i1, i2) =>
        i1.datetime.nextDateTime.isBefore(i2.datetime.nextDateTime) ? -1 : 1);

    _selectedDateTitle = DateDuration.dateToString(
      calendarControl.selectedDate,
      nowDate: DateTime.now(),
    );

    onUpdate(() {});
  }

  void pushToItemView(BuildContext context, {ItemModel? model}) async {
    bool? isUpdate = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => ItemView(model: model)),
    );
    if (isUpdate == true) updateModels();
  }

  void pushToItemsView(BuildContext context) async {
    bool? isUpdate = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const ItemsView()),
    );

    if (isUpdate == true) updateModels();
  }

  void showRequestDialog(BuildContext context) async {
    String? request = await Popups.getText(context, title: 'Введіть запрос');
    if (request == null || request.isEmpty) return;

    // ignore: use_build_context_synchronously
    bool? isUpdate = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => ItemView(request: request)),
    );

    if (isUpdate == true) updateModels();
  }

  Future<bool> deleteItem(BuildContext context, ItemModel model) async {
    String? response = await Popups.showMessage(
      context,
      title: 'Видалення',
      content: 'Ви впевнені, що хочете видалити?',
      icon: MessageIcon.question,
      actions: ['Ні', 'Так'],
    );
    if (response != 'Так') return false;

    await FastHive.delete(model);
    updateModels();
    return true;
  }

  void changeTheme() async {
    SettingsModel settings =
        await FastHive.get(0, modelIfBoxEmpty: SettingsModel(darkMode: false));

    bool newDarkMode = !settings.darkMode;
    onUpdate(() {
      ViewColors.isDarkMode = newDarkMode;
      _colorThemeIcon = newDarkMode ? Icons.sunny : Icons.dark_mode_outlined;
    });

    settings.darkMode = newDarkMode;
    await FastHive.put(settings);
  }

  // Initialization

  void _setTheme() async {
    SettingsModel settings =
        await FastHive.get(0, modelIfBoxEmpty: SettingsModel(darkMode: false));

    if (!settings.darkMode) return;

    onUpdate(() {
      ViewColors.isDarkMode = settings.darkMode;
      _colorThemeIcon =
          settings.darkMode ? Icons.sunny : Icons.dark_mode_outlined;
    });
  }

  HomeViewModel({required this.onUpdate}) {
    _setTheme();
    updateModels();
  }
}
