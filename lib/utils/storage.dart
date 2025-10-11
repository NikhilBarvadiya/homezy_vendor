import 'dart:convert';
import 'package:get_storage/get_storage.dart';

final _storage = GetStorage();

dynamic read(String name) {
  dynamic info = _storage.read(name);
  return info != null ? json.decode(info) : info;
}

Future<dynamic> write(String key, dynamic value) async {
  dynamic object = value != null ? json.encode(value) : value;
  return await _storage.write(key, object);
}

removeSpecificKeyStorage(String key) => _storage.remove(key);

clearStorage() => _storage.erase();
