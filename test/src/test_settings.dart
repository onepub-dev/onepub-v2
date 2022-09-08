/* Copyright (C) OnePub IP Pty Ltd - All Rights Reserved
 * licensed under the GPL v2.
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'dart:async';

import 'package:dcli/dcli.dart';
import 'package:onepub/src/onepub_settings.dart';
import 'package:settings_yaml/settings_yaml.dart';

class TestSettings {
  TestSettings() {
    _settings = SettingsYaml.load(pathToSettings: pathToTestSettings);
  }

  late final SettingsYaml _settings;

  String get member => _settings.asString('member');
  String get cicdMember => _settings.asString('cicd_member');

  String get onepubToken => _settings.asString('onepub_token');
  set onepubToken(String token) => _settings['onepub_token'] = token;

  String get onepubUrl => _settings.asString('onepubUrl');
  set onepubUrl(String url) => _settings['onepubUrl'] = url;

  String get organisationName => _settings.asString('organisationName');

  set organisationName(String name) => _settings['organisationName'] = name;

  String get organisationId => _settings.asString('organisationId');
  set organisationId(String obsfucatedId) =>
      _settings['organisationId'] = obsfucatedId;

  // ignore: discarded_futures
  void save() => waitForEx(_settings.save());

  String get pathToTestSettings {
    final pathToTest = DartProject.self.pathToTestDir;

    return join(pathToTest, 'test_settings.yaml');
  }
}

/// Initialises a OnePubSettings file in a tmp directory
/// copying its initial state from the test_settings.yaml file
/// in the project 'test' directory.
Future<void> withTestSettings(void Function(TestSettings testSettings) action,
    {bool forAuthentication = false}) async {
  await withTempDir((tempSettingsDir) async {
    // control the location of the onepub settings file.
    await withEnvironment(() async {
      await withSettings(() async {
        final settings = OnePubSettings.use;
        final testSettings = TestSettings();

        if (!forAuthentication) {
          settings
            ..operatorEmail = testSettings.member
            ..organisationName = testSettings.organisationName
            ..obfuscatedOrganisationId = testSettings.organisationId;
        }
        settings
          ..onepubUrl = testSettings.onepubUrl
          ..save();

        action(testSettings);
      }, create: true);
    }, environment: {OnePubSettings.onepubPathEnvKey: tempSettingsDir});
  });
}
