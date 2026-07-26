import 'package:movie_nest/features/nest_list/data/models/nest_list.dart';
import 'package:uuid/uuid.dart';

class NestListDto {
  NestListDto({
    String? id,
    this.name,
    Map<String, int>? fieldsVersion,
    DateTime? date,
  }) {
    this.id = id ?? const Uuid().v4();
    this.date = date ?? DateTime.now().toUtc();
    this.fieldsVersion = fieldsVersion ?? {};
  }
  late final String id;
  String? name;
  late final DateTime date;
  late Map<String, int> fieldsVersion;

  String? validate(bool isEdit) {
    if (isEdit) {
      return (name?.isNotEmpty ?? true) ? null : 'List name is required';
    }
    return name != null && name!.isNotEmpty ? null : 'List name is required';
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'id': id,
      'name': name,
      'date': date.toIso8601String(),
      'fieldsVersion': {},
    };
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'name': name,
      'date': date.toIso8601String(),
      'fieldsVersion': fieldsVersion,
    };
  }

  NestList toModel() {
    return NestList(
      id: id,
      name: name!,
      date: date,
      media: [],
      fieldsVersion: {},
    );
  }
}
