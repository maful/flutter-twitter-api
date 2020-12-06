import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_twitter_api/config_reader.dart';

class EnvironmentConfig {
  final apiKey = ConfigReader.getApiKey();
  final apiKeySecret = ConfigReader.getApiKeySecret();
  final accessToken = ConfigReader.getAccessToken();
  final accessTokenSecret = ConfigReader.getAccessTokenSecret();
}

final environmentConfigProvider = Provider<EnvironmentConfig>((ref) {
  return EnvironmentConfig();
});
