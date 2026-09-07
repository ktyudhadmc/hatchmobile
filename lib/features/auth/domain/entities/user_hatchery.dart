import 'package:equatable/equatable.dart';

class UserHatchery extends Equatable {
  const UserHatchery({required this.id, required this.name});

  final int id;
  final String name;

  @override
  List<Object?> get props => [id, name];
}
