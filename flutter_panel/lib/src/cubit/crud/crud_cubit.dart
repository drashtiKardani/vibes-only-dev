import 'dart:convert';

// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_panel/src/data/network/panel_api.dart';
import 'package:flutter_panel/src/data/network/panel_upload_api.dart';
import 'package:flutter_panel/src/di/di.dart';
import 'package:flutter_panel/src/util/large_file_uploader.dart';
import 'package:harmony_auth/harmony_auth.dart';
import 'package:sealed_annotations/sealed_annotations.dart';
import 'package:vibes_common/vibes.dart';

part 'crud_cubit.sealed.dart';

class CrudCubit extends Cubit<CrudState> {
  CrudCubit({required this.api, required this.uploadApi})
      : super(const CrudState.initial());

  final VibesPanelApi api;
  final VibesPanelUploadApi uploadApi;

  Future<void> getSettings() async {
    emit(const CrudState.loading());
    final result = await api.getSettings().sealed();
    emitSealed<HelpUrls>(result,
        success: (data) => CrudState.getSettings(helpUrls: data));
  }

  Future<void> updateSettings(HelpUrls helpUrls) async {
    emit(const CrudState.loading());
    final result = await api.updateSettings(helpUrls).sealed();
    emitSealed<HelpUrls>(result,
        success: (data) => const CrudState.successfulCreate());
  }

  Future<void> getAllVideoCreators() async {
    emit(const CrudState.loading());
    var result = await api.getAllVideoCreators().sealed();
    emitSealed<List<VideoCreator>>(result,
        success: (data) =>
            CrudState.getAllVideoCreators(allVideoCreators: data));
  }

  Future<void> addVideoCreator(UpdatingVideoCreator videoCreator) async {
    emit(const CrudState.loading());
    var result = await uploadApi.addVideoCreator(videoCreator).sealed();
    emitSealed(result, success: (data) => const CrudState.successfulCreate());
  }

  Future<void> updateVideoCreator(
      int id, UpdatingVideoCreator videoCreator) async {
    emit(const CrudState.loading());
    var result = await uploadApi.updateVideoCreator(id, videoCreator).sealed();
    emitSealed(result, success: (data) => const CrudState.successfulCreate());
  }

  Future<void> deleteVideoCreator(int id) async {
    emit(const CrudState.deleting());
    await api.deleteVideoCreator(id).sealed();
    emit(const CrudState.itemsDeleted());
  }

  Future<void> getAllCommodities() async {
    emit(const CrudState.loading());
    var result = await api.getAllCommodities().sealed();
    emitSealed<List<Commodity>>(result,
        success: (data) => CrudState.getAllCommodities(allCommodities: data));
  }

  Future<void> addCommodity({
    int? order,
    required String name,
    String? bluetoothName,
    String? shopUrl,
    int? numberOfMotors,
    required Uint8List shopImage,
    Uint8List? controllerImage,
    required bool isToy,
    required String motor1Name,
    required String motor2Name,
  }) async {
    emit(const CrudState.loading());
    var result = await uploadApi
        .addCommodity(order, name, bluetoothName, shopUrl, numberOfMotors,
            shopImage, controllerImage, isToy, motor1Name, motor2Name)
        .sealed();
    emitSealed(result, success: (data) => const CrudState.successfulCreate());
  }

  Future<void> updateCommodity({
    required int id,
    int? order,
    required String name,
    String? bluetoothName,
    String? shopUrl,
    int? numberOfMotors,
    required Uint8List shopImage,
    Uint8List? controllerImage,
    required bool isToy,
    required String motor1Name,
    required String motor2Name,
    required String motor3Name,
  }) async {
    emit(const CrudState.loading());
    var result = await uploadApi
        .updateCommodity(
            id,
            order,
            name,
            bluetoothName,
            shopUrl,
            numberOfMotors,
            shopImage,
            controllerImage,
            isToy,
            motor1Name,
            motor2Name,
            motor3Name)
        .sealed();
    emitSealed(result, success: (data) => const CrudState.successfulCreate());
  }

  Future<void> deleteCommodity(int id) async {
    emit(const CrudState.deleting());
    await api.deleteCommodity(id).sealed();
    emit(const CrudState.itemsDeleted());
  }

  Future<void> getAllPromotions() async {
    emit(const CrudState.loading());
    var result = await api.getAllPromotions().sealed();
    emitSealed<List<Promotion>>(result,
        success: (data) => CrudState.getAllPromotions(allPromotions: data));
  }

  Future<void> addPromotion({
    required String title,
    required String body,
    required String code,
    required PromotionTarget target,
    PromotionSubscriptionType? subscriptionType,
    int? frequency,
    int? daysSinceMembershipStart,
    Constraint? daysSinceMembershipStartConstraint,
    int? daysSinceRegistration,
    Constraint? daysSinceRegistrationConstraint,
    int? daysUntilSubscriptionEnd,
    Constraint? daysUntilSubscriptionEndConstraint,
  }) async {
    emit(const CrudState.loading());
    var result = await api
        .addPromotion(ShortPromotion(
          title: title,
          body: body,
          code: code,
          target: target,
          subscriptionType: subscriptionType,
          frequency: frequency,
          daysSinceMembershipStart: daysSinceMembershipStart,
          daysSinceMembershipStartConstraint:
              daysSinceMembershipStartConstraint,
          daysSinceRegistration: daysSinceRegistration,
          daysSinceRegistrationConstraint: daysSinceRegistrationConstraint,
          daysUntilSubscriptionEnd: daysUntilSubscriptionEnd,
          daysUntilSubscriptionEndConstraint:
              daysUntilSubscriptionEndConstraint,
        ))
        .sealed();
    emitSealed(result, success: (data) => const CrudState.successfulCreate());
  }

  void updatePromotion(
    int id, {
    String? title,
    String? body,
    String? code,
    PromotionTarget? target,
    PromotionSubscriptionType? subscriptionType,
    int? frequency,
    int? daysSinceMembershipStart,
    Constraint? daysSinceMembershipStartConstraint,
    int? daysSinceRegistration,
    Constraint? daysSinceRegistrationConstraint,
    int? daysUntilSubscriptionEnd,
    Constraint? daysUntilSubscriptionEndConstraint,
  }) async {
    emit(const CrudState.loading());
    var result = await api
        .updatePromotion(
            id,
            ShortPromotion(
              title: title,
              body: body,
              code: code,
              target: target,
              subscriptionType: subscriptionType,
              frequency: frequency,
              daysSinceMembershipStart: daysSinceMembershipStart,
              daysSinceMembershipStartConstraint:
                  daysSinceMembershipStartConstraint,
              daysSinceRegistration: daysSinceRegistration,
              daysSinceRegistrationConstraint: daysSinceRegistrationConstraint,
              daysUntilSubscriptionEnd: daysUntilSubscriptionEnd,
              daysUntilSubscriptionEndConstraint:
                  daysUntilSubscriptionEndConstraint,
            ))
        .sealed();
    emitSealed(result, success: (data) => const CrudState.successfulCreate());
  }

  Future<void> deletePromotion(int id) async {
    emit(const CrudState.deleting());
    await api.deletePromotion(id).sealed();
    emit(const CrudState.itemsDeleted());
  }

  Future<void> getAllCategories(int limit, int offset,
      {String? search, String? ordering}) async {
    emit(const CrudState.loading());
    var result =
        await api.getAllCategories(limit, offset, search, ordering).sealed();
    emitSealed<AllCategories>(result,
        success: (data) => CrudState.getAllCategories(allCategories: data));
  }

  Future<void> getAllStaffs(int limit, int offset, {String? search}) async {
    emit(const CrudState.loading());
    var result = await api.getAllStaffs(limit, offset, search).sealed();
    emitSealed<AllStaffs>(result,
        success: (data) => CrudState.getAllStaffs(allStaffs: data));
  }

  Future<void> getAllCharacters(int limit, int offset,
      {String? search, String? ordering}) async {
    emit(const CrudState.loading());
    var result =
        await api.getAllCharacters(limit, offset, search, ordering).sealed();
    emitSealed<AllCharacters>(result,
        success: (data) => CrudState.getAllCharacters(allCharacters: data));
  }

  Future<void> getAllStories(int limit, int offset,
      {String? search, String? ordering}) async {
    emit(const CrudState.loading());
    var result =
        await api.getAllStories(limit, offset, search, ordering).sealed();
    emitSealed<AllStories>(result,
        success: (data) => CrudState.getAllStories(allStories: data));
  }

  Future<void> getAllSections(int limit, int offset) async {
    emit(const CrudState.loading());
    var result = await api.getAllSections(limit, offset).sealed();
    emitSealed<AllSections>(result,
        success: (data) => CrudState.getAllSections(allSections: data));
  }

  Future<void> getAllChannels(int limit, int offset, {String? search}) async {
    emit(const CrudState.loading());
    var result = await api.getAllChannels(limit, offset, '').sealed();
    emitSealed<AllChannel>(result,
        success: (data) => CrudState.getAllChannels(allChannel: data));
  }

  Future<void> getAllVideos(int limit, int offset,
      {String? search, String? ordering}) async {
    emit(const CrudState.loading());
    var result =
        await api.getAllVideos(limit, offset, search, ordering).sealed();
    emitSealed<AllVideo>(result,
        success: (data) => CrudState.getAllVideos(allVideo: result.data));
  }

  Future<void> deleteStories(List<int> ids) async {
    emit(const CrudState.deleting());
    for (int id in ids) {
      await api.deleteStory(id.toString()).sealed();
    }
    emit(const CrudState.itemsDeleted());
  }

  Future<void> deleteStoryVibes(int storyId) async {
    emit(const CrudState.deleting());
    await api.deleteStoryVibes(storyId.toString()).sealed();
    emit(const CrudState.itemsDeleted());
  }

  Future<void> deleteStaffs(List<int> ids) async {
    emit(const CrudState.deleting());
    for (int id in ids) {
      await api.deleteUser(id.toString()).sealed();
    }
    emit(const CrudState.itemsDeleted());
  }

  Future<void> deleteChannels(List<int> ids) async {
    emit(const CrudState.deleting());
    for (int id in ids) {
      await api.deleteChannel(id.toString()).sealed();
    }
    emit(const CrudState.itemsDeleted());
  }

  Future<void> deleteVideos(List<int> ids) async {
    emit(const CrudState.loading());
    for (int id in ids) {
      await api.deleteVideo(id.toString()).sealed();
    }
    emit(const CrudState.itemsDeleted());
  }

  Future<void> deleteCharacters(List<int> ids) async {
    emit(const CrudState.deleting());
    for (int id in ids) {
      await api.deleteCharacter(id.toString()).sealed();
    }
    emit(const CrudState.itemsDeleted());
  }

  Future<void> deleteCategories(List<int> ids) async {
    emit(const CrudState.deleting());
    for (int id in ids) {
      await api.deleteCategory(id.toString()).sealed();
    }
    emit(const CrudState.itemsDeleted());
  }

  Future<void> addStory(
      String title,
      String shortDesc,
      String body,
      html.File? audio,
      Uint8List coverImage,
      Uint8List? showcaseSmall,
      Uint8List? showcaseMedium,
      Uint8List? showcaseTall,
      Uint8List? showcaseExtended,
      Uint8List? featuredImage,
      List<String> categories,
      List<String> characters,
      Iterable<String> flags,
      bool? premiumContentFlag,
      String transcript,
      {Uint8List? androidImage}) async {
    emit(const CrudState.loading());
    var result = await uploadApi
        .addStory(
          description: body,
          title: title,
          shortDescription: shortDesc,
          transcript: transcript,
          imageCover: coverImage,
          imageShowcaseExtended: showcaseExtended,
          imageShowcaseMedium: showcaseMedium,
          imageShowcaseSmall: showcaseSmall,
          imageShowcaseTall: showcaseTall,
          featuredImage: featuredImage,
          androidImage: androidImage,
          characters: characters,
          categories: categories,
          flags: flags,
          premiumContent: premiumContentFlag,
        )
        .sealed();

    if (audio != null) {
      result.fold(
        onSuccess: (value) async {
          final videoModel = Video.fromJson(value.data);

          final authRepository = await inject<AuthRepository>().getToken();
          LargeFileUploader.upload(
              method: 'PATCH',
              uploadUrl:
                  '${uploadApi.dio.options.baseUrl}stories/stories/${videoModel.id}/',
              onSendProgress: (progress) => emit(CrudState.onProgress(progress: progress)),
              onComplete: (response) => emit(const CrudState.successfulCreate()),
              headers: {
                'Authorization': 'Bearer ${authRepository?.access ?? ''}'
              },
              data: {
                'audio': audio
              });
        },
        onError: (error) async {
          emit(CrudState.failure(error: error));
        },
      );
    } else {
      emitSealed(result, success: (data) => const CrudState.successfulCreate());
    }
  }

  Future<void> addCharacter(String name, String bio, Uint8List image,
      bool showOnHomepage, String order) async {
    emit(const CrudState.loading());
    var result = await uploadApi
        .addCharacter(name, bio, image, showOnHomepage, order)
        .sealed();
    emitSealed(result, success: (data) => const CrudState.successfulCreate());
  }

  Future<void> addStaff(String firstName, String lastName, String email,
      String password, String phoneNumber) async {
    emit(const CrudState.loading());
    var result = await api
        .addStaff(ShortStaff(
            email: email,
            password: password,
            firstName: firstName,
            lastName: lastName,
            phoneNumber: phoneNumber))
        .sealed();
    emitSealed(result, success: (data) => const CrudState.successfulCreate());
  }

  Future<void> updateStaff(String id, String? firstName, String? lastName,
      String? password, String? phoneNumber) async {
    emit(const CrudState.loading());
    var result = await uploadApi
        .updateStaff(id, firstName, lastName, phoneNumber, password)
        .sealed();
    emitSealed(result, success: (data) => const CrudState.successfulCreate());
  }

  Future<void> addCategory(String name, bool tile, Uint8List image,
      UploadingPhoto? androidImage) async {
    emit(const CrudState.loading());
    var result =
        await uploadApi.addCategory(image, name, tile, androidImage).sealed();
    emitSealed(result, success: (data) => const CrudState.successfulCreate());
  }

  Future<String> encodeInBase64(List<int> bytes) async {
    String base64 = base64Encode(bytes);
    return "data:image/jpeg;base64,$base64";
  }

  Future<void> getAddStoryFormData() async {
    var characters = await api.getAllCharacters(100, 0, null, null).sealed();
    var categories = await api.getAllCategories(100, 0, null, null).sealed();
    if (characters.isSuccessful && categories.isSuccessful) {
      emit(CrudState.getAddStoryFormData(
          characters: characters.data, categories: categories.data));
    }
  }

  void emitSealed<T>(SealedResult<T, VibeError> result,
      {required CrudState Function(T data) success}) {
    if (result.isFailure) {
      emit(CrudState.failure(error: result.error));
    } else if (result.isSuccessful) {
      emit(success(result.data));
    }
  }

  void addVideo(
    String title,
    Uint8List thumbnail,
    html.File file,
    Iterable<String> channels,
    String? caption,
    String? transcript,
    bool? premiumContentFlag,
    VideoCreator? videoCreator,
    UploadingPhoto? trendImage,
    bool isTrend,
    bool isFavorite,
    bool excludeAndroid,
  ) async {
    emit(const CrudState.loading());
    var result = await uploadApi
        .addVideo(
            title,
            channels,
            thumbnail,
            caption,
            transcript,
            premiumContentFlag,
            videoCreator?.id,
            trendImage,
            isTrend,
            isFavorite,
            excludeAndroid)
        .sealed();

    result.fold(
      onSuccess: (value) async {
        final videoModel = Video.fromJson(value.data);

        final authRepository = await inject<AuthRepository>().getToken();

        var data = {'file': file};

        LargeFileUploader.upload(
            method: 'PATCH',
            uploadUrl:
                '${uploadApi.dio.options.baseUrl}videos/videos/${videoModel.id}/',
            onSendProgress: (progress) =>
                emit(CrudState.onProgress(progress: progress)),
            onComplete: (response) => emit(const CrudState.successfulCreate()),
            headers: {
              'Authorization': 'Bearer ${authRepository?.access ?? ''}'
            },
            data: data);
      },
      onError: (error) async {
        emit(CrudState.failure(error: error));
      },
    );
  }

  void addChannel(String title, String description, Uint8List image) async {
    emit(const CrudState.loading());
    var result = await uploadApi.addChannel(title, description, image).sealed();
    emitSealed(result, success: (data) => const CrudState.successfulCreate());
  }

  void getCharacter(String id) async {
    emit(const CrudState.loading());
    var result = await api.getCharacter(id).sealed();
    emitSealed(result,
        success: (data) => CrudState.getCharacter(character: result.data));
  }

  void getCategory(String id) async {
    emit(const CrudState.loading());
    var result = await api.getCategory(id).sealed();
    emitSealed(result,
        success: (data) => CrudState.getCategory(category: result.data));
  }

  void getStory(String id) async {
    emit(const CrudState.loading());
    var result = await api.getStory(id).sealed();
    final categories = await api.getAllCategories(1000, 0, null, null);
    final characters = await api.getAllCharacters(1000, 0, null, null);
    emitSealed(result,
        success: (data) => CrudState.getStory(
            story: result.data,
            categories: categories.results,
            characters: characters.results));
  }

  void getStaff(String id) async {
    emit(const CrudState.loading());
    var result = await api.getStaff(id).sealed();

    emitSealed(result,
        success: (data) => CrudState.getStaff(staff: data as Staff));
  }

  void getChannel(String id) async {
    emit(const CrudState.loading());
    var result = await api.getChannel(id).sealed();
    emitSealed(result,
        success: (data) => CrudState.getChannel(channel: result.data));
  }

  void getVideo(String id, int limit, int offset) async {
    emit(const CrudState.loading());
    var channels = await api.getAllChannels(limit, offset, null).sealed();
    var result = await api.getVideo(id).sealed();
    final videoCreators = await api.getAllVideoCreators().sealed();
    emitSealed(result,
        success: (data) => CrudState.getVideo(
              video: result.data,
              channels: channels.data.results,
              videoCreators: videoCreators.data,
            ));
  }

  void updateChannel(String id, String title, String description,
      Uint8List image, DateTime? publishDate) async {
    emit(const CrudState.loading());
    var result = await uploadApi
        .updateChannel(id, title, description, image, publishDate)
        .sealed();
    emitSealed(result, success: (data) => const CrudState.successfulCreate());
  }

  Future<void> updateCategory(
      String id,
      String title,
      bool tile,
      Uint8List image,
      String status,
      DateTime? publishDate,
      UploadingPhoto? androidImage) async {
    emit(const CrudState.loading());
    var result = await uploadApi
        .updateCategory(
            id, title, tile, image, status, publishDate, androidImage)
        .sealed();
    emitSealed(result, success: (data) => const CrudState.successfulCreate());
  }

  Future<void> updateCharacter(String id, String name, String bio,
      Uint8List image, bool showOnHomepage, String status, String order) async {
    emit(const CrudState.loading());
    var result = await uploadApi
        .updateCharacter(id, name, bio, image, showOnHomepage, status, order)
        .sealed();
    emitSealed(result, success: (data) => const CrudState.successfulCreate());
  }

  void updateVideo(
      String id,
      String title,
      Iterable<String> channels,
      Uint8List thumbnail,
      String? transcript,
      html.File? file,
      String? caption,
      String status,
      DateTime? publishDate,
      bool? premiumContentFlag,
      VideoCreator? videoCreator,
      UploadingPhoto? trendImage,
      bool isTrend,
      bool isFavorite,
      bool excludeAndroid) async {
    emit(const CrudState.loading());

    var result = await uploadApi
        .updateVideo(
            id,
            title,
            channels,
            thumbnail,
            transcript,
            caption,
            status,
            publishDate,
            premiumContentFlag,
            videoCreator?.id,
            trendImage,
            isTrend,
            isFavorite,
            excludeAndroid)
        .sealed();

    if (file != null) {
      result.fold(
        onSuccess: (value) async {
          final authRepository = await inject<AuthRepository>().getToken();

          var data = {'file': file};

          LargeFileUploader.upload(
              method: 'PATCH',
              uploadUrl: '${uploadApi.dio.options.baseUrl}videos/videos/$id/',
              onSendProgress: (progress) =>
                  emit(CrudState.onProgress(progress: progress)),
              onComplete: (response) =>
                  emit(const CrudState.successfulCreate()),
              headers: {
                'Authorization': 'Bearer ${authRepository?.access ?? ''}'
              },
              data: data);
        },
        onError: (error) async {
          emit(CrudState.failure(error: error));
        },
      );
    } else {
      emitSealed(result, success: (data) => const CrudState.successfulCreate());
    }
  }

  void updateStory(
      String id,
      String title,
      String shortDesc,
      String body,
      Uint8List? coverImage,
      Uint8List? showcaseSmall,
      Uint8List? showcaseMedium,
      Uint8List? showcaseTall,
      Uint8List? showcaseExtended,
      Uint8List? featuredImage,
      List<String> categories,
      List<String> characters,
      Map<dynamic, bool> flags,
      String status,
      html.File? audio,
      DateTime? publishDate,
      bool? premiumContentFlag,
      String transcript,
      {Uint8List? androidImage}) async {
    emit(const CrudState.loading());

    var result = await uploadApi
        .updateStory(
            id,
            title,
            body,
            shortDesc,
            showcaseExtended,
            showcaseTall,
            showcaseMedium,
            showcaseSmall,
            coverImage,
            featuredImage,
            categories,
            characters,
            flags,
            status,
            publishDate,
            premiumContentFlag,
            transcript,
            androidImage: androidImage)
        .sealed();

    if (audio != null) {
      result.fold(
        onSuccess: (value) async {
          final videoModel = Video.fromJson(value.data);

          final authRepository = await inject<AuthRepository>().getToken();
          LargeFileUploader.upload(
              method: 'PATCH',
              uploadUrl:
                  '${uploadApi.dio.options.baseUrl}stories/stories/${videoModel.id}/',
              onSendProgress: (progress) => emit(CrudState.onProgress(progress: progress)),
              onComplete: (response) => emit(const CrudState.successfulCreate()),
              headers: {
                'Authorization': 'Bearer ${authRepository?.access ?? ''}'
              },
              data: {
                'audio': audio
              });
        },
        onError: (error) async {
          emit(CrudState.failure(error: error));
        },
      );
    } else {
      emitSealed(result, success: (data) => const CrudState.successfulCreate());
    }
  }

  Uint8List? getOrNullImage(Map<String, dynamic> formData, String key) {
    if (formData.containsKey(key) && formData[key] != null) {
      return (formData[key] as List<dynamic>).first as Uint8List;
    }
    return null;
  }

  PlatformFile? getOrNullFile(Map<String, dynamic> formData, String key) {
    if (formData.containsKey(key) && formData[key] != null) {
      return (formData[key] as List<dynamic>).first as PlatformFile;
    }
    return null;
  }
}

@Sealed()
abstract class _CrudState {
  void initial();

  void loading();

  void deleting();

  void itemsDeleted();

  void onProgress(int progress);

  void getSettings(HelpUrls helpUrls);

  void getAllCommodities(List<Commodity> allCommodities);

  void getAllVideoCreators(List<VideoCreator> allVideoCreators);

  void getAllPromotions(List<Promotion> allPromotions);

  void getAllCategories(AllCategories allCategories);

  void getAllStaffs(AllStaffs allStaffs);

  void successfulCreate();

  void getAllCharacters(AllCharacters allCharacters);

  void getAllSections(AllSections allSections);

  void getAllStories(AllStories allStories);

  void getAllChannels(AllChannel allChannel);

  void getAllVideos(AllVideo allVideo);

  void getCharacter(Character character);

  void getUser(User user);

  void getStaff(Staff staff);

  void getStory(
      Story story, List<Character> characters, List<Category> categories);

  void getCategory(Category category);

  void getVideo(
      Video video, List<Channel> channels, List<VideoCreator> videoCreators);

  void getChannel(Channel channel);

  void failure(@WithType('VibeError') error);

  void getAddStoryFormData(AllCharacters characters, AllCategories categories);
}
