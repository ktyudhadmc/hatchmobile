import 'package:hatchmobile/features/auth/domain/entities/user_role.dart';

class UserRoleModel extends UserRole {
  const UserRoleModel({required super.id, required super.name});

  factory UserRoleModel.fromJson(Map<String, dynamic> json) {
    return UserRoleModel(id: json['id'] as int, name: json['name'] as String);
  }
}
