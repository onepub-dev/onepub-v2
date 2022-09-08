/* Copyright (C) OnePub IP Pty Ltd - All Rights Reserved
 * licensed under the GPL v2.
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import '../util/send_command.dart';

class Logout {
  Logout(EndpointResponse response) {
    var success = response.success;

    if (!success) {
      var errorMessage =
          response.data['message']! as String? ?? 'Missing field "message"';
      // if we failed because we were already logged out
      // we still report success.
      if (errorMessage.startsWith('Your token is no longer valid') ||
          errorMessage
              .startsWith('You must be logged in to run this command.')) {
        wasAlreadyLoggedOut = true;
        errorMessage = '';
        success = true;
      }
      this.errorMessage = errorMessage;
    } else {
      wasAlreadyLoggedOut = false;
    }
    this.success = success;
  }

  late final bool success;

  /// If the call failed this contains the error message.
  late final String errorMessage;

  /// If the user was already logged out when we called logout.
  late final bool wasAlreadyLoggedOut;
}
