abstract class IModel {
  late int? id;
  Map<String, dynamic> toMap();
  IModel.fromMap(Map<String, dynamic> map);
}
