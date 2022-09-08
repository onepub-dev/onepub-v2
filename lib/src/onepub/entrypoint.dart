#! /usr/bin/env dcli

import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:dcli/dcli.dart';
import 'package:scope/scope.dart';

import '../onepub/util/log.dart' as ulog;
import 'runner.dart';
import 'settings.dart';
import 'util/exceptions.dart';

/* Copyright (C) OnePub IP Pty Ltd - All Rights Reserved
 * licensed under the GPL v2.
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

/// Used by unit tests to alter the working directory a command runs in.
ScopeKey<String> unitTestWorkingDirectoryKey =
    ScopeKey<String>('WorkingDirectory');

/// The [args] list should contain the command to be run
/// followed by the arguments to be passed to the command.
///
/// The [executableName] is used when displaying help.
Future<void> entrypoint(
  List<String> args,
  CommandSet commandSet,
  String executableName,
) async {
  try {
    await withSettings(() async {
      final runner =
          OnePubRunner(args, executableName, _description, commandSet);
      try {
        runner.init();
        waitForEx(runner.run(args));
      } on FormatException catch (e) {
        printerr(e.message);
        // this is an Exception (generally from the server, not a usage problem)
        //showUsage();
      } on UsageException catch (e) {
        printerr(e.message);
        printerr('');
        printerr(e.usage);
      }
    }, create: true);
  } on ExitException catch (e) {
    printerr(e.message);
    // final firstLine = e.message.split('\n').first;
    // final rest = e.message.split('\n').skip(1).join('\n');
    // printerr(red('Error: $firstLine'));
    // printerr('');
    // printerr(rest);
    exit(e.exitCode);
    // ignore: avoid_catches_without_on_clauses
  } catch (e, s) {
    ulog.logerr('$e\n$s');
  }
}

void showUsage(OnePubRunner runner) {
  runner.printUsage();
  exit(1);
}

String get _description => orange('OnePub CLI tools.');
