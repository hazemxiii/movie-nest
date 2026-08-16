class NestUser {
  NestUser({
    required this.id,
    required this.name,
    required this.email,
    this.pictureUrl,
    required this.listsCount,
    required this.mediaCount,
  });

  final String id;
  final String name;
  final String email;
  final String? pictureUrl;
  final int listsCount;
  final int mediaCount;
}
