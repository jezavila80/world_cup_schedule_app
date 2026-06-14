import 'package:flutter/material.dart';

enum FlagPattern {
  verticalStripes,
  horizontalStripes,
  solidCircle,
  centeredCircle,
  cross,
  diagonalApproximation,
  complexApproximation,
}

class FlagStyle {
  final String teamId;
  final String displayName;
  final String fifaCode;
  final String iso2Code;
  final List<Color> flagColors;
  final String orientation;
  final FlagPattern pattern;
  final String notes;

  const FlagStyle({
    required this.teamId,
    required this.displayName,
    required this.fifaCode,
    required this.iso2Code,
    required this.flagColors,
    required this.orientation,
    required this.pattern,
    required this.notes,
  });

  factory FlagStyle.fromJson(Map<String, dynamic> json) {
    Color hexToColor(String hex) {
      final buffer = StringBuffer();
      if (hex.length == 6 || hex.length == 7) buffer.write('ff');
      buffer.write(hex.replaceFirst('#', ''));
      return Color(int.parse(buffer.toString(), radix: 16));
    }

    final colorsList = (json['flagColors'] as List<dynamic>)
        .map((c) => hexToColor(c as String))
        .toList();

    FlagPattern parsePattern(String p) {
      switch (p) {
        case 'verticalStripes':
          return FlagPattern.verticalStripes;
        case 'horizontalStripes':
          return FlagPattern.horizontalStripes;
        case 'solidCircle':
          return FlagPattern.solidCircle;
        case 'centeredCircle':
          return FlagPattern.centeredCircle;
        case 'cross':
          return FlagPattern.cross;
        case 'diagonalApproximation':
          return FlagPattern.diagonalApproximation;
        case 'complexApproximation':
        default:
          return FlagPattern.complexApproximation;
      }
    }

    return FlagStyle(
      teamId: json['teamId'] as String,
      displayName: json['displayName'] as String,
      fifaCode: json['fifaCode'] as String,
      iso2Code: json['iso2Code'] as String,
      flagColors: colorsList,
      orientation: json['orientation'] as String,
      pattern: parsePattern(json['pattern'] as String),
      notes: json['notes'] as String? ?? '',
    );
  }
}
