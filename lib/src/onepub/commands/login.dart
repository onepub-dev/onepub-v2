/* Copyright (C) OnePub IP Pty Ltd - All Rights Reserved
 * licensed under the GPL v2.
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */
import 'dart:async';

import 'package:args/command_runner.dart';
import 'package:dcli/dcli.dart';
import 'package:dcli/docker.dart';

import '../settings.dart';
import '../util/bread_butter_auth.dart';
import '../util/exceptions.dart';
import '../util/one_pub_token_store.dart';
import '../util/send_command.dart';

/// onepub login
/// We trigger oauth by showing url
// We then do a long poll to the server and wait for oauth to complete
// The long poll adds a pending request to a guava cache (with expiry)

// The oath completes on the server
// The server checks if there is an existing onepub token for the member
// If so we return the token as this allows mulitple devices to be authed.
// If not we create a new onepub token
// We return the onpub token to the cli and it stores it.
// The cli then passed the onepub token each time it needs to interact.
// No oauth is required we just check the onepub token is invalid.
// A logout on any device will invalidate the token.
// A manager can invalidate the token from the web site.
class OnePubLoginCommand extends Command<int> {
  ///
  OnePubLoginCommand();

  @override
  String get description => blue('Log in to OnePub.');

  @override
  String get name => 'login';

  @override
  Future<int> run() async {
    /// we need to provide different instructions if its a remote
    /// or local docker session.
    /// remote session will always be over ssh
    /// but local ones won't

    try {
      final bb = BreadButter();
      final auth = await bb.auth();

      OnePubTokenStore().save(
          onepubToken: auth.onepubToken,
          organisationName: auth.organisationName,
          obfuscatedOrganisationId: auth.obfuscatedOrganisationId,
          operatorEmail: auth.operatorEmail);

      showWelcome(
          firstLogin: auth.firstLogin,
          organisationName: auth.organisationName,
          operator: auth.operatorEmail);
    } on FetchException {
      printerr(red('Unable to connect to '
          '${OnePubSettings.use.onepubApiUrl}. '
          'Check your internet connection.'));
    }
    return 0;
  }

  void checkForSSH() {
    if (inSSH()) {
      throw ExitException(exitCode: -1, message: """
${red('onepub login will not work from an ssh shell.')}

Instead:
Exit your ssh session and run:
${green('onepub export')}

Restart your ssh session and run:
${green('onepub import --ask')}

See the documentation for full details and alternate techniques:
${orange('https://docs.onepub.dev/guides/ssh')}
""");
    }
  }

  void checkForDocker() {
    if (DockerShell.inDocker) {
      throw ExitException(exitCode: -1, message: """
${red('onepub login will not work within a Docker shell.')}
    
Instead:
Exit your docker session and run:
${green('onepub export')}

Restart your docker session and run:
${green('onepub import --ask')}

See the documentation for full details and alternate techniques:
${orange('https://docs.onepub.dev/guides/docker')}
""");
    }
  }

  void showError(EndpointResponse endPointResponse) {
    final error = endPointResponse.data['message']! as String;

    print(red(error));
  }

  bool inSSH() =>
      Env().exists('SSH_CLIENT') ||
      Env().exists('SSH_CONNECTION') ||
      Env().exists('SSH_TTY');
  // removed as I think this is set if a user
  //runs ssa-agent to start the ssh-agent on their local machine.
  // Env().exists('SSH_AGENT_PID');
}

void showWelcome(
    {required bool firstLogin,
    required String organisationName,
    required String operator}) {
  var firstMessage = '';
  if (firstLogin) {
    firstMessage = '''
Welcome to OnePub.
Read the getting started guide at:
${orange('${OnePubSettings.use.onepubWebUrl}/getting-started')}

''';
  }

  print('''

${blue('Successfully logged into $organisationName as $operator.')}

$firstMessage
''');
}
