import 'package:flutter_test/flutter_test.dart';
import 'package:hatchmobile/features/auth/data/models/user_model.dart';
import 'package:hatchmobile/features/auth/domain/entities/user_hatchery.dart';
import 'package:hatchmobile/features/auth/domain/entities/user_role.dart';

void main() {
  group('UserModel.fromJson', () {
    test('maps id, the Indonesian "nama" key, role, and hatchery access', () {
      final user = UserModel.fromJson({
        'id': 1,
        'nama': 'Budi Santoso',
        'role': {'id': 2, 'name': 'Admin'},
        'access': {'id': 3, 'name': 'Hatchery A'},
      });

      expect(user.id, 1);
      expect(user.name, 'Budi Santoso');
      expect(user.role.id, 2);
      expect(user.role.name, 'Admin');
      expect(user.hatchery.id, 3);
      expect(user.hatchery.name, 'Hatchery A');
    });
  });

  group('UserModel.toJson', () {
    test('uses the same keys as fromJson, so the local cache round-trips', () {
      const user = UserModel(
        id: 7,
        name: 'Siti',
        role: UserRole(id: 2, name: 'Admin'),
        hatchery: UserHatchery(id: 3, name: 'Hatchery A'),
      );

      final restored = UserModel.fromJson(user.toJson());

      expect(restored.id, user.id);
      expect(restored.name, user.name);
      expect(restored.role.id, user.role.id);
      expect(restored.role.name, user.role.name);
      expect(restored.hatchery.id, user.hatchery.id);
      expect(restored.hatchery.name, user.hatchery.name);
    });
  });
}
