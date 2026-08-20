import 'package:hatchmobile/features/auth/data/models/user_hatchery_model.dart';
import 'package:hatchmobile/features/auth/data/models/user_role_model.dart';

import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.name,
    required super.role,
    required super.hatchery,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['nama'] as String,
      role: UserRoleModel.fromJson(json['role'] as Map<String, dynamic>),
      hatchery: UserHatcheryModel.fromJson(
        json['access'] as Map<String, dynamic>,
      ),
    );
  }

  /// Only used to serialize for the local session cache (see
  /// AuthLocalDatasource.saveSession) — keep the keys in sync with
  /// [fromJson] ('nama'/'role'/'access', matching the backend's login
  /// response), not the backend's own field naming for any outgoing request.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': name,
      'role': {'id': role.id, 'name': role.name},
      'access': {'id': hatchery.id, 'name': hatchery.name},
    };
  }
}
