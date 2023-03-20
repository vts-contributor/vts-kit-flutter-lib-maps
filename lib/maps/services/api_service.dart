import 'dart:async';

import '../models/network/token.dart';

class CoreAPIService {
  static String host = "Empty host url";

  static Future<Token> refreshToken() async {
    // final body = {
    //   'clientId': 'mobile',
    //   'refresh_token': Profile.token?.refresh,
    //   'grant_type': 'refresh_token',
    // };
    // final response = await post(host, 'uaa/oauth/refresh_token', body);
    // return response.map((json) => Token.fromJson(json));
    return Token('sad', 'asd', 'asd', 145464898978, 'asd');
  }
}
