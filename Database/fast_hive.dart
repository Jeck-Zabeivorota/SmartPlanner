import 'package:hive/hive.dart';
import 'i_model.dart';
//
import 'Models/settings_model.dart';
import 'Models/item_model.dart';
import 'Models/q_state_model.dart';

/// Class for quick work with the database (Hive)
abstract class FastHive {
  static const Map<Type, String> boxesNames = {
    SettingsModel: 'settings',
    ItemModel: 'items',
    QStateModel: 'q_states'
  };

  static int getFirstFreeId(LazyBox box) {
    int id = -1;

    while (++id < box.length) {
      if (!box.containsKey(id)) return id;
    }
    return id;
  }

  static Future<void> put<T extends IModel>(T model) async {
    var box = await Hive.openLazyBox<T>(boxesNames[T]!);
    model.id ??= getFirstFreeId(box);
    await box.put(model.id, model);
    await box.close();
  }

  static Future<void> putAll<T extends IModel>(List<T> models) async {
    var box = await Hive.openLazyBox<T>(boxesNames[T]!);
    for (var model in models) {
      model.id ??= getFirstFreeId(box);
      await box.put(model.id!, model);
    }
    await box.close();
  }

  static Future<T> get<T extends IModel>(int id, {T? modelIfBoxEmpty}) async {
    var box = await Hive.openLazyBox<T>(boxesNames[T]!);

    if (box.isEmpty && modelIfBoxEmpty != null) {
      modelIfBoxEmpty.id ??= 0;
      await box.put(modelIfBoxEmpty.id, modelIfBoxEmpty);
      await box.close();
      return modelIfBoxEmpty;
    }

    T model = (await box.get(id))!;
    await box.close();

    return model;
  }

  static Future<List<T>> getAll<T extends IModel>() async {
    var box = await Hive.openBox<T>(boxesNames[T]!);
    List<T> models = box.values.toList();
    await box.close();
    return models;
  }

  static Future<void> delete<T extends IModel>(T model) async {
    if (model.id == null) return;
    var box = await Hive.openLazyBox<T>(boxesNames[T]!);
    await box.delete(model.id);
    await box.close();
  }

  static Future<void> deleteAt<T extends IModel>(int id) async {
    var box = await Hive.openLazyBox<T>(boxesNames[T]!);
    await box.delete(id);
    await box.close();
  }

  static Future<bool> exists<T extends IModel>(int id) async {
    var box = await Hive.openLazyBox<T>(boxesNames[T]!);
    bool isExists = box.containsKey(id);
    await box.close();
    return isExists;
  }

  static Future<Box<T>> openBox<T extends IModel>() async =>
      await Hive.openBox<T>(boxesNames[T]!);

  static Future<LazyBox<T>> openLazyBox<T extends IModel>() async =>
      await Hive.openLazyBox<T>(boxesNames[T]!);
}
