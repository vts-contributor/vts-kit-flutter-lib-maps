import 'dart:convert';
import 'dart:math' as math;
import 'package:fixnum/fixnum.dart';
import 'package:flutter/cupertino.dart';
import 'package:maps_core/maps.dart';

///src code: https://github.com/everton-e26/polyline_codec/blob/master/pubspec.yaml
class PolylineCodec {
  PolylineCodec._();

  static const _defaultPrecision = 5;

  static num _py2Round(num value) {
    return (value.abs() + 0.5).floor() * (value >= 0 ? 1 : -1);
  }

  static String _encode(num current, num previous, num factor) {
    current = _py2Round(current * factor);
    previous = _py2Round(previous * factor);
    Int32 coordinate = Int32(current as int) - Int32(previous as int) as Int32;
    coordinate <<= 1;
    if (current - previous < 0) {
      coordinate = ~coordinate;
    }
    var output = "";
    while (coordinate >= Int32(0x20)) {
      try {
        Int32 v = (Int32(0x20) | (coordinate & Int32(0x1f))) + 63 as Int32;
        output += String.fromCharCodes([v.toInt()]);
      } catch (err) {
        debugPrint(err.toString());
      }
      coordinate >>= 5;
    }
    output += ascii.decode([coordinate.toInt() + 63]);
    return output;
  }

  static List<LatLng> decode(String str, {int precision = _defaultPrecision}) {
    final List<LatLng> coordinates = [];

    var index = 0,
        lat = 0,
        lng = 0,
        shift = 0,
        result = 0,
        factor = math.pow(10, precision);

    int? latitudeChange, longitudeChange, byte;

    // Coordinates have variable length when encoded, so just keep
    // track of whether we've hit the end of the string. In each
    // loop iteration, a single coordinate is decoded.
    while (index < str.length) {
      // Reset shift, result, and byte
      byte = null;
      shift = 0;
      result = 0;

      do {
        byte = str.codeUnitAt(index++) - 63;
        result |= ((Int32(byte) & Int32(0x1f)) << shift).toInt();
        shift += 5;
      } while (byte >= 0x20);

      latitudeChange =
          ((result & 1) != 0 ? ~(Int32(result) >> 1) : (Int32(result) >> 1))
              .toInt();

      shift = result = 0;

      do {
        byte = str.codeUnitAt(index++) - 63;
        result |= ((Int32(byte) & Int32(0x1f)) << shift).toInt();
        shift += 5;
      } while (byte >= 0x20);

      longitudeChange =
          ((result & 1) != 0 ? ~(Int32(result) >> 1) : (Int32(result) >> 1))
              .toInt();

      lat += latitudeChange;
      lng += longitudeChange;

      coordinates.add(LatLng(lat / factor, lng / factor));
    }

    return coordinates;
  }

  static String encode(List<LatLng> coordinates, {int precision = _defaultPrecision}) {
    if (coordinates.isEmpty) {
      return "";
    }

    final factor = math.pow(10, precision);
    var output = _encode(coordinates[0].latitude, 0, factor) +
        _encode(coordinates[0].longitude, 0, factor);

    for (var i = 1; i < coordinates.length; i++) {
      var a = coordinates[i], b = coordinates[i - 1];
      output += _encode(a.latitude, b.latitude, factor);
      output += _encode(a.longitude, b.longitude, factor);
    }

    return output;
  }
}