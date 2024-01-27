import 'package:flutter/material.dart';
import '../../Instruments/date_duration.dart';
import '../../Database/Models/item_model.dart';
import '../../Database/fast_hive.dart';
import 'item_view.dart';
import '../Filter/filter.dart';
import '../Filter/filter_view.dart';
import '../Widgets/popups.dart';

enum Order { toNew, toOld }

class ItemsViewModel {
  final void Function(void Function()) onUpdate;
  Filter _filter = Filter();
  bool _filterIsDefault = true, _isHomeUpdate = false;
  Order _order = Order.toNew;
  List<ItemModel> _models = [];
  Map<DateTime, List<ItemModel>> _groups = {};

  // bindings

  Map<DateTime, List<ItemModel>> get groups => _groups;
  bool get filterIsDefault => _filterIsDefault;
  Order get order => _order;

  // methods

  void _updateModels() async {
    _models = _filter.filter(await FastHive.getAll<ItemModel>());
    sort();
  }

  void _setGroups() {
    if (_models.isEmpty) {
      onUpdate(() => _groups = {});
      return;
    }

    DateTime currDate = _models[0].datetime.nextDateTime;
    _groups = {currDate: []};

    for (var model in _models) {
      DateTime date = model.datetime.nextDateTime;
      if (DateDuration.compareDates(date, currDate) == 0) {
        _groups[currDate]!.add(model);
        continue;
      }
      currDate = date;
      _groups[date] = [model];
    }

    onUpdate(() {});
  }

  void sort({bool isChangeOrder = false}) {
    if (isChangeOrder) {
      _order = _order == Order.toNew ? Order.toOld : Order.toNew;
    }
    int pos = _order == Order.toNew ? 1 : -1;

    _models.sort((model1, model2) {
      DateTime date1 = model1.datetime.nextDateTime;
      DateTime date2 = model2.datetime.nextDateTime;
      return date1.isBefore(date2) ? -pos : pos;
    });

    _setGroups();
  }

  void pushToItemView(BuildContext context, {ItemModel? model}) async {
    bool? isUpdate = await Navigator.push<bool?>(
      context,
      MaterialPageRoute(builder: (_) => ItemView(model: model)),
    );
    if (isUpdate != true) return;

    _updateModels();
    _isHomeUpdate = true;
  }

  void showRequestDialog(BuildContext context) async {
    String? request = await Popups.getText(context, title: 'Введіть запрос');
    if (request == null || request.isEmpty) return;

    // ignore: use_build_context_synchronously
    bool? isUpdate = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => ItemView(request: request)),
    );
    if (isUpdate != true) return;

    _updateModels();
    _isHomeUpdate = true;
  }

  void pushToFilterView(BuildContext context) async {
    Filter? filter = await Navigator.push<Filter?>(
      context,
      MaterialPageRoute(builder: (_) => FilterView(filter: _filter)),
    );
    if (filter == null) return;

    _filter = filter;
    _filterIsDefault = filter.isDefault;
    _updateModels();
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
    _models.remove(model);

    for (List<ItemModel> list in _groups.values) {
      if (list.remove(model)) break;
    }
    _isHomeUpdate = true;

    return true;
  }

  void pushBack(BuildContext context) => Navigator.pop(context, _isHomeUpdate);

  // Initialization

  ItemsViewModel({required this.onUpdate}) {
    _updateModels();
  }
}
