import 'package:uuid/uuid.dart';

const _uuid = Uuid();

/// Gets the initials of a name, e.g. "Budi Santoso" -> "BS".
String initialFormatter(String name) {
  final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
  if (parts.isEmpty) return '';
  if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
  return (parts.first.substring(0, 1) + parts.last.substring(0, 1)).toUpperCase();
}

/// Generates a client-side unique id, useful for offline-first records that
/// need an id before they've been synced to the server.
String generateLocalId() => _uuid.v4();

double? parseDouble(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}
