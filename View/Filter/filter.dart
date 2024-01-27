import '../../extension_methods.dart';
import '../../Database/Models/item_model.dart';

class Filter {
  final List<Category> categories;
  final List<Priority> prioritets;
  final DateTime? startDatetime, endDatetime;
  final String title;
  final List<Repead> repeads;

  Filter({
    this.categories = const [],
    this.prioritets = const [],
    this.startDatetime,
    this.endDatetime,
    String? title,
    this.repeads = const [],
  }) : title = title ?? '';

  bool get isDefault =>
      categories.isEmpty &&
      prioritets.isEmpty &&
      startDatetime == null &&
      endDatetime == null &&
      title.isEmpty &&
      repeads.isEmpty;

  List<ItemModel> filter(List<ItemModel> models) {
    List<ItemModel> result = [];

    if (isDefault) {
      result.addAll(models);
      return result;
    }

    for (var model in models) {
      if (categories.isNotEmpty && categories.contains(model.category)) {
        result.add(model);
        continue;
      }
      if (prioritets.isNotEmpty && prioritets.contains(model.priority)) {
        result.add(model);
        continue;
      }
      if (startDatetime != null || endDatetime != null) {
        DateTime dt = model.datetime.nextDateTime;
        if ((startDatetime == null || dt >= startDatetime!) &&
            (endDatetime == null || dt <= endDatetime!)) {
          result.add(model);
          continue;
        }
      }
      if (title.isNotEmpty && model.title.contains(title)) {
        result.add(model);
        continue;
      }
      if (repeads.isNotEmpty && repeads.contains(model.datetime.repead)) {
        result.add(model);
      }
    }

    return result;
  }
}
