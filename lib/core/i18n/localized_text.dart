class LocalizedText {
  final String en;
  final String es;

  const LocalizedText({
    required this.en,
    required this.es,
  });

  factory LocalizedText.fromJson(Map<String, dynamic> json) {
    return LocalizedText(
      en: json['en'] ?? '',
      es: json['es'] ?? json['en'] ?? '',
    );
  }

  String value(String languageCode) {
    if (languageCode == 'es') return es;
    return en;
  }

  Map<String, dynamic> toJson() {
    return {
      'en': en,
      'es': es,
    };
  }
}
