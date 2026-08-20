import 'package:equatable/equatable.dart';

class UserRole extends Equatable {
  const UserRole({required this.id, required this.name});

  final int id;
  final String name;

  @override
  List<Object?> get props => [id, name];
}
