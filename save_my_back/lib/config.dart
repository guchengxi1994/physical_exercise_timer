import 'dart:io';

import 'package:toml/toml.dart';

class AppConfig {
  final String modelPath;

  AppConfig({required this.modelPath});

  factory AppConfig.fromMap(Map<String, dynamic> map) {
    return AppConfig(
      modelPath: map['model-path'] as String,
    );
  }

  factory AppConfig.fromFile(File f) {
    final contents = f.readAsStringSync();
    final tomlDocument = TomlDocument.parse(contents);
    final configMap = tomlDocument.toMap();
    return AppConfig.fromMap(configMap['config']);
  }
}
