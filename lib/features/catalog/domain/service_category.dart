import 'package:flutter/foundation.dart';

/// One row of the admin-owned `ServiceCategory` master, read from the public
/// `GET /categories`.
///
/// Page 15's specialty tiles are these rows since 19-11-2026 (client) — they
/// used to be ten hard-coded entries in `specialty.dart`, which drifted from
/// the catalogue the admin actually sells.
///
/// **[name] is what the profile stores.** `InstructorProfile.specialisations`
/// is a `String[]`, so the tile writes the category's name, not its id; the
/// admin trainer table then reads those names straight out. Renaming a
/// category therefore orphans what trainers already picked — flagged for the
/// client in `worklog/2026-11-19.md`.
@immutable
class ServiceCategory {
  const ServiceCategory({
    required this.id,
    required this.name,
    this.icon,
    this.description,
    this.serviceCount = 0,
  });

  final String id;
  final String name;

  /// An emoji or glyph the admin set; null means the tile draws its own.
  final String? icon;
  final String? description;
  final int serviceCount;

  factory ServiceCategory.fromJson(Map<String, dynamic> json) {
    return ServiceCategory(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      icon: json['icon'] as String?,
      description: json['description'] as String?,
      serviceCount:
          (json['_count'] as Map<String, dynamic>?)?['services'] as int? ?? 0,
    );
  }

  /// Falls back to the generic glyph when the admin has not set one, so a
  /// freshly added category is never a blank tile.
  String get symbol => (icon == null || icon!.isEmpty) ? '🏋️' : icon!;

  /// The tile's second line. The HTML had a hand-written caption per tile;
  /// the master's own description replaces it, and when there is none the
  /// service count is the honest thing to show.
  String get caption {
    if (description != null && description!.trim().isNotEmpty) {
      return description!.trim();
    }
    return serviceCount == 1 ? '1 service' : '$serviceCount services';
  }
}
