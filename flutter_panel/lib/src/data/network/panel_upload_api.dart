import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:vibes_common/vibes.dart';

class VibesPanelUploadApi {
  VibesPanelUploadApi(this.dio);

  final Dio dio;

  Future<VideoCreator> addVideoCreator(
      UpdatingVideoCreator videoCreator) async {
    final data = FormData.fromMap(videoCreator.toJson());
    return await dio
        .post('/videos/creators/', data: data)
        .then((res) => VideoCreator.fromJson(res.data));
  }

  Future<VideoCreator> updateVideoCreator(
      int id, UpdatingVideoCreator videoCreator) async {
    final data = FormData.fromMap(videoCreator.toJson());
    return await dio
        .patch('/videos/creators/$id/', data: data)
        .then((res) => VideoCreator.fromJson(res.data));
  }

  Future addCommodity(
      int? order,
      String name,
      String? bluetoothName,
      String? shopUrl,
      int? numberOfMotors,
      Uint8List shopImage,
      Uint8List? controllerImage,
      bool isToy,
      String motor1Name,
      String motor2Name) async {
    final fields = {
      'name': name,
      'shop_picture':
          MultipartFile.fromBytes(shopImage, filename: 'upload.png'),
      'is_toy': isToy,
      'motor_name1': motor1Name,
      'motor_name2': motor2Name,
    };
    if (order != null) fields.addAll({'ordering': order});
    if (bluetoothName != null && bluetoothName.isNotEmpty) {
      fields.addAll({'bluetooth_name': bluetoothName});
    }
    if (shopUrl != null && shopUrl.isNotEmpty) {
      fields.addAll({'shop_url': shopUrl});
    }
    if (numberOfMotors != null) {
      fields.addAll({'number_of_motors': numberOfMotors});
    }
    if (controllerImage != null) {
      fields.addAll({
        'controller_page_picture':
            MultipartFile.fromBytes(controllerImage, filename: 'upload.png')
      });
    }

    final formData = FormData.fromMap(fields);
    return await dio.post('/studio/devices/', data: formData);
  }

  Future updateCommodity(
      int id,
      int? order,
      String name,
      String? bluetoothName,
      String? shopUrl,
      int? numberOfMotors,
      Uint8List shopImage,
      Uint8List? controllerImage,
      bool isToy,
      String motor1Name,
      String motor2Name,
      String motor3Name) async {
    final fields = {
      'name': name,
      'shop_picture':
          MultipartFile.fromBytes(shopImage, filename: 'upload.png'),
      'is_toy': isToy,
      'motor_name1': motor1Name,
      'motor_name2': motor2Name,
      'motor_name3': motor3Name,
    };
    if (order != null) fields.addAll({'ordering': order});
    if (bluetoothName != null && bluetoothName.isNotEmpty) {
      fields.addAll({'bluetooth_name': bluetoothName});
    }
    if (shopUrl != null && shopUrl.isNotEmpty) {
      fields.addAll({'shop_url': shopUrl});
    }
    if (numberOfMotors != null) {
      fields.addAll({'number_of_motors': numberOfMotors});
    }
    if (controllerImage != null) {
      fields.addAll({
        'controller_page_picture':
            MultipartFile.fromBytes(controllerImage, filename: 'upload.png')
      });
    }

    final formData = FormData.fromMap(fields);
    return await dio.patch('/studio/devices/$id/', data: formData);
  }

  Future<dynamic> addCharacter(String name, String bio, Uint8List profileImage,
      bool showOnHomepage, String order) async {
    var formData = FormData.fromMap({
      'order': order,
      'first_name': name,
      'bio': bio,
      'profile_image': MultipartFile.fromBytes(
        profileImage,
        filename: 'upload.png',
      ),
      'show_on_homepage': showOnHomepage,
    });
    return await dio.post('stories/characters/', data: formData);
  }

  Future<dynamic> addCategory(Uint8List? image, String title, bool tileView,
      UploadingPhoto? androidImage) async {
    var formData = FormData.fromMap({
      'title': title,
      'tile_view': tileView,
      'image': image == null
          ? null
          : MultipartFile.fromBytes(
              image,
              filename: 'upload.png',
            ),
      'android_image': androidImage == null
          ? null
          : MultipartFile.fromBytes(
              androidImage,
              filename: 'upload.png',
            ),
    });
    return await dio.post('stories/categories/', data: formData);
  }

  Future<dynamic> addUser(
    Uint8List? image,
    String firstName,
    String lastName,
  ) async {
    var formData = FormData.fromMap({
      'first_name': firstName,
      'last_name': lastName,
      'image': image == null
          ? null
          : MultipartFile.fromBytes(
              image,
              filename: 'upload.png',
            )
    });
    return await dio.post('stories/categories/', data: formData);
  }

  Future<dynamic> addStory({
    required String title,
    required String shortDescription,
    required String description,
    required Uint8List imageCover,
    Uint8List? imageShowcaseExtended,
    Uint8List? imageShowcaseTall,
    Uint8List? imageShowcaseMedium,
    Uint8List? imageShowcaseSmall,
    Uint8List? featuredImage,
    Uint8List? androidImage,
    List<String> categories = const [],
    List<String> characters = const [],
    Iterable<String> flags = const [],
    bool? premiumContent,
    required String transcript,
  }) async {
    const extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final data = FormData();
    data.fields.add(MapEntry('title', title));
    data.fields.add(MapEntry('description', description));
    data.fields.add(MapEntry('short_description', shortDescription));
    data.fields.add(MapEntry('transcript', transcript));

    if (featuredImage != null) {
      data.files.add(MapEntry('image_full',
          MultipartFile.fromBytes(featuredImage, filename: 'upload.png')));
    }
    if (androidImage != null) {
      data.files.add(MapEntry('android_image',
          MultipartFile.fromBytes(androidImage, filename: 'upload.png')));
    }
    if (imageShowcaseExtended != null) {
      data.files.add(MapEntry(
          'image_showcase_extended',
          MultipartFile.fromBytes(imageShowcaseExtended,
              filename: 'upload.png')));
    }
    if (imageShowcaseTall != null) {
      data.files.add(MapEntry('image_showcase_tall',
          MultipartFile.fromBytes(imageShowcaseTall, filename: 'upload.png')));
    }
    if (imageShowcaseMedium != null) {
      data.files.add(MapEntry(
          'image_showcase_medium',
          MultipartFile.fromBytes(imageShowcaseMedium,
              filename: 'upload.png')));
    }
    if (imageShowcaseSmall != null) {
      data.files.add(MapEntry('image_showcase_small',
          MultipartFile.fromBytes(imageShowcaseSmall, filename: 'upload.png')));
    }
    data.files.add(MapEntry('image_cover',
        MultipartFile.fromBytes(imageCover, filename: 'upload.png')));

    for (var i in categories) {
      data.fields.add(MapEntry('categories', i));
    }
    for (var i in characters) {
      data.fields.add(MapEntry('characters', i));
    }
    for (var f in flags) {
      data.fields.add(MapEntry(f, true.toString()));
    }
    if (premiumContent != null) {
      data.fields.add(MapEntry('paid', premiumContent.toString()));
    }
    var result = await dio.fetch<void>(_setStreamType<void>(
        Options(method: 'POST', headers: <String, dynamic>{}, extra: extra)
            .compose(dio.options, 'stories/stories/',
                queryParameters: queryParameters, data: data)
            .copyWith(baseUrl: dio.options.baseUrl)));
    return result;
  }

  RequestOptions _setStreamType<T>(RequestOptions requestOptions) {
    if (T != dynamic &&
        !(requestOptions.responseType == ResponseType.bytes ||
            requestOptions.responseType == ResponseType.stream)) {
      if (T == String) {
        requestOptions.responseType = ResponseType.plain;
      } else {
        requestOptions.responseType = ResponseType.json;
      }
    }
    return requestOptions;
  }

  Future<dynamic> addVideo(
    String title,
    Iterable<String> channelIds,
    Uint8List? thumbnail,
    String? caption,
    String? transcript,
    bool? premiumContent,
    int? videoCreatorId,
    UploadingPhoto? trendImage,
    bool isTrend,
    bool isFavorite,
    bool excludeAndroid,
  ) async {
    const extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final data = FormData();
    data.fields.add(MapEntry('title', title));
    data.fields.add(MapEntry('exclude_android', excludeAndroid.toString()));

    for (final channelId in channelIds) {
      data.fields.add(MapEntry('channels', channelId));
    }

    if (thumbnail != null) {
      data.files.add(MapEntry('thumbnail',
          MultipartFile.fromBytes(thumbnail, filename: 'upload.jpeg')));
    }

    if (caption != null) {
      data.fields.add(MapEntry('caption', caption));
    }

    if (transcript != null) {
      data.fields.add(MapEntry('transcript', transcript));
    }
    if (premiumContent != null) {
      data.fields.add(MapEntry('paid', premiumContent.toString()));
    }
    if (videoCreatorId != null) {
      data.fields.add(MapEntry('creator', videoCreatorId.toString()));
    }
    if (trendImage != null) {
      data.files.add(MapEntry('trend_image',
          MultipartFile.fromBytes(trendImage, filename: 'upload.png')));
    }
    data.fields.add(MapEntry('is_trend', isTrend.toString()));
    data.fields.add(MapEntry('is_favorite', isFavorite.toString()));

    var result = await dio.fetch<void>(_setStreamType<void>(
        Options(method: 'POST', headers: <String, dynamic>{}, extra: extra)
            .compose(dio.options, 'videos/videos/',
                queryParameters: queryParameters, data: data)
            .copyWith(baseUrl: dio.options.baseUrl)));
    return result;
  }

  Future<dynamic> addChannel(
      String title, String description, Uint8List image) async {
    const extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final data = FormData();
    data.fields.add(MapEntry('title', title));
    data.fields.add(MapEntry('description', description));
    data.files.add(MapEntry(
        'image', MultipartFile.fromBytes(image, filename: 'upload.png')));

    var result = await dio.fetch<void>(_setStreamType<void>(
        Options(method: 'POST', headers: <String, dynamic>{}, extra: extra)
            .compose(dio.options, 'videos/channels/',
                queryParameters: queryParameters, data: data)
            .copyWith(baseUrl: dio.options.baseUrl)));
    return result;
  }

  Future<dynamic> updateChannel(String id, String title, String description,
      Uint8List? image, DateTime? publishDate) async {
    const extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final data = FormData();
    data.fields.add(MapEntry('title', title));
    data.fields.add(MapEntry('description', description));
    if (image != null) {
      data.files.add(MapEntry(
          'image', MultipartFile.fromBytes(image, filename: 'upload.png')));
    }
    data.fields.add(
        MapEntry('published_date', publishDate?.toIso8601String() ?? 'null'));
    var result = await dio.fetch<void>(_setStreamType<void>(
        Options(method: 'PATCH', headers: <String, dynamic>{}, extra: extra)
            .compose(dio.options, 'videos/channels/$id/',
                queryParameters: queryParameters, data: data)
            .copyWith(baseUrl: dio.options.baseUrl)));
    return result;
  }

  Future<dynamic> updateCategory(
      String id,
      String title,
      bool tileView,
      Uint8List? image,
      String status,
      DateTime? publishDate,
      UploadingPhoto? androidImage) async {
    const extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final data = FormData();
    data.fields.add(MapEntry('title', title));
    data.fields.add(MapEntry('tile_view', tileView.toString()));
    data.fields.add(MapEntry('state', status));
    if (publishDate != null) {
      data.fields
          .add(MapEntry('published_date', publishDate.toIso8601String()));
    }
    if (image != null) {
      data.files.add(MapEntry(
          'image', MultipartFile.fromBytes(image, filename: 'upload.png')));
    }
    if (androidImage != null) {
      data.files.add(MapEntry('android_image',
          MultipartFile.fromBytes(androidImage, filename: 'upload.png')));
    }
    var result = await dio.fetch<void>(_setStreamType<void>(
        Options(method: 'PATCH', headers: <String, dynamic>{}, extra: extra)
            .compose(dio.options, 'stories/categories/$id/',
                queryParameters: queryParameters, data: data)
            .copyWith(baseUrl: dio.options.baseUrl)));
    return result;
  }

  Future<dynamic> updateCharacter(
    String id,
    String firstName,
    String bio,
    Uint8List? image,
    bool showOnHomepage,
    String status,
    String order,
  ) async {
    const extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final data = FormData();
    data.fields.add(MapEntry('order', order));
    data.fields.add(MapEntry('first_name', firstName));
    data.fields.add(MapEntry('bio', bio));
    data.fields.add(MapEntry('show_on_homepage', showOnHomepage.toString()));
    data.fields.add(MapEntry('state', status));
    if (image != null) {
      data.files.add(MapEntry('profile_image',
          MultipartFile.fromBytes(image, filename: 'upload.png')));
    }
    var result = await dio.fetch<void>(_setStreamType<void>(
        Options(method: 'PATCH', headers: <String, dynamic>{}, extra: extra)
            .compose(dio.options, 'stories/characters/$id/',
                queryParameters: queryParameters, data: data)
            .copyWith(baseUrl: dio.options.baseUrl)));
    return result;
  }

  Future<dynamic> updateStaff(
    String id,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? password,
  ) async {
    const extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final data = FormData();

    if (firstName != null) data.fields.add(MapEntry('first_name', firstName));
    if (lastName != null) data.fields.add(MapEntry('last_name', lastName));
    if (phoneNumber != null) {
      data.fields.add(MapEntry('phone_number', phoneNumber));
    }
    if (password != null) data.fields.add(MapEntry('password', password));

    var result = await dio.fetch<void>(_setStreamType<void>(
        Options(method: 'PATCH', headers: <String, dynamic>{}, extra: extra)
            .compose(dio.options, 'users/staffs/$id/',
                queryParameters: queryParameters, data: data)
            .copyWith(baseUrl: dio.options.baseUrl)));
    return result;
  }

  Future<dynamic> updateVideo(
      String id,
      String title,
      Iterable<String> channelIds,
      Uint8List? thumbnail,
      String? transcript,
      String? caption,
      String status,
      DateTime? publishDate,
      bool? premiumContent,
      int? videoCreatorId,
      UploadingPhoto? trendImage,
      bool isTrend,
      bool isFavorite,
      bool excludeAndroid) async {
    const extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final data = FormData();
    data.fields.add(MapEntry('title', title));
    data.fields.add(MapEntry('state', status));
    data.fields.add(MapEntry('exclude_android', excludeAndroid.toString()));
    if (thumbnail != null) {
      data.files.add(MapEntry('thumbnail',
          MultipartFile.fromBytes(thumbnail, filename: 'upload.png')));
    }

    if (transcript != null) {
      data.fields.add(MapEntry('transcript', transcript));
    }

    if (caption != null) {
      data.fields.add(MapEntry('caption', caption));
    }

    for (final channelId in channelIds) {
      data.fields.add(MapEntry('channels', channelId));
    }

    data.fields.add(
        MapEntry('published_date', publishDate?.toIso8601String() ?? 'null'));
    if (premiumContent != null) {
      data.fields.add(MapEntry('paid', premiumContent.toString()));
    }
    if (videoCreatorId != null) {
      data.fields.add(MapEntry('creator', videoCreatorId.toString()));
    }
    if (trendImage != null) {
      data.files.add(MapEntry('trend_image',
          MultipartFile.fromBytes(trendImage, filename: 'upload.png')));
    }
    data.fields.add(MapEntry('is_trend', isTrend.toString()));
    data.fields.add(MapEntry('is_favorite', isFavorite.toString()));

    var result = await dio.fetch<void>(_setStreamType<void>(
        Options(method: 'PATCH', headers: <String, dynamic>{}, extra: extra)
            .compose(dio.options, 'videos/videos/$id/',
                queryParameters: queryParameters, data: data)
            .copyWith(baseUrl: dio.options.baseUrl)));
    return result;
  }

  Future<dynamic> updateStory(
      String id,
      String title,
      String body,
      String shortDescription,
      Uint8List? showcaseExtended,
      Uint8List? showcaseTall,
      Uint8List? showcaseMedium,
      Uint8List? showcaseSmall,
      Uint8List? coverPhoto,
      Uint8List? featuredImage,
      List<String> categories,
      List<String> characters,
      Map<dynamic, bool> flags,
      String status,
      DateTime? publishDate,
      bool? premiumContent,
      String transcript,
      {Uint8List? androidImage}) async {
    const extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final data = FormData();
    data.fields.add(MapEntry('title', title));
    data.fields.add(MapEntry('description', body));
    data.fields.add(MapEntry('short_description', shortDescription));
    data.fields.add(MapEntry('transcript', transcript));
    data.fields.add(MapEntry('state', status));
    if (featuredImage != null) {
      data.files.add(MapEntry('image_full',
          MultipartFile.fromBytes(featuredImage, filename: 'upload.png')));
    }
    if (androidImage != null) {
      data.files.add(MapEntry('android_image',
          MultipartFile.fromBytes(androidImage, filename: 'upload.png')));
    }
    if (showcaseExtended != null) {
      data.files.add(MapEntry('image_showcase_extended',
          MultipartFile.fromBytes(showcaseExtended, filename: 'upload.png')));
    }
    if (showcaseTall != null) {
      data.files.add(MapEntry('image_showcase_tall',
          MultipartFile.fromBytes(showcaseTall, filename: 'upload.png')));
    }
    if (showcaseMedium != null) {
      data.files.add(MapEntry('image_showcase_medium',
          MultipartFile.fromBytes(showcaseMedium, filename: 'upload.png')));
    }
    if (showcaseSmall != null) {
      data.files.add(MapEntry('image_showcase_small',
          MultipartFile.fromBytes(showcaseSmall, filename: 'upload.png')));
    }
    if (coverPhoto != null) {
      data.files.add(MapEntry('image_cover_photo',
          MultipartFile.fromBytes(coverPhoto, filename: 'upload.png')));
    }
    for (var i in categories) {
      data.fields.add(MapEntry('categories', i));
    }
    for (var i in characters) {
      data.fields.add(MapEntry('characters', i));
    }
    flags.forEach((flag, value) {
      data.fields.add(MapEntry(flag, value.toString()));
    });
    data.fields.add(
        MapEntry('published_date', publishDate?.toIso8601String() ?? 'null'));
    if (premiumContent != null) {
      data.fields.add(MapEntry('paid', premiumContent.toString()));
    }
    var result = await dio.fetch<void>(_setStreamType<void>(
        Options(method: 'PATCH', headers: <String, dynamic>{}, extra: extra)
            .compose(dio.options, 'stories/stories/$id/',
                queryParameters: queryParameters, data: data)
            .copyWith(baseUrl: dio.options.baseUrl)));
    return result;
  }
}
