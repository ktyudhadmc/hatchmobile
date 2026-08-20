import 'package:equatable/equatable.dart';
import 'package:hatchmobile/features/auth/domain/entities/user_hatchery.dart';
import 'package:hatchmobile/features/auth/domain/entities/user_role.dart';

class User extends Equatable {
  const User({
    required this.id,
    required this.name,
    required this.role,
    required this.hatchery,
  });

  final int id;
  final String name;
  final UserRole role;
  final UserHatchery hatchery;

  @override
  List<Object?> get props => [id, name];
}
