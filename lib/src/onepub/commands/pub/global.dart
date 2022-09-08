/* Copyright (C) OnePub IP Pty Ltd - All Rights Reserved
 * licensed under the GPL v2.
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'package:args/command_runner.dart';
import 'package:dcli/dcli.dart';

import 'global/activate.dart';
import 'global/deactivate.dart';

/// Provides the abilty to work with global packages that are hosted
/// as private packages on OnePub
class GlobalCommand extends Command<int> {
  ///
  GlobalCommand() : super() {
    addSubcommand(ActivateCommand());
    addSubcommand(DeactivateCommand());
  }
  @override
  String get name => 'global';
  @override
  String get description => blue('Work with private global packages.');
}
