import '../i_model.dart';

class SettingsModel implements IModel {
  @override
  int? id;
  late bool darkMode;

  @override
  Map<String, dynamic> toMap() => {
        'id': id,
        'darkMode': darkMode,
      };

  @override
  SettingsModel.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    darkMode = map['darkMode'];
  }

  SettingsModel({
    this.id,
    this.darkMode = false,
  });
}
