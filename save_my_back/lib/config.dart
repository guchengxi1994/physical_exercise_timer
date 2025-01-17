import 'dart:io';

import 'package:toml/toml.dart';

String getConfigPath() {
  String executablePath = Platform.resolvedExecutable;
  return "${File(executablePath).parent.path}/config.toml";
}

class AppConfig {
  final String modelPath;
  final int recordPeriod;

  AppConfig({required this.modelPath, required this.recordPeriod});

  factory AppConfig.fromMap(Map<String, dynamic> map) {
    return AppConfig(
      modelPath: map['model-path'] as String,
      recordPeriod: map['record-period'] as int,
    );
  }

  factory AppConfig.fromFile(File f) {
    final contents = f.readAsStringSync();
    final tomlDocument = TomlDocument.parse(contents);
    final configMap = tomlDocument.toMap();
    return AppConfig.fromMap(configMap['config']);
  }
}

class CONFIG {
  CONFIG._();

  static late final AppConfig appConfig;

  static void init() {
    final configFile = File(getConfigPath());
    appConfig = AppConfig.fromFile(configFile);
  }

  static String get modelPath => appConfig.modelPath;
  static int get recordPeriod => appConfig.recordPeriod;
}
