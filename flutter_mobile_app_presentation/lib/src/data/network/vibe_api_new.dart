import 'dart:io' show Platform;

import 'package:flutter_mobile_app_presentation/src/cubit/vibes_ai/models/chat_with_ai.dart';
import 'package:retrofit/retrofit.dart';
import 'package:dio/dio.dart';
import 'package:vibes_common/vibes.dart';

part 'vibe_api_new.g.dart';

@RestApi(baseUrl: 'https://app.vibesonly.com/api/v1/')
abstract class VibeApiNew {
  factory VibeApiNew(Dio dio, {String baseUrl, ParseErrorLogger? errorLogger}) =
      _VibeApiNew;

  @POST('/users/social-login/')
  Future<dynamic> socialLogin(@Body() Map<String, dynamic> body);

  @GET('/users/user-profile/')
  Future<dynamic> getUserProfile(@Query('firebase_uid') String firebaseUid);

  @POST('https://ai-chat.vibesonly.com/chat')
  // @POST('https://isela-unumpired-heriberto.ngrok-free.dev/chat')
  Future<ChatResponse> sendChatMessage(@Body() ChatRequest request);

  @GET('stories/homes/active_home/')
  Future<Home> home();

  @GET('/videos/creators/')
  Future<List<VideoCreator>> getAllVideoCreators();

  @GET('/settings/')
  Future<HelpUrls> getHelpUrls();

  @GET('/stories/stories/{id}/')
  Future<Story> getStoryDetail(@Path('id') String id);

  @GET('stories/stories/')
  Future<AllStories> getAllStories(
    @Query('limit') int limit,
    @Query('offset') int offset, {
    @Query('category') String? categoryId,
    @Query('character') String? characterId,
  });

  @GET('stories/categories/')
  Future<List<Category>> getCategories();

  @GET('/stories/homes/global_search/')
  Future<List<SearchResult>> search(@Query('q') String q);

  /// Note that [limit] and [offset] can actually be left out,
  /// but the result then would be a [List<Video>], not [AllVideo].
  @GET('/videos/videos/')
  Future<AllVideo> getVideos({
    @Query('channel') String? channelId,
    @Query('creator') String? creatorId,
    @Query('limit') required int limit,
    @Query('offset') required int offset,
  });

  @GET('/videos/videos/{id}/')
  Future<Video> getVideoDetail(@Path('id') String id);

  @GET('videos/channels/{id}/')
  Future<Channel> getChannel(@Path() String id);

  @GET('/videos/channels/')
  Future<AllChannel> getChannels(
    @Query('limit') int limit,
    @Query('offset') int offset,
  );

  @POST('/users/devices/')
  Future<void> registerToken(@Body() Device device);

  @GET('financial/promotions/')
  Future<List<Promotion>> getAllPromotions();

  @GET('/studio/devices/')
  Future<List<Commodity>> getAllCommodities();

  @GET('/financial/apple_verify_purchase/')
  Future<SubscriptionResponse> checkSubscriptionApple(
    @Query('device_id') String deviceId,
  );

  @GET('/financial/google_verify_purchase/')
  Future<SubscriptionResponse> checkSubscriptionGoogle(
    @Query('device_id') String deviceId,
  );

  @POST('/financial/apple_verify_purchase/')
  Future<SubscriptionResponse> verifyPurchaseApple(
    @Body() PurchaseVerificationData verificationData,
  );

  @POST('/financial/google_verify_purchase/')
  Future<SubscriptionResponse> verifyPurchaseGoogle(
    @Body() PurchaseVerificationData verificationData,
  );

  @GET('/games/game-cards/')
  Future<AllGameCard> getGameCards(
    @Query('page') int page,
    @Query('page_size') int pageSize,
    @Query('section_type') String sectionType,
  );

  @GET('/studio/device-list')
  Future<AllManuals> getAllManuals({@Query('search') String? search});

  @GET('/studio/manuals-detail/{id}/')
  Future<ManualDetails> getManualDetails(@Path() int id);
}

extension PlatformAgnosticMethods on VibeApiNew {
  Future<SubscriptionResponse> checkSubscription(String deviceId) {
    return Platform.isIOS
        ? checkSubscriptionApple(deviceId)
        : checkSubscriptionGoogle(deviceId);
  }

  Future<SubscriptionResponse> verifyPurchase(
    @Body() PurchaseVerificationData verificationData,
  ) {
    return Platform.isIOS
        ? verifyPurchaseApple(verificationData)
        : verifyPurchaseGoogle(verificationData);
  }
}
