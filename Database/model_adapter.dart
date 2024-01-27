import 'package:hive/hive.dart';
import 'i_model.dart';
import 'Models/settings_model.dart';
import 'Models/item_model.dart';
import 'Models/q_state_model.dart';

class ModelAdapter<T extends IModel> extends TypeAdapter<T> {
  @override
  final int typeId;

  static const Map<Type, dynamic Function(Map<String, dynamic>)> constructors =
      {
    SettingsModel: SettingsModel.fromMap,
    ItemModel: ItemModel.fromMap,
    QStateModel: QStateModel.fromMap,
  };

  @override
  T read(BinaryReader reader) =>
      constructors[T]!(Map<String, dynamic>.from(reader.readMap()));

  @override
  void write(BinaryWriter writer, T obj) => writer.writeMap(obj.toMap());

  ModelAdapter({required this.typeId});
}
