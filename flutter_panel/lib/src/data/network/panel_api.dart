import 'package:flutter_panel/src/data/network/panel_upload_api.dart';
import 'package:retrofit/retrofit.dart';
import 'package:dio/dio.dart';
import 'package:vibes_common/vibes.dart';

part 'panel_api.g.dart';

@RestApi(baseUrl: "https://vo-dev.6thsolution.tech/api/v1/")
abstract class VibesPanelApi {
  factory VibesPanelApi(Dio dio,
      {String baseUrl, ParseErrorLogger? errorLogger}) = _VibesPanelApi;

  @POST("hippo_shield/email_password_authentication/login/")
  Future<LoginResponse> login(@Body() LoginByEmail request);

  @POST("hippo_shield/2fa/login/")
  Future<Tokens> send2FACode(@Body() TwoFACode code);

  @GET("users/push_messages/")
  Future<List<PushResponse>> getAllPushMessages();

  @POST("users/push_messages/")
  Future<PushResponse> sendPush(@Body() PushMessage request);

  @DELETE("users/push_messages/{id}/")
  Future<void> deletePush(@Path() int id);

  @GET("stories/categories/")
  Future<AllCategories> getAllCategories(
    @Query("limit") int limit,
    @Query("offset") int offset,
    @Query("search") String? search,
    @Query("ordering") String? ordering,
  );

  @GET("stories/characters/")
  Future<AllCharacters> getAllCharacters(
    @Query("limit") int limit,
    @Query("offset") int offset,
    @Query("search") String? search,
    @Query("ordering") String? ordering,
  );

  @GET("stories/stories/")
  Future<AllStories> getAllStories(
    @Query("limit") int limit,
    @Query("offset") int offset,
    @Query("search") String? search,
    @Query("ordering") String? ordering,
  );

  @GET("stories/sections/")
  Future<AllSections> getAllSections(
    @Query("limit") int limit,
    @Query("offset") int offset,
  );

  @GET("videos/channels/")
  Future<AllChannel> getAllChannels(
    @Query("limit") int limit,
    @Query("offset") int offset,
    @Query("search") String? search,
  );

  @GET("videos/videos/")
  Future<AllVideo> getAllVideos(
    @Query("limit") int limit,
    @Query("offset") int offset,
    @Query("search") String? search,
    @Query("ordering") String? ordering,
  );

  @GET("users/staffs/")
  Future<AllStaffs> getAllStaffs(
    @Query("limit") int limit,
    @Query("offset") int offset,
    @Query("search") String? search,
  );

  @PATCH("users/staffs/{id}/")
  Future<void> updateStaff(@Path() String id, @Body() ShortStaff user);

  @POST("users/staffs/register/")
  Future<Staff> addStaff(@Body() ShortStaff user);

  @DELETE("users/staffs/{id}/")
  Future<void> deleteUser(@Path() String id);

  @POST("stories/categories/")
  Future<Category> addCategory(@Body() ShortCategory category);

  @POST("stories/stories/")
  Future<Story> addStory(@Body() ShortStory story);

  @PATCH("stories/stories/{id}/")
  Future<void> updateStory(@Path() int id, @Body() ShortStory story);

  @DELETE("stories/characters/{id}/")
  Future<void> deleteCharacter(@Path() String id);

  @DELETE("stories/categories/{id}/")
  Future<void> deleteCategory(@Path() String id);

  @DELETE("stories/stories/{id}/")
  Future<void> deleteStory(@Path() String id);

  @DELETE("videos/channels/{id}/")
  Future<void> deleteChannel(@Path() String id);

  @DELETE("videos/videos/{id}/")
  Future<void> deleteVideo(@Path() String id);

  @GET("stories/homes/{id}/")
  Future<Home> home(@Path() String id);

  @GET("stories/characters/{id}/")
  Future<Character> getCharacter(@Path() String id);

  @GET("stories/categories/{id}/")
  Future<Category> getCategory(@Path() String id);

  @GET("stories/stories/{id}/")
  Future<Story> getStory(@Path() String id);

  @GET("users/staffs/{id}/")
  Future<Staff> getStaff(@Path() String id);

  @GET("videos/channels/{id}/")
  Future<Channel> getChannel(@Path() String id);

  @GET("videos/videos/{id}/")
  Future<Video> getVideo(@Path() String id);

  @DELETE("stories/stories/{id}/delete_vibe/")
  Future<void> deleteStoryVibes(@Path() String id);

  @GET("/stories/homes/global_search/")
  Future<List<SearchResult>> search(@Query("q") String q);

  @GET("financial/promotions/")
  Future<List<Promotion>> getAllPromotions();

  @POST("financial/promotions/")
  Future<Promotion> addPromotion(@Body() ShortPromotion promotion);

  @PATCH("financial/promotions/{id}/")
  Future<Promotion> updatePromotion(
      @Path() int id, @Body() ShortPromotion promotion);

  @DELETE("financial/promotions/{id}/")
  Future<void> deletePromotion(@Path() int id);

  @GET("/studio/devices/")
  Future<List<Commodity>> getAllCommodities();

  @DELETE("/studio/devices/{id}/")
  Future<void> deleteCommodity(@Path() int id);

  @GET("/videos/creators/")
  Future<List<VideoCreator>> getAllVideoCreators();

  /// For @POST("videos/creators/") and @PATCH("videos/creators/{id}/"),
  /// use [VibesPanelUploadApi.addVideoCreator] and [VibesPanelUploadApi.updateVideoCreator] respectively.
  /// It cannot be done here cleanly.

  @DELETE("videos/creators/{id}/")
  Future<void> deleteVideoCreator(@Path() int id);

  @GET('/settings/')
  Future<HelpUrls> getSettings();

  @POST('/settings/')
  Future<HelpUrls> updateSettings(@Body() HelpUrls helpUrls);
}
