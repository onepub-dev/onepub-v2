/* Copyright (C) OnePub IP Pty Ltd - All Rights Reserved
 * licensed under the GPL v2.
 * Written by Brett Sutton <bsutton@onepub.dev>, Jan 2022
 */

import '../util/send_command.dart';

class OnePubToken {
  OnePubToken(EndpointResponse response) {
    if (response.success) {
      token = response.data['onepubToken'] as String?;
    }

    if (token == null) {
      errorMessage = response.data['message']! as String;
    }
  }

  bool get success => token != null;
  String? token;

  String? errorMessage;
}
