// Copied from flutter_core

import 'dart:math';

import 'package:collection/collection.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:maps_core/maps/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/network/language.dart';
import '../models/network/token.dart';


typedef LetCallback<T, R> = R Function(T it);
typedef FutureLetCallback<T, R> = Future<R> Function(T it);

extension Let<T, R> on T {
  R let<R>(LetCallback<T, R> callback) {
    return callback(this);
  }

  Future<R> asyncLet<R>(FutureLetCallback<T, R> callback) {
    return callback(this);
  }
}

typedef TakeIfCallback<T> = bool Function(T it);
extension TakeIf<T> on T {
  T? takeIf(TakeIfCallback<T> callback) {
    if (callback(this)) {
      return this;
    }
    return null;
  }
}

extension NullOrEmpty on dynamic {
  bool get isNullOrEmpty {
    if (this == null) {
      return true;
    }
    if (this is Iterable) {
      final Iterable it = this;
      return it.isEmpty;
    }
    if (this is Map) {
      final Map it = this;
      return it.isEmpty;
    }
    if (this is String) {
      final String it = this;
      return it.isEmpty;
    }
    return false;
  }
}

extension ItemCast on List {
  List<R>? asListOf<R>() {
    List<R>? result;
    try {
      result = map((e) => e as R).toList();
    } on Exception catch (_) {}
    return result;
  }

  List<R>? asFilteredListOf<R>() {
    final List<R> result = where((e) => e is R).map((e) => e as R).toList();
    return result;
  }
}

extension IndexedIterable<E> on Iterable<E> {
  Iterable<T> mapIndexed<T>(T Function(E e, int i) f) {
    var i = 0;
    return map((e) => f(e, i++));
  }

  Iterable<E> whereIndexed(bool Function(E e, int i) f) {
    var i = 0;
    return where((e) => f(e, i++));
  }
}

extension BinaryString on String {
  int toSignedInt() {
    var result = 0;
    final binary = this;
    final length = binary.length;
    for (var i = 0; i < binary.length; i++) {
      final c = binary[i];
      if (c != '0' && c != '1') {
        return 0;
      }
      final num = int.parse(c);
      if (i == 0) {
        final int sign;
        if (num == 1) {
          sign = -1;
        } else {
          sign = 1;
        }
        result = sign * num * pow(2, length - 1 - i).toInt();
      } else {
        result += num * pow(2, length - 1 - i).toInt();
      }
    }
    return result;
  }
}

extension BinaryInt on int {
  String toReversed8Bit() {
    int x = this;
    String bitString = "";
    for (var i = 0; i < 8; i++) {
      bitString = ((x & 1 == 1) ? "0" : "1") + bitString;
      x = x >> 1;
    }
    return bitString;
  }
}

extension Localex on Locale {
  Locale? supportedOrNull() {
    for (Locale locale in SUPPORTED_LOCALES) {
      if (languageCode == locale.languageCode) {
        return this;
      }
    }
    return null;
  }
}

extension Tokenx on Token {
  static const _KEY_ACCESS = 'TOKEN_ACCESS';
  static const _KEY_REFRESH = 'TOKEN_REFRESH';
  static const _KEY_TYPE = 'TOKEN_TYPE';
  static const _KEY_EXPIRES = 'TOKEN_EXPIRES';
  static const _KEY_SCOPE = 'TOKEN_SCOPE';

  static Future<Token> fromSharedPreferences() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    final access = sharedPreferences.getString(_KEY_ACCESS);
    final refresh = sharedPreferences.getString(_KEY_REFRESH);
    final type = sharedPreferences.getString(_KEY_TYPE);
    final expiresIn = sharedPreferences.getInt(_KEY_EXPIRES);
    final scope = sharedPreferences.getString(_KEY_SCOPE);
    return Token(access, type, refresh, expiresIn, scope);
  }

  Future<void> saveSharedPreferences() async {
    final sharedPref = await SharedPreferences.getInstance();
    await access?.asyncLet((it) => sharedPref.setString(_KEY_ACCESS, it));
    await refresh?.asyncLet((it) => sharedPref.setString(_KEY_REFRESH, it));
    await type?.asyncLet((it) => sharedPref.setString(_KEY_TYPE, it));
    await expiresIn?.asyncLet((it) => sharedPref.setInt(_KEY_EXPIRES, it));
    await scope?.asyncLet((it) => sharedPref.setString(_KEY_SCOPE, it));
  }
}

extension MapX on Map<String, String>? {
  String valueOrKey(String key) => this?[key] ?? key;
}

extension RootBundleImage on AssetBundle {
  Future<Uint8List> loadImageAsUint8List(String path) async {
    final ByteData bytes = await rootBundle.load(path);
    return bytes.buffer.asUint8List();
  }
}

extension DioImageDownload on Dio {
  Future<Uint8List> downloadImageToBitmap(String url) async {

    final response = await get<List<int>>(
      url,
      options: Options(responseType: ResponseType.bytes), // Set the response type to `stream`.
    );

    if (response.data != null) {
      return Uint8List.fromList(response.data!);
    } else {
      throw NullThrownError();
    }
  }
}

extension MapUtils<K, V> on Map<K, V> {
  K? keyOf(V value) {
    return keyWhere((e) => e == value);
  }

  K? keyWhere(bool Function(V value) test) {
    final entry = entries.firstWhereOrNull((element) => test(element.value));
    return entry?.key;
  }
}

extension ConstrictZoomLevel on double {
  ///must >= 1
  double get validCoreZoomLevel => max(Constant.zoomLevelLowerBound, this);
}

extension CompareDouble on double {

  /// The parameter [precision] must be an integer satisfying:
  /// `0 <= fractionDigits <= 20`. If this is not satisfied, it will just return
  /// double.compareTo
  int compareAsFixed(double other, [int? precision]) {
    if (precision == null || precision < 0 || precision > 20) {
      return compareTo(other);
    }

    try {
      final thisFixed = double.parse(toStringAsFixed(precision));
      final otherFixed = double.parse(other.toStringAsFixed(precision));

      return thisFixed.compareTo(otherFixed);
    } catch (e, s) {
      debugPrintStack(stackTrace: s);
      return compareTo(other);
    }
  }
}