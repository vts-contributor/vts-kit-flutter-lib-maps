import 'package:maps_core/maps/extensions/extensions.dart';
import 'package:maps_core/maps/models/models.dart';

class GeocodingPlace extends Place {
  final String? formattedAddress;
  final Geometry? geometry;
  final PlusCode? plusCode;
  final List<AddressComponent>? addressComponents;

  GeocodingPlace(
      String id, {
        this.formattedAddress,
        this.geometry,
        this.plusCode,
        this.addressComponents,
      }) : super(id);

  factory GeocodingPlace.fromJson(Map<String, dynamic> json) {
    final id = json['place_id'] ?? '';
    final formattedAddress = json['formatted_address'];
    final geometry =
    json['geometry'] != null ? Geometry.fromJson(json['geometry']) : null;
    final addressComponents = (json['address_components'] as List?)
        ?.map((e) => AddressComponent.fromJson(e as Map<String, dynamic>))
        .toList();
    final plusCode =
    json['plus_code'] != null ? PlusCode.fromJson(json['plus_code']) : null;
    return GeocodingPlace(
      id,
      formattedAddress: formattedAddress,
      geometry: geometry,
      plusCode: plusCode,
      addressComponents: addressComponents,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'place_id': id,
      'formatted_address': formattedAddress,
      'geometry': geometry?.toJson(),
      'plus_code': plusCode?.toJson(),
      'address_components':
      addressComponents?.map((e) => e.toJson()).toList(),
    };
  }

  static List<GeocodingPlace> parseListGeocoding(
      List<Map<String, dynamic>> json) {
    if (json.isEmpty) {
      return [];
    }
    return (json as List<dynamic>)
        .map((e) => GeocodingPlace.fromJson(e))
        .toList();
  }
}

class GeocodingPlaceGoogle extends GeocodingPlace {
  final List<String>? types;

  GeocodingPlaceGoogle(
      String id, {
        super.formattedAddress,
        super.geometry,
        super.plusCode,
        super.addressComponents,
        this.types,
      }) : super(id);

  factory GeocodingPlaceGoogle.fromJson(Map<String, dynamic> json) {
    final base = GeocodingPlace.fromJson(json);
    final types = (json['types'] as List?)?.asListOf<String>();
    return GeocodingPlaceGoogle(
      base.id,
      formattedAddress: base.formattedAddress,
      geometry: base.geometry,
      plusCode: base.plusCode,
      addressComponents: base.addressComponents,
      types: types,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'types': types,
    };
  }

  static List<GeocodingPlaceGoogle> parseListGeocoding(
      List<Map<String, dynamic>> json) {
    if (json.isEmpty) {
      return [];
    }
    return (json as List<dynamic>)
        .map((e) => GeocodingPlaceGoogle.fromJson(e))
        .toList();
  }
}