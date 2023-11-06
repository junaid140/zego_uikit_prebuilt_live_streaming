// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:zego_uikit_prebuilt_live_streaming/zego_uikit_prebuilt_live_streaming.dart';

import 'constants.dart';
import 'secret.dart';

class LivePage extends StatelessWidget {
  final String liveID;
  final bool isHost;

  const LivePage({
    Key? key,
    required this.liveID,
    this.isHost = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final liveStateNotifier =
    ValueNotifier<ZegoLiveStreamingState>(ZegoLiveStreamingState.idle);
    return SafeArea(
      child: ZegoUIKitPrebuiltLiveStreaming(
        appID: YourSecret.appID /*input your AppID*/,
        appSign: YourSecret.appSign /*input your AppSign*/,
        userID: localUserID,
        userName: 'user_$localUserID',
        liveID: liveID,
        config: isHost
            ? ZegoUIKitPrebuiltLiveStreamingConfig.host()
            : ZegoUIKitPrebuiltLiveStreamingConfig.audience()


      ),
    );
  }
}
