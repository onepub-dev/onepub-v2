/* Copyright (C) OnePub IP Pty Ltd - All Rights Reserved
 * licensed under the GPL v2.
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:dcli/dcli.dart';
import 'package:scope/scope.dart';

import '../command.dart';
import '../command/add.dart';
import '../command/cache.dart';
import '../command/deps.dart';
import '../command/downgrade.dart';
import '../command/get.dart';
import '../command/global.dart';
import '../command/lish.dart';
import '../command/login.dart';
import '../command/logout.dart';
import '../command/outdated.dart';
import '../command/remove.dart';
import '../command/run.dart';
import '../command/token.dart';
import '../command/upgrade.dart';
import '../command/uploader.dart';
import '../command/version.dart';
import '../io.dart';
import '../log.dart' hide red;
import '../log.dart' as plog;
import '../onepub/commands/doctor.dart';
import '../onepub/commands/export.dart';
import '../onepub/commands/import.dart';
import '../onepub/commands/login.dart';
import '../onepub/commands/logout.dart';
import '../onepub/commands/pub.dart' as onepub;
import 'entrypoint.dart';
import 'settings.dart';
import 'util/exceptions.dart';

enum CommandSet { opub, onepub }

///
///
class OnePubRunner extends CommandRunner<int> implements PubTopLevel {
  OnePubRunner(
      this.args, String executableName, String description, this.commandSet)
      : super(executableName, description) {
    try {
      switch (commandSet) {
        case CommandSet.onepub:
          onepubCommands(commandSet);
          break;
        case CommandSet.opub:
          opubCommands();
      }
    } on FormatException catch (e) {
      throw ExitException(exitCode: 1, message: e.message);
    }
  }
  CommandSet commandSet;

  void init() {
    results = argParser.parse(args);

    Settings().setVerbose(enabled: results['debug'] as bool);

    final version = results['version'] as bool == true;
    if (version == true) {
      // no output required as the startup logic already prints the version.
      exit(0);
    }

    if (commandSet == CommandSet.onepub) {
      install(dev: results['dev'] as bool);
    }
  }

  void opubCommands() {
    argParser
      ..addFlag('version', negatable: false, help: 'Print pub version.')
      ..addFlag('debug',
          negatable: false, abbr: 'd', help: 'Enable verbose logging')
      ..addFlag('trace',
          negatable: false,
          help: 'Print debugging information when an error occurs.')
      ..addOption('verbosity', help: 'Control output verbosity.', allowed: [
        'error',
        'warning',
        'normal',
        'io',
        'solver',
        'all'
      ], allowedHelp: {
        'error': 'Show only errors.',
        'warning': 'Show only errors and warnings.',
        'normal': 'Show errors, warnings, and user messages.',
        'io': 'Also show IO operations.',
        'solver': 'Show steps during version resolution.',
        'all': 'Show all output including internal tracing messages.'
      })
      ..addFlag('verbose',
          abbr: 'v', negatable: false, help: 'Shortcut for "--verbosity=all".')
      ..addOption(
        'directory',
        abbr: 'C',
        help: 'Run the subcommand in the directory<dir>.',
        defaultsTo: '.',
        valueHelp: 'dir',
      );
    addCommand(LishCommand());
    addCommand(GetCommand());
    addCommand(AddCommand());

    addCommand(CacheCommand());
    addCommand(DepsCommand());
    addCommand(DowngradeCommand());
    addCommand(GlobalCommand());

    addCommand(OutdatedCommand());
    addCommand(RemoveCommand());
    addCommand(RunCommand());

    addCommand(UpgradeCommand());
    addCommand(UploaderCommand());
    addCommand(VersionCommand());
    addCommand(LoginCommand());
    addCommand(LogoutCommand());
    addCommand(TokenCommand());
  }

  void onepubCommands(CommandSet commandSet) {
    argParser
      ..addFlag('debug',
          negatable: false, abbr: 'd', help: 'Enable verbose logging')
      ..addFlag('version',
          negatable: false, help: 'Displays the onepub version no. and exits.')
      ..addFlag('dev',
          hide: true,
          negatable: false,
          help: 'Allows for configuration of localhost for '
              'use in a development environment.');

    addCommand(DoctorCommand());
    addCommand(OnePubLoginCommand());
    addCommand(OnePubLogoutCommand());
    addCommand(ImportCommand());
    addCommand(ExportCommand());
    addCommand(onepub.PubCommand());
  }

  List<String> args;
  late ArgResults results;

  @override
  ArgResults get argResults => results;

  @override
  String get directory {
    if (argResults.options.contains('directory') &&
        argResults.wasParsed('directory')) {
      return argResults['directory'] as String;
    }

    /// if we are in a unit test and directory hasn't been passed
    if (Scope.hasScopeKey(unitTestWorkingDirectoryKey)) {
      return Scope.use(unitTestWorkingDirectoryKey);
    }
    //  no working dir
    return '';
  }

  @override
  bool get captureStackChains => trace || verbose || verbosityString == 'all';

  String get verbosityString {
    if (!argResults.options.contains('verbosity')) {
      return '';
    }
    return argResults['verbosity'] as String;
  }

  @override
  Verbosity get verbosity {
    switch (verbosityString) {
      case 'error':
        return plog.Verbosity.error;
      case 'warning':
        return plog.Verbosity.warning;
      case 'normal':
        return plog.Verbosity.normal;
      case 'io':
        return plog.Verbosity.io;
      case 'solver':
        return plog.Verbosity.solver;
      case 'all':
        return plog.Verbosity.all;
      default:
        // No specific verbosity given, so check for the shortcut.
        if (verbose) {
          return plog.Verbosity.all;
        }
        if (runningFromTest) {
          return plog.Verbosity.testing;
        }
        return plog.Verbosity.normal;
    }
  }

  @override
  bool get trace {
    if (!argResults.options.contains('trace')) {
      return false;
    }
    return argResults['trace'] as bool;
  }

  bool get verbose {
    if (!argResults.options.contains('verbose')) {
      return false;
    }
    return argResults['verbose'] as bool;
  }
}
