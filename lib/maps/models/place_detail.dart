import 'package:maps_core/maps/extensions/extensions.dart';
import 'package:maps_core/maps/models/models.dart';

class DetailPlace extends Place {
  final String? adrAddress;
  final String? formattedAddress;
  final Geometry? geometry;
  final String? icon;
  final String? name;
  final OpeningHours? openingHours;
  final PlusCode? plusCode;
  final int? priceLevel;
  final double? rating;
  final List<String>? types;
  final int? userRatingTotal;
  final String? vicinity;

  DetailPlace(String id, {
    this.adrAddress,
    this.formattedAddress,
    this.geometry,
    this.icon,
    this.name,
    this.openingHours,
    this.plusCode,
    this.priceLevel,
    this.rating,
    this.types,
    this.userRatingTotal,
    this.vicinity,
  }) : super(id);

  factory DetailPlace.fromJson(Map<String, dynamic> json) {
    final String id = json['place_id'] ?? '';
    final String? adrAddress = json['adr_address'];
    final String? formattedAddress = json['formatted_address'];
    final Geometry geometry = Geometry.fromJson(json['geometry']);
    final String? icon = json['icon'];
    final String? name = json['name'];
    final OpeningHours openingHours =
    OpeningHours.fromJson(json['opening_hours']);
    final PlusCode plusCode = PlusCode.fromJson(json['plus_code']);
    final int? priceLevel = json['price_level'];
    final double? rating = json['rating'];
    final List<String>? types = (json['types'] as List?)?.asListOf<String>();
    final int? userRatingTotal = json['user_rating_total'];
    final String? vicinity = json['vicinity'];
    return DetailPlace(id, adrAddress: adrAddress,
      formattedAddress: formattedAddress,
      geometry: geometry,
      icon: icon,
      name: name,
      openingHours: openingHours,
      plusCode: plusCode,
      priceLevel: priceLevel,
      rating: rating,
      types: types,
      userRatingTotal: userRatingTotal,
      vicinity: vicinity,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'place_id': id,
      'adr_address': adrAddress,
      'formatted_address': formattedAddress,
      'geometry': geometry?.toJson(),
      'icon': icon,
      'name': name,
      'opening_hours': openingHours?.toJson(),
      'plus_code': plusCode?.toJson(),
      'price_level': priceLevel,
      'rating': rating,
      'types': types,
      'user_rating_total': userRatingTotal,
      'vicinity': vicinity,
    };
  }
}

class DetailPlaceGoogle extends DetailPlace {
  final List<AddressComponent>? addressComponents;
  final String? googleMapsUri;
  final String? websiteUri;
  final int? utcOffsetMinutes;
  final String? iconMaskBaseUri;
  final String? iconBackgroundColor;
  final DisplayName? displayName;
  final String? shortFormattedAddress;
  final List<Photo>? photos;
  final bool? pureServiceAreaBusiness;
  final GoogleMapsLinks? googleMapsLinks;
  final TimeZone? timeZone;

  DetailPlaceGoogle(String id, {
    super.adrAddress,
    this.addressComponents,
    super.formattedAddress,
    super.geometry,
    super.icon,
    super.name,
    super.openingHours,
    super.plusCode,
    super.priceLevel,
    super.rating,
    super.types,
    super.userRatingTotal,
    super.vicinity,
    this.googleMapsUri,
    this.websiteUri,
    this.utcOffsetMinutes,
    this.iconMaskBaseUri,
    this.iconBackgroundColor,
    this.displayName,
    this.shortFormattedAddress,
    this.photos,
    this.pureServiceAreaBusiness,
    this.googleMapsLinks,
    this.timeZone,
  }) : super(id);

  factory DetailPlaceGoogle.fromJson(Map<String, dynamic> json) {
    final Geometry? geometry = Geometry(
      location: LatLng.fromJson(json['location']),
      viewPort: ViewPort.fromJson(json['viewport']),
    );
    final String id = json['id'] ?? '';
    final List<AddressComponent>? addressComponents = (json['addressComponents'] as List?)?.map((e) => AddressComponent.fromJson(e as Map<String, dynamic>)).toList();
    final String? googleMapsUri = json['googleMapsUri'];
    final String? websiteUri = json['websiteUri'];
    final int? utcOffsetMinutes = json['utcOffsetMinutes'];
    final String? iconMaskBaseUri = json['iconMaskBaseUri'];
    final String? iconBackgroundColor = json['iconBackgroundColor'];
    final DisplayName? displayName = json['displayName'] != null ? DisplayName.fromJson(json['displayName'] as Map<String, dynamic>) : null;
    final String? shortFormattedAddress = json['shortFormattedAddress'];
    final List<Photo>? photos = (json['photos'] as List?)?.map((e) => Photo.fromJson(e as Map<String, dynamic>)).toList();
    final bool? pureServiceAreaBusiness = json['pureServiceAreaBusiness'];
    final GoogleMapsLinks? googleMapsLinks = json['googleMapsLinks'] != null ? GoogleMapsLinks.fromJson(json['googleMapsLinks'] as Map<String, dynamic>) : null;
    final TimeZone? timeZone = json['timeZone'] != null ? TimeZone.fromJson(json['timeZone'] as Map<String, dynamic>) : null;

    return DetailPlaceGoogle(
      id,
      adrAddress: json['adr_address'],
      formattedAddress: json['formattedAddress'],
      geometry: geometry,
      icon: json['icon'],
      name: json['name'],
      openingHours: json['openingHours'] != null ? OpeningHours.fromJson(json['openingHours'] as Map<String, dynamic>) : null,
      plusCode: json['plusCode'] != null ? PlusCode.fromJson(json['plusCode'] as Map<String, dynamic>) : null,
      priceLevel: json['priceLevel'],
      rating: (json['rating'] as num?)?.toDouble(),
      types: (json['types'] as List?)?.cast<String>(),
      userRatingTotal: json['userRatingTotal'],
      vicinity: json['vicinity'],
      addressComponents: addressComponents,
      googleMapsUri: googleMapsUri,
      websiteUri: websiteUri,
      utcOffsetMinutes: utcOffsetMinutes,
      iconMaskBaseUri: iconMaskBaseUri,
      iconBackgroundColor: iconBackgroundColor,
      displayName: displayName,
      shortFormattedAddress: shortFormattedAddress,
      photos: photos,
      pureServiceAreaBusiness: pureServiceAreaBusiness,
      googleMapsLinks: googleMapsLinks,
      timeZone: timeZone,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'place_id': id,
      'adr_address': adrAddress,
      'formatted_address': formattedAddress,
      'geometry': geometry?.toJson(),
      'icon': icon,
      'name': name,
      'opening_hours': openingHours?.toJson(),
      'plus_code': plusCode?.toJson(),
      'price_level': priceLevel,
      'rating': rating,
      'types': types,
      'user_rating_total': userRatingTotal,
      'vicinity': vicinity,
      'addressComponents': addressComponents?.map((e) => e.toJson()).toList(),
      'googleMapsUri': googleMapsUri,
      'websiteUri': websiteUri,
      'utcOffsetMinutes': utcOffsetMinutes,
      'iconMaskBaseUri': iconMaskBaseUri,
      'iconBackgroundColor': iconBackgroundColor,
      'displayName': displayName?.toJson(),
      'shortFormattedAddress': shortFormattedAddress,
      'photos': photos?.map((e) => e.toJson()).toList(),
      'pureServiceAreaBusiness': pureServiceAreaBusiness,
      'googleMapsLinks': googleMapsLinks?.toJson(),
      'timeZone': timeZone?.toJson(),
    };
  }
}


class LocalizedText {
  final String? text;
  final String? languageCode;

  LocalizedText({this.text, this.languageCode});

  factory LocalizedText.fromJson(Map<String, dynamic> json) {
    return LocalizedText(
      text: json['text'],
      languageCode: json['languageCode'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'text': text, 'languageCode': languageCode};
  }
}

class AuthorAttribution {
  final String? displayName;
  final String? uri;
  final String? photoUri;

  AuthorAttribution({this.displayName, this.uri, this.photoUri});

  factory AuthorAttribution.fromJson(Map<String, dynamic> json) {
    return AuthorAttribution(
      displayName: json['displayName'],
      uri: json['uri'],
      photoUri: json['photoUri'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'displayName': displayName, 'uri': uri, 'photoUri': photoUri};
  }
}

class Photo {
  final String? name;
  final int? widthPx;
  final int? heightPx;
  final List<AuthorAttribution>? authorAttributions;
  final String? flagContentUri;
  final String? googleMapsUri;

  Photo({
    this.name,
    this.widthPx,
    this.heightPx,
    this.authorAttributions,
    this.flagContentUri,
    this.googleMapsUri,
  });

  factory Photo.fromJson(Map<String, dynamic> json) {
    return Photo(
      name: json['name'],
      widthPx: json['widthPx'],
      heightPx: json['heightPx'],
      authorAttributions: (json['authorAttributions'] as List?)
          ?.map((e) => AuthorAttribution.fromJson(e as Map<String, dynamic>))
          .toList(),
      flagContentUri: json['flagContentUri'],
      googleMapsUri: json['googleMapsUri'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'widthPx': widthPx,
      'heightPx': heightPx,
      'authorAttributions': authorAttributions?.map((e) => e.toJson()).toList(),
      'flagContentUri': flagContentUri,
      'googleMapsUri': googleMapsUri,
    };
  }
}

class GoogleMapsLinks {
  final String? directionsUri;
  final String? placeUri;
  final String? photosUri;

  GoogleMapsLinks({this.directionsUri, this.placeUri, this.photosUri});

  factory GoogleMapsLinks.fromJson(Map<String, dynamic> json) {
    return GoogleMapsLinks(
      directionsUri: json['directionsUri'],
      placeUri: json['placeUri'],
      photosUri: json['photosUri'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'directionsUri': directionsUri, 'placeUri': placeUri, 'photosUri': photosUri};
  }
}

class TimeZone {
  final String? id;

  TimeZone({this.id});

  factory TimeZone.fromJson(Map<String, dynamic> json) {
    return TimeZone(id: json['id']);
  }

  Map<String, dynamic> toJson() {
    return {'id': id};
  }
}

class DisplayName {
  final String? text;
  final String? languageCode;

  DisplayName({this.text, this.languageCode});

  factory DisplayName.fromJson(Map<String, dynamic> json) {
    return DisplayName(
      text: json['text'] as String?,
      languageCode: json['languageCode'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'languageCode': languageCode,
    };
  }
}
