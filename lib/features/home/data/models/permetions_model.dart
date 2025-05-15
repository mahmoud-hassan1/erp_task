import 'package:erp_task/features/home/domain/entities/permissions.dart';

class PermissionsModel extends Permissions {
  const PermissionsModel({
    required super.edit,
    required super.view,
  });

  factory PermissionsModel.fromJson(Map<String, dynamic> json) {

    return PermissionsModel(
      edit: List<String>.from(json['edit'] as List),
      view: List<String>.from(json['view'] as List),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'edit': edit,
      'view': view,
    };
  }
}
