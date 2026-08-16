import 'package:movie_nest/features/nest_user/data/entities/nest_user.dart';
import 'package:movie_nest/features/nest_user/data/models/google_user_model.dart';

class ServerUserModel {
  factory ServerUserModel.fromJson(
    Map<String, dynamic> json,
    GoogleUserModel googleUser,
  ) {
    return ServerUserModel(
      id: json['_id'] as String,
      name: json['name'],
      pictureUrl: json['picture_url'],
      googleUser: googleUser,
      email: json['email'],
      listsCount: json['lists_count'] ?? 0,
      mediaCount: json['media_count'] ?? 0,
    );
  }
  ServerUserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.pictureUrl,
    required this._googleUser,
    required this.listsCount,
    required this.mediaCount,
  });

  final String id;
  final String? name;
  final String? pictureUrl;
  final GoogleUserModel _googleUser;
  final String email;
  final int listsCount;
  final int mediaCount;

  NestUser toEntity() {
    return NestUser(
      id: id,
      name: name ?? _googleUser.name,
      email: email,
      pictureUrl: pictureUrl ?? _googleUser.pictureUrl,
      listsCount: listsCount,
      mediaCount: mediaCount,
    );
  }
}
