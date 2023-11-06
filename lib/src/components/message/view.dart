// Flutter imports:
import 'dart:ui';

import 'package:flutter/material.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_live_streaming/src/live_streaming_config.dart';

/// @nodoc
class ZegoInRoomLiveMessageView extends StatefulWidget {
  final ZegoInRoomMessageConfig? config;
  final ZegoAvatarBuilder? avatarBuilder;

  const ZegoInRoomLiveMessageView({
    Key? key,
    this.config,
    this.avatarBuilder,
  }) : super(key: key);

  @override
  State<ZegoInRoomLiveMessageView> createState() =>
      _ZegoInRoomLiveMessageViewState();
}

/// @nodoc
class _ZegoInRoomLiveMessageViewState extends State<ZegoInRoomLiveMessageView> {
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: 0,
            child: widget.config?.background ?? Container(),
          ),
          ZegoInRoomMessageView(
            historyMessages: ZegoUIKit().getInRoomMessages(),
            stream: ZegoUIKit().getInRoomMessageListStream(),
            itemBuilder: widget.config?.itemBuilder ??
                (BuildContext context, ZegoInRoomMessage message, _) {
                  return ZegoInRoomMessageViewItem(
                    message: message,
                    avatarBuilder: widget.avatarBuilder,
                    showName: widget.config?.showName ?? true,
                    showAvatar: widget.config?.showAvatar ?? true,
                    resendIcon: widget.config?.resendIcon,
                    borderRadius: widget.config?.borderRadius,
                    paddings: widget.config?.paddings,
                    opacity: widget.config?.opacity,
                    backgroundColor: widget.config?.backgroundColor,
                    maxLines: widget.config?.maxLines,
                    nameTextStyle: widget.config?.nameTextStyle,
                    messageTextStyle: widget.config?.messageTextStyle,
                    onItemClick: widget.config?.onMessageClick,
                    onItemLongPress: widget.config?.onMessageLongPress,
                  );
                },
          ),
          // FadeEndListView(),
          // Positioned(
          //   top: 0,
          //   left: 0,
          //   right: 0,
          //   child: Container(
          //     height: 100, // Adjust the height of the blur
          //     child: BackdropFilter(
          //       filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), // Adjust blur intensity
          //       child: Container(
          //         color: Colors.transparent,
          //       ),
          //     ),
          //   ),
          // ),
          // Positioned(
          //   bottom: 0,
          //   left: 0,
          //   right: 0,
          //   child: Container(
          //     height: 100, // Adjust the height of the blur
          //     child: BackdropFilter(
          //       filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), // Adjust blur intensity
          //       child: Container(
          //         color: Colors.transparent,
          //       ),
          //     ),
          //   ),
          // ),

        ],
      ),
    );
  }
}
class FadeEndListView extends StatelessWidget {
  const FadeEndListView({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), // Adjust blur intensity
        child: Container(
          color: Colors.transparent,
        ),
      ),
    );
  }
}