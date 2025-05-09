class StructuredFormatting {
  final String? mainText;
  final String? secondaryText;

  StructuredFormatting({
    this.mainText,
    this.secondaryText,
  });

  factory StructuredFormatting.fromJson(Map<String, dynamic>? json) {
    final mainText = json?['main_text'];
    final secondaryText = json?['secondary_text'];
    return StructuredFormatting(
      mainText: mainText,
      secondaryText: secondaryText,
    );
  }

  factory StructuredFormatting.fromJsonGoogle(Map<String, dynamic>? json) {
    final mainText = json?['mainText']['text'];
    final secondaryText = json?['secondaryText']['text'];
    return StructuredFormatting(
      mainText: mainText,
      secondaryText: secondaryText,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'main_text': mainText,
      'secondary_text': secondaryText,
    };
  }
}
