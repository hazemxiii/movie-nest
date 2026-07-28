import 'package:movie_nest/core/exceptions/nest_secret_exception.dart';
import 'package:movie_nest/core/services/nest_logger.dart';
import 'package:movie_nest/features/media/data/models/media.dart';
import 'package:movie_nest/features/nest_list/data/models/nest_list_dto.dart';

class NestList {
  NestList({
    required this.id,
    required this.name,
    this.date,
    required this.media,
    required this.fieldsVersion,
  });

  factory NestList.fromJson(dynamic json) {
    try {
      json = Map<String, dynamic>.from(json);
      return NestList(
        id: (json['_id'] ?? json['id']) as String,
        name: json['name'] as String,
        date: json['date'] != null
            ? DateTime.parse(json['date'] as String)
            : null,
        media: [],
        fieldsVersion: Map<String, int>.from(json['fieldsVersion'] ?? {}),
      );
    } catch (e) {
      final error = NestSecretException('0xNLT');
      NestLogger.logError(e.toString(), code: error.objectCode);
      throw error;
    }
  }

  final String id;
  final String name;
  final DateTime? date;
  final List<Media> media;
  final Map<String, int> fieldsVersion;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'date': date?.toIso8601String(),
      'fieldsVersion': fieldsVersion,
    };
  }

  NestListDto toDto() {
    return NestListDto(
      id: id,
      name: name,
      date: date,
      fieldsVersion: fieldsVersion,
    );
  }

  NestList updateWith(NestListDto dto) {
    return NestList(
      id: dto.id,
      name: dto.name ?? name,
      date: dto.date,
      media: media,
      fieldsVersion: dto.fieldsVersion,
    );
  }

  NestList copyWith({
    String? id,
    String? name,
    DateTime? date,
    List<Media>? media,
    Map<String, int>? fieldsVersion,
  }) {
    return NestList(
      id: id ?? this.id,
      name: name ?? this.name,
      date: date ?? this.date,
      media: media ?? this.media,
      fieldsVersion: this.fieldsVersion,
    );
  }
}
