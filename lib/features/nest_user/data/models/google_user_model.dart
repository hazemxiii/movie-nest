class GoogleUserModel {
  GoogleUserModel({
    required this.id,
    required this.name,
    this.pictureUrl,
    required this.email,
  });
  final String id;
  final String name;
  final String? pictureUrl;
  final String email;
}
