import 'dart:convert';

import 'package:flutter/services.dart';

abstract class ConfigReader {
  static Map<String, dynamic> _config;

  static Future<void> initialize() async {
    final configString = await rootBundle.loadString('config/app_config.json');
    _config = json.decode(configString) as Map<String, dynamic>;
  }

  static String getApiKey() {
    return _config['apiKey'] as String;
  }

  static String getApiKeySecret() {
    return _config['apiKeySecret'] as String;
  }

  static String getAccessToken() {
    return _config['accessToken'] as String;
  }

  static String getAccessTokenSecret() {
    return _config['accessTokenSecret'] as String;
  }
}
