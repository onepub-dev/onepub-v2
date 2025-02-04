/* Copyright (C) OnePub IP Pty Ltd - All Rights Reserved
 * licensed under the GPL v2.
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'package:dcli/dcli.dart';

import '../../../../command.dart';
import '../../../../global_packages.dart';
import '../../../../system_cache.dart';

/// Imports a the onepub token generated by the onepub login process
/// and then addes it
class DeactivateCommand extends PubCommand {
  @override
  String get description =>
      blue('Remove a previously activated private package.');

  @override
  String get name => 'deactivate';

  GlobalPackages? _globals;
  @override
  // ignore: overridden_fields
  late final SystemCache cache = SystemCache();

  @override
  GlobalPackages get globals => _globals ??= GlobalPackages(cache);

  late Iterable<String> args = argResults.rest;

  ///
  @override
  Future<void> runProtected() async {
    final package = readArg('No package to deactivate given.');

    if (!globals.deactivate(
      package,
    )) {
      printerr(red("No package with the name '$package' found."));
    }
  }

  String readArg([String error = '']) {
    if (args.isEmpty) {
      usageException(error);
    }
    final arg = args.first;
    args = args.skip(1);
    return arg;
  }
}
