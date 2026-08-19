import 'package:flutter_test/flutter_test.dart';
import 'package:hatchmobile/features/auth/data/models/user_model.dart';

void main() {
  group('UserModel.fromJson', () {
    test('maps id and the Indonesian "nama" key to name', () {
      final user = UserModel.fromJson({'id': 1, 'nama': 'Budi Santoso'});

      expect(user.id, 1);
      expect(user.name, 'Budi Santoso');
    });
  });

  group('UserModel.toJson', () {
    test('round-trips id and name under English keys', () {
      const user = UserModel(id: 7, name: 'Siti');

      expect(user.toJson(), {'id': 7, 'name': 'Siti'});
    });
  });
}
