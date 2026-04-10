import 'package:maps_core/maps/extensions/extensions.dart';
import 'package:maps_core/maps/models/models.dart';

class AutocompletePlace extends Place {
  final String? description;
  final StructuredFormatting? structuredFormatting;
  final List<Term>? terms;
  final List<String>? types;

  AutocompletePlace(
    String placeId, {
    this.description,
    this.structuredFormatting,
    this.terms,
    this.types,
  }) : super(placeId);

  factory AutocompletePlace.fromJson(Map<String, dynamic> json) {
    final String id = json['place_id'] ?? '';
    final String? description = json['description'];
    final StructuredFormatting structuredFormatting =
        StructuredFormatting.fromJson(json['structured_formatting']);
    final List<Term>? terms = (json['terms'] as List?)?.map((e) {
      final json = e as Map<String, dynamic>;
      return Term.fromJson(json);
    }).toList();
    final List<String>? types = (json['types'] as List?)?.asListOf<String>();
    return AutocompletePlace(
      id,
      description: description,
      structuredFormatting: structuredFormatting,
      terms: terms,
      types: types,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'place_id': id,
      'description': description,
      'structured_formatting': structuredFormatting?.toJson(),
      'terms': terms?.map((e) => e.toJson()).toList(),
      'types': types,
    };
  }
}


class AutocompletePlaceGoogle extends AutocompletePlace {
  final String? placeReference;

  AutocompletePlaceGoogle(
      String placeId, {
        super.description,
        super.structuredFormatting,
        super.terms,
        super.types,
        this.placeReference,
      }) : super(placeId);

  factory AutocompletePlaceGoogle.fromJson(Map<String, dynamic> json) {
    final placePrediction = json['placePrediction'];
    final String id = placePrediction['placeId'] ?? '';
    final StructuredFormatting? structuredFormatting =
    placePrediction['structuredFormat'] != null
        ? StructuredFormatting.fromJsonGoogle(placePrediction['structuredFormat'])
        : null;
    final List<String>? types =
    (placePrediction['types'] as List?)?.asListOf<String>();
    final String? placeReference = placePrediction['place'];

    return AutocompletePlaceGoogle(
      id,
      description: placePrediction['text']?['text'],
      structuredFormatting: structuredFormatting,
      types: types,
      placeReference: placeReference,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'place_id': id,
      'description': description,
      'structured_formatting': structuredFormatting?.toJson(),
      'terms': terms?.map((e) => e.toJson()).toList(),
      'types': types,
      'place_reference': placeReference,
    };
  }

  static List<AutocompletePlaceGoogle> parseListGoogle(
      List<Map<String, dynamic>> json) {
    if (json.isEmpty) {
      return [];
    }
    return (json as List<dynamic>)
        .map((e) => AutocompletePlaceGoogle.fromJson(e))
        .toList();
  }

  static googleAutocompleteParamsMapper(
      Map<String, dynamic> params) {
    String lat = params['location']?.substring(0, params['location'].indexOf(','));
    String lng = params['location']?.substring(params['location'].indexOf(',') + 1).trim();
    return {
      'input': params['input'],
      'locationBias': {
        'circle': {
          'center': {
            'latitude': lat,
            'longitude': lng,
          },
          'radius': params['radius'],
        },
      },
    };
  }
}
