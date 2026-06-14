import '../../../core/i18n/localized_text.dart';

class LocalizedEntity {
  final String id;
  final LocalizedText name;

  const LocalizedEntity({
    required this.id,
    required this.name,
  });

  factory LocalizedEntity.fromJson(Map<String, dynamic> json) {
    return LocalizedEntity(
      id: json['id'] ?? '',
      name: LocalizedText.fromJson(json['name'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name.toJson(),
    };
  }
}
