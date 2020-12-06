import 'dart:io';

import 'package:dart_twitter_api/twitter_api.dart';
import 'package:dartz/dartz.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:http/http.dart';

import 'package:riverpod_twitter_api/environment_config.dart';

final twitterApiProvider = Provider<TwitterApi>((ref) {
  final config = ref.watch(environmentConfigProvider);
  final twitterApi = TwitterApi(
    client: TwitterClient(
      consumerKey: config.apiKey,
      consumerSecret: config.apiKeySecret,
      token: config.accessToken,
      secret: config.accessTokenSecret,
    ),
  );

  return twitterApi;
});

class Failure {
  Failure(this.message);

  final String message;
}

final twitterRepositoryProvider = Provider<TwitterRepository>((ref) {
  final twitterApi = ref.watch(twitterApiProvider);

  return TwitterRepository(twitterApi);
});

class TwitterRepository {
  TwitterRepository(this._twitterApi);

  final TwitterApi _twitterApi;

  Future<Either<Failure, String>> post(String status) async {
    try {
      final tweet = await _twitterApi.tweetService.update(status: status);
      return Right(tweet.fullText);
    } on Response catch (response) {
      return Left(Failure(response.reasonPhrase));
    } on SocketException catch (_) {
      return Left(Failure('No internet connection'));
    }
  }
}
