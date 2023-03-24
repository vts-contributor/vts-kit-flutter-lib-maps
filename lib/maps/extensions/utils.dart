// Copied from flutter_core

import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/network/language.dart';
import '../models/network/token.dart';


typedef R LetCallback<T, R>(final T it);
typedef Future<R> FutureLetCallback<T, R>(final T it);

extension Let<T, R> on T {
  R let<R>(LetCallback<T, R> callback) {
    return callback(this);
  }

  Future<R> asyncLet<R>(FutureLetCallback<T, R> callback) {
    return callback(this);
  }
}

typedef bool TakeIfCallback<T>(final T it);
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
      if (this.languageCode == locale.languageCode) {
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