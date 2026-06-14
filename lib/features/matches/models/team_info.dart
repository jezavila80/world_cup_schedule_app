import '../../../core/i18n/localized_text.dart';

class TeamInfo {
  final String id;
  final String fifaCode;
  final LocalizedText name;

  const TeamInfo({
    required this.id,
    required this.fifaCode,
    required this.name,
  });

  factory TeamInfo.fromJson(Map<String, dynamic> json) {
    return TeamInfo(
      id: json['id'] ?? '',
      fifaCode: json['fifaCode'] ?? '',
      name: LocalizedText.fromJson(json['name'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fifaCode': fifaCode,
      'name': name.toJson(),
    };
  }
}
