#! /usr/bin/env dcli
// ignore_for_file: avoid_print

/* Copyright (C) OnePub IP Pty Ltd - All Rights Reserved
 * licensed under the GPL v2.
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */
import 'package:dcli/dcli.dart';
import 'package:onepub/src/onepub/entrypoint.dart';
import 'package:onepub/src/onepub/runner.dart';
import 'package:onepub/src/version/version.g.dart';

Future<void> main(List<String> arguments) async {
  print(orange('OnePub version: $packageVersion '));

  print('');

  await entrypoint(arguments, CommandSet.onepub, 'onepub');
}
