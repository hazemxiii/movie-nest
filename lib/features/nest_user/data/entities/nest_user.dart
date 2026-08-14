class NestUser {
  NestUser({
    required this.id,
    required this.name,
    required this.email,
    this.pictureUrl,
  });

  final String id;
  final String name;
  final String email;
  final String? pictureUrl;
}
