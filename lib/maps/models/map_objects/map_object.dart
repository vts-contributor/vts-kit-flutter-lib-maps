import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:maps_core/maps.dart';

/// Uniquely identifies object an among [CoreMap] collections of a specific
/// type.
///
/// This does not have to be globally unique, only unique among the collection.
@immutable
class MapObjectId<T> {
  /// Creates an immutable object representing a [T] among [GoogleMap] Ts.
  ///
  /// An [AssertionError] will be thrown if [value] is null.
  const MapObjectId(this.value);

  /// The value of the id.
  final String value;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is MapObjectId<T> && value == other.value;
  }

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() {
    return '${objectRuntimeType(this, 'MapsObjectId')}($value)';
  }
}

abstract class MapObject<T> {
  MapObjectId<T> get id;
  int get zIndex;
}