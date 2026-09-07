import 'package:hatchmobile/features/auth/domain/entities/user_hatchery.dart';

class UserHatcheryModel extends UserHatchery {
  const UserHatcheryModel({required super.id, required super.name});

  factory UserHatcheryModel.fromJson(Map<String, dynamic> json) {
    return UserHatcheryModel(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }
}
