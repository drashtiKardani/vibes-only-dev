// ignore_for_file: non_constant_identifier_names

import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:sealed_annotations/sealed_annotations.dart';

part 'models.g.dart';

@JsonSerializable()
class AllStaffs {
  int count;
  String? next;
  String? previous;
  List<Staff> results;

  AllStaffs({
    required this.count,
    required this.results,
    this.next,
    this.previous,
  });

  factory AllStaffs.fromJson(Map<String, dynamic> json) =>
      _$AllStaffsFromJson(json);

  Map<String, dynamic> toJson() => _$AllStaffsToJson(this);
}

@JsonSerializable()
class ShortStaff {
  String? email;
  String? password;
  @JsonKey(name: 'first_name')
  String? firstName;
  @JsonKey(name: 'last_name')
  String? lastName;
  @JsonKey(name: 'phone_number')
  String? phoneNumber;

  ShortStaff({
    this.email,
    this.password,
    this.firstName,
    this.lastName,
    this.phoneNumber,
  });

  factory ShortStaff.fromJson(Map<String, dynamic> json) =>
      _$ShortStaffFromJson(json);

  Map<String, dynamic> toJson() => _$ShortStaffToJson(this);
}

@JsonSerializable()
class Staff {
  int id;
  String user;
  String? email;
  @JsonKey(name: 'phone_number')
  String? phoneNumber;
  @JsonKey(name: 'first_name')
  String? firstName;
  @JsonKey(name: 'last_name')
  String? lastName;
  @JsonKey(name: 'profile_image')
  String? profileImage;

  Staff({required this.id, required this.user, this.firstName, this.lastName});

  factory Staff.fromJson(Map<String, dynamic> json) => _$StaffFromJson(json);

  Map<String, dynamic> toJson() => _$StaffToJson(this);
}

@JsonSerializable()
class NetworkError {
  String message;
  int code;

  NetworkError({required this.message, required this.code});

  factory NetworkError.fromJson(Map<String, dynamic> json) =>
      _$NetworkErrorFromJson(json);

  Map<String, dynamic> toJson() => _$NetworkErrorToJson(this);
}

@JsonSerializable()
class ShortCategory {
  String title;
  String? image;
  bool tileView;

  ShortCategory({this.image, required this.title, this.tileView = false});

  factory ShortCategory.fromJson(Map<String, dynamic> json) =>
      _$ShortCategoryFromJson(json);

  Map<String, dynamic> toJson() => _$ShortCategoryToJson(this);
}

@JsonSerializable()
class User {
  String id;
  String? user;
  @JsonKey(name: 'date_joined')
  DateTime? dateJoined;
  Profile? profile;

  User({required this.id, this.user, this.profile, this.dateJoined});

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);
}

@JsonSerializable()
class Profile {
  int id;
  @JsonKey(name: 'first_name')
  String? firstName;
  @JsonKey(name: 'last_name')
  String? lastName;
  @JsonKey(name: 'profile_image')
  String? profileImage;

  Profile({required this.id, this.firstName, this.lastName, this.profileImage});

  factory Profile.fromJson(Map<String, dynamic> json) =>
      _$ProfileFromJson(json);

  Map<String, dynamic> toJson() => _$ProfileToJson(this);
}

@JsonSerializable()
class ShortStory {
  String title;
  String description;
  String shortDescription;
  String? imageCover;
  String? imageFull;
  String? imageShowcaseExtended;
  String? imageShowcaseTall;
  String? imageShowcaseMedium;
  String? imageShowcaseSmall;
  String? audio;
  List<String> characters;
  List<String> categories;

  ShortStory({
    required this.title,
    required this.description,
    required this.shortDescription,
    this.imageCover,
    this.imageFull,
    this.imageShowcaseExtended,
    this.imageShowcaseTall,
    this.imageShowcaseMedium,
    this.imageShowcaseSmall,
    this.audio,
    required this.characters,
    required this.categories,
  });

  factory ShortStory.fromJson(Map<String, dynamic> json) =>
      _$ShortStoryFromJson(json);

  Map<String, dynamic> toJson() => _$ShortStoryToJson(this);
}

@JsonSerializable()
class ShortCharacter {
  String firstName;
  String profileImage;
  String bio;

  ShortCharacter({
    required this.profileImage,
    required this.firstName,
    required this.bio,
  });

  factory ShortCharacter.fromJson(Map<String, dynamic> json) =>
      _$ShortCharacterFromJson(json);

  Map<String, dynamic> toJson() => _$ShortCharacterToJson(this);
}

@JsonSerializable()
class Category {
  int id;
  String dateCreated;
  String? dateEdited;
  String? datePublished;
  String title;
  String? image;
  bool? tileView;
  String? creator;
  User? editor;
  String? publisher;
  List<int> relatedCategories;
  int? storiesCount;
  @JsonKey(name: 'state')
  String? status;
  @JsonKey(name: 'published_date')
  DateTime? publishDate;
  String? androidImage;

  Category({
    required this.id,
    required this.dateCreated,
    this.dateEdited,
    this.datePublished,
    required this.title,
    this.image,
    this.tileView,
    this.creator,
    this.editor,
    this.publisher,
    required this.relatedCategories,
    this.storiesCount,
    this.status,
    this.publishDate,
    this.androidImage,
  });

  factory Category.fromJson(Map<String, dynamic> json) =>
      _$CategoryFromJson(json);

  Map<String, dynamic> toJson() => _$CategoryToJson(this);
}

@JsonSerializable()
class Character {
  int id;
  int? order;
  String? dateCreated;
  String? dateEdited;
  String? datePublished;
  bool? isVisible;
  String? firstName;
  String? lastName;
  String bio;
  String profileImage;
  String? creator;
  User? editor;
  String? publisher;
  @JsonKey(name: 'stories_count')
  int? storiesCount;
  @JsonKey(name: 'show_on_homepage')
  bool? showOnHomepage;
  @JsonKey(name: 'state')
  String? status;

  Character({
    required this.id,
    this.dateCreated,
    this.dateEdited,
    this.datePublished,
    this.isVisible,
    this.firstName,
    this.lastName,
    required this.bio,
    required this.profileImage,
    this.creator,
    this.editor,
    this.publisher,
    this.storiesCount,
    this.showOnHomepage,
    this.status,
  });

  factory Character.fromJson(Map<String, dynamic> json) =>
      _$CharacterFromJson(json);

  Map<String, dynamic> toJson() => _$CharacterToJson(this);
}

@JsonSerializable()
class Story {
  int id;
  String? uid;
  String title;
  String description;
  String? shortDescription;
  String? imageCover;
  String? imageFull;
  String? imageShowcaseExtended;
  String? imageShowcaseTall;
  String? imageShowcaseMedium;
  String? imageShowcaseSmall;
  String? androidImage;
  String? audio;
  int? audioLengthSeconds;
  String? transcript;
  String? beat;
  String? creator;
  User? editor;
  String? publisher;
  List<Category> categories;
  List<Character> characters;
  @JsonKey(name: 'new')
  bool? neW;
  bool? featured;
  bool? trending;
  bool? top_10;
  @JsonKey(name: 'staff_pick')
  bool? staffPick;
  @JsonKey(name: 'published_date')
  DateTime? publishDate;
  @JsonKey(name: 'date_created')
  DateTime? dateCreated;
  @JsonKey(name: 'date_approved')
  DateTime? dateApproved;
  @JsonKey(name: 'date_published')
  DateTime? datePublished;
  @JsonKey(name: 'date_edited')
  DateTime? dateEdited;
  @JsonKey(name: 'state')
  String? status;
  bool? paid;
  int? view_count_hour;
  int? view_count_day;
  int? view_count_total;

  Story({
    required this.id,
    this.uid,
    required this.title,
    required this.description,
    this.shortDescription,
    this.imageCover,
    this.imageFull,
    this.imageShowcaseExtended,
    this.imageShowcaseTall,
    this.imageShowcaseMedium,
    this.imageShowcaseSmall,
    this.androidImage,
    this.audio,
    this.audioLengthSeconds,
    this.transcript,
    this.beat,
    this.creator,
    this.editor,
    this.publisher,
    required this.categories,
    required this.characters,
    this.neW,
    this.featured,
    this.trending,
    this.top_10,
    this.staffPick,
    this.dateCreated,
    this.dateEdited,
    this.datePublished,
    this.dateApproved,
    this.status,
    this.paid,
    this.view_count_hour,
    this.view_count_day,
    this.view_count_total,
  });

  String thumbnail(Style style) {
    switch (style) {
      case Style.avatar:
        return imageShowcaseMedium ?? '';
      case Style.card:
        return imageShowcaseMedium ?? '';
      case Style.promotionFull:
        return imageFull ?? '';
      case Style.showcaseExpanded:
        return imageShowcaseExtended ?? '';
      case Style.showcaseMedium:
        return imageShowcaseMedium ?? '';
      case Style.showcaseTall:
        return imageShowcaseTall ?? '';
      case Style.showcaseSmall:
        return imageShowcaseSmall ?? '';
      case Style.wrappedChips:
        return imageShowcaseMedium ?? '';
      case Style.swiper:
        return imageFull ?? '';
    }
  }

  factory Story.fromJson(Map<String, dynamic> json) => _$StoryFromJson(json);

  Map<String, dynamic> toJson() => _$StoryToJson(this);
}

@JsonSerializable()
class Section {
  Section({
    required this.id,
    required this.isVisible,
    required this.title,
    required this.contentType,
    required this.style,
    this.containingStories = const [],
    this.characters = const [],
    this.categories = const [],
    this.videos = const [],
    this.channels = const [],
    this.videoCreators = const [],
  });

  int id;
  bool? isVisible;
  String title;
  String contentType;
  Style style;
  List<Story> containingStories;
  List<Character> characters;
  List<Category> categories;
  List<Video>? videos;
  List<Channel> channels;
  List<VideoCreator> videoCreators;

  factory Section.fromJson(Map<String, dynamic> json) =>
      _$SectionFromJson(json);

  Map<String, dynamic> toJson() => _$SectionToJson(this);
}

@JsonSerializable()
class Home {
  Home({required this.sections});

  final List<Section> sections;

  factory Home.fromJson(Map<String, dynamic> json) => _$HomeFromJson(json);

  Map<String, dynamic> toJson() => _$HomeToJson(this);
}

enum Style {
  @JsonValue('SHOWCASE_TALL')
  showcaseTall,
  @JsonValue('SHOWCASE_SMALL')
  showcaseSmall,
  @JsonValue('SHOWCASE_MEDIUM')
  showcaseMedium,
  @JsonValue('SHOWCASE_EXPANDED')
  showcaseExpanded,
  @JsonValue('CARD')
  card,
  @JsonValue('WRAPPED_CHIPS')
  wrappedChips,
  @JsonValue('AVATAR')
  avatar,
  @JsonValue('PROMOTION_FULL')
  promotionFull,
  @JsonValue('SWIPER')
  swiper,
}

@JsonSerializable()
class LoginByEmail {
  String email;
  String password;

  LoginByEmail({required this.email, required this.password});

  factory LoginByEmail.fromJson(Map<String, dynamic> json) =>
      _$LoginByEmailFromJson(json);

  Map<String, dynamic> toJson() => _$LoginByEmailToJson(this);
}

@JsonSerializable()
class LoginResponse {
  String? status;
  String message;
  Tokens data;

  LoginResponse({this.status, required this.message, required this.data});

  factory LoginResponse.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseFromJson(json);

  Map<String, dynamic> toJson() => _$LoginResponseToJson(this);
}

@JsonSerializable()
class TwoFACode {
  String code;
  String email;

  TwoFACode({required this.code, required this.email});

  factory TwoFACode.fromJson(Map<String, dynamic> json) =>
      _$TwoFACodeFromJson(json);

  Map<String, dynamic> toJson() => _$TwoFACodeToJson(this);
}

@JsonSerializable()
class Tokens {
  String refresh;
  String access;

  Tokens({required this.refresh, required this.access});

  factory Tokens.fromJson(Map<String, dynamic> json) => _$TokensFromJson(json);

  Map<String, dynamic> toJson() => _$TokensToJson(this);
}

enum PushMessageAudience { all, paid, free }

enum PushMessageDestination { tabHome, tabVideos, video, story }

@JsonSerializable()
class PushMessage {
  String title;
  String body;
  PushMessageAudience target;
  Map<String, dynamic> data;
  DateTime? scheduledFor;

  PushMessage({
    required this.title,
    required this.body,
    required this.target,
    PushMessageDestination destination = PushMessageDestination.tabHome,
    int? pageId,
    this.scheduledFor,
  }) : data = _buildDataFrom(destination, pageId);

  factory PushMessage.fromJson(Map<String, dynamic> json) =>
      _$PushMessageFromJson(json);

  Map<String, dynamic> toJson() => _$PushMessageToJson(this);

  static Map<String, dynamic> _buildDataFrom(
    PushMessageDestination destination,
    int? pageId,
  ) {
    switch (destination) {
      case PushMessageDestination.tabHome:
        return {'tab': 'home'};
      case PushMessageDestination.tabVideos:
        return {'tab': 'videos'};
      case PushMessageDestination.video:
        return {'video': pageId};
      case PushMessageDestination.story:
        return {'story': pageId};
    }
  }
}

@JsonSerializable()
class PushResponse {
  int id;
  String title;
  String body;
  Map<String, dynamic>? data;
  String target;
  String status;
  @JsonKey(name: 'scheduled_for')
  DateTime? scheduledFor;
  @JsonKey(name: 'created_at')
  DateTime createdAt;

  PushResponse({
    required this.id,
    required this.title,
    required this.body,
    required this.data,
    required this.target,
    required this.status,
    required this.scheduledFor,
    required this.createdAt,
  });

  factory PushResponse.fromJson(Map<String, dynamic> json) =>
      _$PushResponseFromJson(json);

  Map<String, dynamic> toJson() => _$PushResponseToJson(this);
}

@JsonSerializable()
class AllCategories {
  int count;
  String? next;
  String? previous;
  List<Category> results;

  AllCategories({
    required this.count,
    required this.results,
    this.next,
    this.previous,
  });

  factory AllCategories.fromJson(Map<String, dynamic> json) =>
      _$AllCategoriesFromJson(json);

  Map<String, dynamic> toJson() => _$AllCategoriesToJson(this);
}

@JsonSerializable()
class AllCharacters {
  int count;
  String? next;
  String? previous;
  List<Character> results;

  AllCharacters({
    required this.count,
    required this.results,
    this.next,
    this.previous,
  });

  factory AllCharacters.fromJson(Map<String, dynamic> json) =>
      _$AllCharactersFromJson(json);

  Map<String, dynamic> toJson() => _$AllCharactersToJson(this);
}

@JsonSerializable()
class AllUsers {
  int count;
  String? next;
  String? previous;
  List<User> results;

  AllUsers({
    required this.count,
    required this.results,
    this.next,
    this.previous,
  });

  factory AllUsers.fromJson(Map<String, dynamic> json) =>
      _$AllUsersFromJson(json);

  Map<String, dynamic> toJson() => _$AllUsersToJson(this);
}

@JsonSerializable()
class AllStories {
  int count;
  String? next;
  String? previous;
  List<Story> results;

  AllStories({
    required this.count,
    required this.results,
    this.next,
    this.previous,
  });

  factory AllStories.fromJson(Map<String, dynamic> json) =>
      _$AllStoriesFromJson(json);

  Map<String, dynamic> toJson() => _$AllStoriesToJson(this);
}

@JsonSerializable()
class AllSections {
  int count;
  String? next;
  String? previous;
  List<Section> results;

  AllSections({
    required this.count,
    required this.results,
    this.next,
    this.previous,
  });

  factory AllSections.fromJson(Map<String, dynamic> json) =>
      _$AllSectionsFromJson(json);

  Map<String, dynamic> toJson() => _$AllSectionsToJson(this);
}

@JsonSerializable()
class SearchResult {
  final Story? story;
  final Character? character;
  final Category? category;
  final Video? video;

  SearchResult({this.story, this.character, this.category, this.video});

  factory SearchResult.fromJson(Map<String, dynamic> json) =>
      _$SearchResultFromJson(json);

  Map<String, dynamic> toJson() => _$SearchResultToJson(this);
}

@JsonSerializable()
class Video {
  int id;
  bool? isVisible;
  String title;
  int? index;
  String? file;
  String? shortStart;
  String? shortEnd;
  List<int> channels;
  String? channelName;
  String? thumbnail;
  ProcessedFiles? processedFiles;
  String? caption;
  String? transcript;
  @JsonKey(name: 'published_date')
  DateTime? publishDate;
  @JsonKey(name: 'state')
  String? status;
  @JsonKey(name: 'date_created')
  DateTime? dateCreated;
  @JsonKey(name: 'date_published')
  DateTime? datePublished;
  @JsonKey(name: 'video_quality_status')
  String? videoQualityStatus;
  @JsonKey(name: 'video_short_version_status')
  String? videoShortVersionStatus;
  @JsonKey(name: 'transcript_status')
  String? transcriptStatus;
  bool? paid;
  int? view_count_hour;
  int? view_count_day;
  int? view_count_total;
  @JsonKey(name: 'creator')
  @VideoCreatorIdConverter()
  int? creatorId;
  String? trendImage;
  bool? isTrend;
  bool? isFavorite;
  final bool? excludeAndroid;

  Video({
    required this.id,
    required this.title,
    this.isVisible,
    this.index,
    this.file,
    this.shortStart,
    this.shortEnd,
    required this.channels,
    this.channelName,
    this.thumbnail,
    this.processedFiles,
    this.status,
    this.caption,
    this.transcript,
    this.dateCreated,
    this.datePublished,
    this.videoQualityStatus,
    this.videoShortVersionStatus,
    this.transcriptStatus,
    this.paid,
    this.view_count_hour,
    this.view_count_day,
    this.view_count_total,
    this.creatorId,
    this.trendImage,
    this.isTrend,
    this.isFavorite,
    this.excludeAndroid,
  });

  factory Video.fromJson(Map<String, dynamic> json) => _$VideoFromJson(json);

  Map<String, dynamic> toJson() => _$VideoToJson(this);
}

/// This is a necessary but inconvenient wiring.
/// Server sends whole [VideoCreator] in one instance, and only its id in another.
/// We transform response, so that it holds the 'id' in any case.
class VideoCreatorIdConverter implements JsonConverter<int?, dynamic> {
  const VideoCreatorIdConverter();

  @override
  int? fromJson(dynamic json) {
    if (json is int?) {
      return json;
    }
    return json['id'];
  }

  @override
  dynamic toJson(int? object) => object;
}

@JsonSerializable()
class ProcessedFiles {
  @JsonKey(name: 'final')
  String? finalVideo;
  @JsonKey(name: 'final-360x640')
  String? finalVideo360;
  @JsonKey(name: 'final-576x1024')
  String? finalVideo576;
  @JsonKey(name: 'final-1080x1920')
  String? finalVideo1080;

  ProcessedFiles({
    required this.finalVideo,
    required this.finalVideo360,
    required this.finalVideo576,
    required this.finalVideo1080,
  });

  factory ProcessedFiles.fromJson(Map<String, dynamic> json) =>
      _$ProcessedFilesFromJson(json);

  Map<String, dynamic> toJson() => _$ProcessedFilesToJson(this);
}

@JsonSerializable()
class AllVideo {
  int count;
  String? next;
  String? previous;
  List<Video> results;

  AllVideo({
    required this.count,
    required this.results,
    this.next,
    this.previous,
  });

  factory AllVideo.fromJson(Map<String, dynamic> json) =>
      _$AllVideoFromJson(json);

  Map<String, dynamic> toJson() => _$AllVideoToJson(this);
}

@JsonSerializable()
class Channel {
  int id;
  bool? isVisible;
  String title;
  String? image;
  String? description;
  int videosCount;
  List<Video> videoList;
  @JsonKey(name: 'published_date')
  DateTime? publishDate;
  final bool isStaffChoice;
  final int order;

  Channel({
    required this.id,
    required this.title,
    this.isVisible,
    this.image,
    this.description,
    required this.videosCount,
    required this.videoList,
    required this.isStaffChoice,
    required this.order,
  });

  factory Channel.fromJson(Map<String, dynamic> json) =>
      _$ChannelFromJson(json);

  Map<String, dynamic> toJson() => _$ChannelToJson(this);
}

@JsonSerializable()
class AllChannel {
  int count;
  String? next;
  String? previous;
  List<Channel> results;

  AllChannel({
    required this.count,
    required this.results,
    this.next,
    this.previous,
  });

  factory AllChannel.fromJson(Map<String, dynamic> json) =>
      _$AllChannelFromJson(json);

  Map<String, dynamic> toJson() => _$AllChannelToJson(this);
}

@JsonSerializable()
class Device {
  @JsonKey(name: 'registration_id')
  String registrationId;
  String type;
  bool active;

  Device({
    required this.registrationId,
    required this.type,
    this.active = true,
  });

  factory Device.fromJson(Map<String, dynamic> json) => _$DeviceFromJson(json);

  Map<String, dynamic> toJson() => _$DeviceToJson(this);
}

@JsonSerializable()
class SubscriptionResponse {
  bool valid;
  @JsonKey(name: 'transaction_id')
  String transactionId;
  String exp;
  String package;

  SubscriptionResponse({
    required this.valid,
    required this.transactionId,
    required this.exp,
    required this.package,
  });

  factory SubscriptionResponse.fromJson(Map<String, dynamic> json) =>
      _$SubscriptionResponseFromJson(json);

  Map<String, dynamic> toJson() => _$SubscriptionResponseToJson(this);
}

@JsonSerializable()
class PurchaseVerificationData {
  String token;
  @JsonKey(name: 'subscription_id')
  String? subscriptionId;
  @JsonKey(name: 'device_id')
  String deviceId;

  PurchaseVerificationData({
    required this.token,
    this.subscriptionId,
    required this.deviceId,
  });

  factory PurchaseVerificationData.fromJson(Map<String, dynamic> json) =>
      _$PurchaseVerificationDataFromJson(json);

  Map<String, dynamic> toJson() => _$PurchaseVerificationDataToJson(this);
}

@JsonSerializable()
class Promotion {
  final int id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String title;
  final String body;
  final String code;
  final PromotionTarget target;
  final PromotionSubscriptionType? subscriptionType;
  final int? frequency;
  final int? daysSinceMembershipStart;
  final Constraint? daysSinceMembershipStartConstraint;
  final int? daysSinceRegistration;
  final Constraint? daysSinceRegistrationConstraint;
  final int? daysUntilSubscriptionEnd;
  final Constraint? daysUntilSubscriptionEndConstraint;

  Promotion({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.title,
    required this.body,
    required this.code,
    required this.target,
    this.subscriptionType,
    this.frequency,
    this.daysSinceMembershipStart,
    this.daysSinceMembershipStartConstraint,
    this.daysSinceRegistration,
    this.daysSinceRegistrationConstraint,
    this.daysUntilSubscriptionEnd,
    this.daysUntilSubscriptionEndConstraint,
  });

  factory Promotion.fromJson(Map<String, dynamic> json) =>
      _$PromotionFromJson(json);

  Map<String, dynamic> toJson() => _$PromotionToJson(this);
}

@JsonSerializable(includeIfNull: false)
class ShortPromotion {
  final String? title;
  final String? body;
  final String? code;
  final PromotionTarget? target;
  final PromotionSubscriptionType? subscriptionType;
  final int? frequency;
  final int? daysSinceMembershipStart;
  final Constraint? daysSinceMembershipStartConstraint;
  final int? daysSinceRegistration;
  final Constraint? daysSinceRegistrationConstraint;
  final int? daysUntilSubscriptionEnd;
  final Constraint? daysUntilSubscriptionEndConstraint;

  ShortPromotion({
    this.title,
    this.body,
    this.code,
    this.target,
    this.subscriptionType,
    this.frequency,
    this.daysSinceMembershipStart,
    this.daysSinceMembershipStartConstraint,
    this.daysSinceRegistration,
    this.daysSinceRegistrationConstraint,
    this.daysUntilSubscriptionEnd,
    this.daysUntilSubscriptionEndConstraint,
  });

  factory ShortPromotion.fromJson(Map<String, dynamic> json) =>
      _$ShortPromotionFromJson(json);

  Map<String, dynamic> toJson() => _$ShortPromotionToJson(this);
}

enum PromotionTarget { free, paid }

enum PromotionSubscriptionType {
  @JsonValue('monthly_billing')
  monthlyBilling,
  @JsonValue('annual_billing')
  annualBilling,
}

enum Constraint {
  @JsonValue('more_than')
  moreThan,
  @JsonValue('equals')
  equals,
  @JsonValue('less_than')
  lessThan,
}

@JsonSerializable()
class Commodity {
  final int id;
  final int ordering;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String name;
  final String? bluetoothName;
  final String? shopUrl;
  final int? numberOfMotors;
  final bool isToy;
  final String shopPicture;
  final String? controllerPagePicture;
  final String? motorName1;
  final String? motorName2;
  final String? motorName3;

  Commodity({
    required this.id,
    required this.ordering,
    required this.createdAt,
    required this.updatedAt,
    required this.name,
    this.bluetoothName,
    this.shopUrl,
    this.numberOfMotors,
    required this.isToy,
    required this.shopPicture,
    this.controllerPagePicture,
    this.motorName1,
    this.motorName2,
    this.motorName3,
  });

  factory Commodity.fromJson(Map<String, dynamic> json) =>
      _$CommodityFromJson(json);

  Map<String, dynamic> toJson() => _$CommodityToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class VideoCreator implements Equatable {
  final int id;
  final String name;
  final String photo;
  final String bio;
  final bool isStaffChoice;
  final int order;
  final DateTime dateCreated;

  VideoCreator({
    required this.id,
    required this.name,
    required this.photo,
    required this.bio,
    required this.isStaffChoice,
    required this.order,
    required this.dateCreated,
  });

  factory VideoCreator.fromJson(Map<String, dynamic> json) =>
      _$VideoCreatorFromJson(json);

  Map<String, dynamic> toJson() => _$VideoCreatorToJson(this);

  @override
  List<Object?> get props => [id];

  @override
  bool? get stringify => true;
}

/// Used to create/update a [VideoCreator].
@JsonSerializable(
  fieldRename: FieldRename.snake,
  createFactory: false,
  includeIfNull: false,
  explicitToJson: false,
)
class UpdatingVideoCreator {
  String? name;
  @UploadingPhotoConverter()
  UploadingPhoto? photo;
  String? bio;
  bool? isStaffChoice;
  int? order;

  UpdatingVideoCreator();

  Map<String, dynamic> toJson() => _$UpdatingVideoCreatorToJson(this);
}

/// Alias for data list of a photo that will be uploaded.
/// See [UploadingPhotoConverter], its converter for using with [dio].
typedef UploadingPhoto = Uint8List;

/// Converts [Uint8List] photos to be uploaded using [dio] lib.
class UploadingPhotoConverter
    implements JsonConverter<UploadingPhoto, MultipartFile> {
  const UploadingPhotoConverter();

  @override
  MultipartFile toJson(UploadingPhoto object) =>
      MultipartFile.fromBytes(object, filename: 'upload.png');

  @override
  UploadingPhoto fromJson(MultipartFile json) => throw UnimplementedError();
}

@JsonSerializable()
class HelpUrls {
  final String appleHelpUrl;
  final String androidHelpUrl;

  HelpUrls({required this.appleHelpUrl, required this.androidHelpUrl});

  factory HelpUrls.fromJson(Map<String, dynamic> json) =>
      _$HelpUrlsFromJson(json);

  Map<String, dynamic> toJson() => _$HelpUrlsToJson(this);
}

@JsonSerializable()
class AllGameCard {
  final int count;
  final String? next;
  final String? previous;
  final List<GameCard> results;

  const AllGameCard({
    required this.count,
    required this.next,
    required this.previous,
    required this.results,
  });

  factory AllGameCard.fromJson(Map<String, dynamic> json) =>
      _$AllGameCardFromJson(json);

  Map<String, dynamic> toJson() => _$AllGameCardToJson(this);
}

@JsonSerializable()
class GameCard {
  final int id;
  @JsonKey(name: 'section_type')
  final PromptType promptType;
  final String content;
  final String tag;
  final String status;

  GameCard({
    required this.id,
    required this.promptType,
    required this.content,
    required this.tag,
    required this.status,
  });

  factory GameCard.fromJson(Map<String, dynamic> json) =>
      _$GameCardFromJson(json);

  Map<String, dynamic> toJson() => _$GameCardToJson(this);
}

enum PromptType {
  @JsonValue('show_me')
  showMe,
  @JsonValue('tell_me')
  tellMe,
}

@JsonSerializable()
class AllManuals {
  final bool success;
  final String message;
  @JsonKey(name: 'data')
  final List<Manual> data;

  AllManuals({
    this.success = false,
    required this.message,
    this.data = const [],
  });

  factory AllManuals.fromJson(Map<String, dynamic> json) =>
      _$AllManualsFromJson(json);

  Map<String, dynamic> toJson() => _$AllManualsToJson(this);
}

@JsonSerializable()
class Manual {
  final int id;
  final String name;
  @JsonKey(name: 'controller_page_picture')
  final String controllerPagePicture;

  Manual({
    required this.id,
    required this.name,
    required this.controllerPagePicture,
  });

  factory Manual.fromJson(Map<String, dynamic> json) => _$ManualFromJson(json);

  Map<String, dynamic> toJson() => _$ManualToJson(this);
}

@JsonSerializable()
class ManualDetails {
  final int id;
  final int device;
  final String title;
  @JsonKey(name: 'device_name')
  final String deviceName;
  final String description;

  ManualDetails({
    required this.id,
    required this.device,
    required this.title,
    required this.deviceName,
    required this.description,
  });

  factory ManualDetails.fromJson(Map<String, dynamic> json) =>
      _$ManualDetailsFromJson(json);

  Map<String, dynamic> toJson() => _$ManualDetailsToJson(this);
}
