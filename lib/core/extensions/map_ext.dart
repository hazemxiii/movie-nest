import 'dart:convert';

extension MapExt<K, V> on Map<K, V> {
  String format() {
    return const JsonEncoder.withIndent(' ').convert(this);
  }
}
