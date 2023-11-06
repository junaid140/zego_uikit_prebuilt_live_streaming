// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:zego_uikit/zego_uikit.dart';

// Project imports:
import 'package:zego_uikit_prebuilt_live_streaming/src/components/defines.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/components/effects/beauty_effect_button.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/components/effects/sound_effect_button.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/components/leave_button.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/components/message/disable_chat_button.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/components/message/input_board_button.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/components/pop_up_manager.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/core/co_host_control_button.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/core/connect_manager.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/core/host_manager.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/internal/internal.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/live_streaming_config.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/live_streaming_defines.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/minimizing/mini_button.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/minimizing/prebuilt_data.dart';
import 'package:zego_uikit_prebuilt_live_streaming/src/pk/src/pk_impl.dart';

/// @nodoc
class StatusDailog extends StatefulWidget {
  final ZegoUIKitPrebuiltLiveStreamingConfig config;
  final ZegoUIKitPrebuiltLiveStreamingData prebuiltData;
  final Size buttonSize;

  final ZegoLiveHostManager hostManager;
  final ZegoPopUpManager popUpManager;
  final ValueNotifier<bool> hostUpdateEnabledNotifier;

  final ValueNotifier<LiveStatus> liveStatusNotifier;
  final ZegoLiveConnectManager connectManager;

  final ValueNotifier<bool>? isLeaveRequestingNotifier;

  const StatusDailog({
    Key? key,
    required this.config,
    required this.prebuiltData,
    required this.buttonSize,
    required this.hostManager,
    required this.hostUpdateEnabledNotifier,
    required this.liveStatusNotifier,
    required this.connectManager,
    required this.popUpManager,
    this.isLeaveRequestingNotifier,
  }) : super(key: key);

  @override
  State<StatusDailog> createState() => _StatusDailogState();
}

/// @nodoc
class _StatusDailogState extends State<StatusDailog> {
  List<ZegoMenuBarButtonName> buttons = [];
  List<ZegoMenuBarExtendButton> extendButtons = [];
  TextEditingController textController = TextEditingController();
  var focusNode = FocusNode();
  ValueNotifier<bool> isEmptyNotifier = ValueNotifier(true);

  @override
  void initState() {
    super.initState();

    updateButtonsByRole();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: widget.config.bottomMenuBarConfig.margin,
      padding: widget.config.bottomMenuBarConfig.padding,
      decoration: BoxDecoration(
        color: widget.config.bottomMenuBarConfig.backgroundColor ??
            Colors.transparent,
      ),
      height: widget.config.bottomMenuBarConfig.height ?? 500.zR,
      child: Stack(
        children: [
          if (widget.hostManager.isLocalHost)
            rightToolbar(context)
          else
            ValueListenableBuilder(
              valueListenable:
                  widget.connectManager.audienceLocalConnectStateNotifier,
              builder: (context, connectState, _) {
                if (widget.config.plugins.isEmpty) {
                  return rightToolbar(context);
                }

                if (ZegoLiveStreamingAudienceConnectState.connecting ==
                    connectState) {
                  return rightToolbar(context);
                }

                updateButtonsByRole();

                return rightToolbar(context);
              },
            ),
          // leftChatButton(),
        ],
      ),
    );
  }

  void updateButtonsByRole() {
    if (widget.hostManager.isLocalHost) {
      buttons = widget.config.bottomMenuBarConfig.hostButtons;
      extendButtons = widget.config.bottomMenuBarConfig.hostExtendButtons;
    } else {
      final connectState =
          widget.connectManager.audienceLocalConnectStateNotifier.value;
      final isCoHost =
          ZegoLiveStreamingAudienceConnectState.connected == connectState;

      buttons = isCoHost
          ? widget.config.bottomMenuBarConfig.coHostButtons
          : widget.config.bottomMenuBarConfig.audienceButtons;
      extendButtons = isCoHost
          ? widget.config.bottomMenuBarConfig.coHostExtendButtons
          : widget.config.bottomMenuBarConfig.audienceExtendButtons;
    }

    if (buttons.contains(ZegoMenuBarButtonName.chatButton) &&
        !widget.config.bottomMenuBarConfig.showInRoomMessageButton) {
      buttons
          .removeWhere((button) => button == ZegoMenuBarButtonName.chatButton);
    }
  }

  Widget leftChatButton() {
    if (buttons.contains(ZegoMenuBarButtonName.chatButton)) {
      return const SizedBox();
    }

    if (widget.config.bottomMenuBarConfig.showInRoomMessageButton) {
      return SizedBox(
        height: 124.zR,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // zegoLiveButtonPadding,
          Container(
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.symmetric(horizontal: 15.zR, vertical: 15.zR),
            color: const Color(0xff222222).withOpacity(0.8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(width: 10.zR),
                messageInput(),
                SizedBox(width: 10.zR),
                sendButton(),
                SizedBox(width: 10.zR),
              ],
            ),
          )
          ],
        ),
      );
      // return SizedBox(
      //   height: 124.zR,
      //   child: Row(
      //     mainAxisAlignment: MainAxisAlignment.start,
      //     crossAxisAlignment: CrossAxisAlignment.center,
      //     children: [
      //       zegoLiveButtonPadding,
      //       ZegoInRoomMessageInputBoardButton(
      //         translationText: widget.config.innerText,
      //         hostManager: widget.hostManager,
      //         onSheetPopUp: (int key) {
      //           widget.popUpManager.addAPopUpSheet(key);
      //         },
      //         onSheetPop: (int key) {
      //           widget.popUpManager.removeAPopUpSheet(key);
      //         },
      //         enabledIcon: ButtonIcon(
      //           icon: widget.config.bottomMenuBarConfig.buttonStyle
      //               ?.chatEnabledButtonIcon,
      //         ),
      //         disabledIcon: ButtonIcon(
      //           icon: widget.config.bottomMenuBarConfig.buttonStyle
      //               ?.chatDisabledButtonIcon,
      //         ),
      //       ),
      //     ],
      //   ),
      // );
    }

    return const SizedBox();
  }
  Widget messageInput() {
    // final messageSendBgColor = widget.buttonColor ?? const Color(0xff3e3e3d);
    final messageSendCursorColor =
        // widget.cursorColor ??
            const Color(0xffA653ff);
    final messageSendHintStyle = TextStyle(
      color:
      // widget.textHintColor ??
          const Color(0xffa4a4a4),
      fontSize: 28.zR,
      fontWeight: FontWeight.w400,
    );
    final messageSendInputStyle = TextStyle(
      color:
      // widget.textColor ??
          Colors.white,
      fontSize: 28.zR,
      fontWeight: FontWeight.w400,
    );

    return Expanded(
      child: Container(
        height: 78.zR,
        decoration: BoxDecoration(
          // color: widget.inputBackgroundColor ?? messageSendBgColor,
          borderRadius: BorderRadius.circular(16.zR),
        ),
        child: TextField(

          keyboardType: TextInputType.multiline,
          minLines: 1,
          maxLines: null,

          focusNode: focusNode,
          inputFormatters: <TextInputFormatter>[
            LengthLimitingTextInputFormatter(400)
          ],
          controller: textController,
          onChanged: (String inputMessage) {
            // widget.valueNotifier?.value = inputMessage;

            final valueIsEmpty = inputMessage.isEmpty;
            if (valueIsEmpty != isEmptyNotifier.value) {
              isEmptyNotifier.value = valueIsEmpty;
            }
          },
          textInputAction: TextInputAction.send,
          onSubmitted: (message) => send(),
          cursorColor: messageSendCursorColor,
          cursorHeight: 30.zR,
          cursorWidth: 3.zR,
          style: messageSendInputStyle,
          decoration: InputDecoration(
            hintText: "Enter Message",
            hintStyle: messageSendHintStyle,
            contentPadding: EdgeInsets.only(
              left: 20.zR,
              top: -5.zR,
              right: 20.zR,
              bottom: 15.zR,
            ),
            // isDense: true,
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }

  Widget sendButton() {
    return ValueListenableBuilder<bool>(
      valueListenable: isEmptyNotifier,
      builder: (context, bool isEmpty, Widget? child) {
        return ZegoTextIconButton(
          onPressed: () {
            if (!isEmpty) send();
          },
          icon: ButtonIcon(
            icon: isEmpty
                ? UIKitImage.asset(StyleIconUrls.iconSendDisable)
                : UIKitImage.asset(StyleIconUrls.iconSend),
            // backgroundColor: widget.buttonColor,
          ),
          iconSize: Size(68.zR, 68.zR),
          buttonSize: Size(72.zR, 72.zR),
        );
      },
    );
  }

  void send() {
    if (textController.text.isEmpty) {
      ZegoLoggerService.logInfo(
        'message is empty',
        tag: 'uikit',
        subTag: 'in room message input',
      );
      return;
    }

    ZegoUIKit().sendInRoomMessage(textController.text);
    textController.clear();

    // widget.valueNotifier?.value = '';
    //
    // widget.onSubmit?.call();
  }

  Widget rightToolbar(BuildContext context) {
    var leftPaddings = <Widget>[];
    if (!widget.config.bottomMenuBarConfig.showInRoomMessageButton) {
      leftPaddings = [
        zegoLiveButtonPadding,
        zegoLiveButtonPadding,
      ];
    }
    else if (buttons.contains(ZegoMenuBarButtonName.chatButton)) {
      leftPaddings = [
        zegoLiveButtonPadding,
        zegoLiveButtonPadding,
      ];
    } else if (buttons.contains(ZegoMenuBarButtonName.expanding)) {
      leftPaddings = [
        zegoLiveButtonPadding,
        zegoLiveButtonPadding,
        zegoLiveButtonPadding,
        SizedBox.fromSize(size: zegoLiveButtonSize),
      ];
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ...leftPaddings,
        ...getDisplayButtons(context),
        zegoLiveButtonPadding,
        zegoLiveButtonPadding,
      ],
    );

    //   CustomScrollView(
    //   scrollDirection: Axis.vertical,
    //   slivers: [
    //     SliverFillRemaining(
    //       hasScrollBody: false,
    //       child: Column(
    //         mainAxisAlignment: MainAxisAlignment.end,
    //         crossAxisAlignment: CrossAxisAlignment.center,
    //         children: [
    //           ...leftPaddings,
    //           ...getDisplayButtons(context),
    //           zegoLiveButtonPadding,
    //           zegoLiveButtonPadding,
    //         ],
    //       ),
    //     ),
    //   ],
    // );
  }

  List<Widget> sortDisplayButtons(
    List<Widget> builtInButton,
    List<ZegoMenuBarExtendButton> _extendButtons,
  ) {
    /// classify
    final unsortedExtendIndexesWithButton = <int, Widget>{};
    final notNeedSortedExtendButtons = <Widget>[];
    final totalButtonCount = builtInButton.length + _extendButtons.length;
    for (var i = 0; i < _extendButtons.length; i++) {
      final extendButton = _extendButtons[i];
      if (extendButton.index >= 0 && extendButton.index < totalButtonCount) {
        unsortedExtendIndexesWithButton[extendButton.index] = extendButton;
      } else {
        // button which index is -1 mean not need to sort
        notNeedSortedExtendButtons.add(extendButton);
      }
    }

    /// sort
    final entries = unsortedExtendIndexesWithButton.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    final sortedExtendIndexesWithButton = Map<int, Widget>.fromEntries(entries);

    /// insert
    final sortButtons = <Widget>[
      ...builtInButton,
      ...notNeedSortedExtendButtons
    ];
    sortedExtendIndexesWithButton.forEach((index, button) {
      sortButtons.insert(index, button);
    });

    return sortButtons;
  }

  List<Widget> getDisplayButtons(BuildContext context) {
    final buttonList = sortDisplayButtons(
      getDefaultButtons(
        context,
        cameraDefaultValueFunc: widget.prebuiltData.isPrebuiltFromMinimizing
            ? () {
                /// if is minimizing, take the local device state
                return ZegoUIKit()
                    .getCameraStateNotifier(ZegoUIKit().getLocalUser().id)
                    .value;
              }
            : null,
        microphoneDefaultValueFunc: widget.prebuiltData.isPrebuiltFromMinimizing
            ? () {
                /// if is minimizing, take the local device state
                return ZegoUIKit()
                    .getMicrophoneStateNotifier(ZegoUIKit().getLocalUser().id)
                    .value;
              }
            : null,
      ),
      extendButtons,
    );

    var displayButtonList = <Widget>[];
    if (buttonList.length > widget.config.bottomMenuBarConfig.maxCount) {
      /// the list count exceeds the limit, so divided into two parts,
      /// one part display in the Menu bar, the other part display in the menu with more buttons
      displayButtonList = buttonList.sublist(
        0,
        widget.config.bottomMenuBarConfig.maxCount - 1,
      )..add(
          buttonWrapper(
            child: ZegoMoreButton(
              menuButtonListFunc: () {
                final buttonList = sortDisplayButtons(
                  getDefaultButtons(
                    context,
                    cameraDefaultValueFunc: () {
                      return ZegoUIKit()
                          .getCameraStateNotifier(ZegoUIKit().getLocalUser().id)
                          .value;
                    },
                    microphoneDefaultValueFunc: () {
                      return ZegoUIKit()
                          .getMicrophoneStateNotifier(
                              ZegoUIKit().getLocalUser().id)
                          .value;
                    },
                  ),
                  extendButtons,
                )..removeRange(
                    0,
                    widget.config.bottomMenuBarConfig.maxCount - 1,
                  );

                return buttonList;
              },
              icon: ButtonIcon(
                icon: PrebuiltLiveStreamingImage.asset(
                    PrebuiltLiveStreamingIconUrls.bottomBarMore),
                backgroundColor: Colors.transparent,
              ),
              onSheetPopUp: (int key) {
                widget.popUpManager.addAPopUpSheet(key);
              },
              onSheetPop: (int key) {
                widget.popUpManager.removeAPopUpSheet(key);
              },
            ),
          ),
        );
    } else {
      displayButtonList = buttonList;
    }

    final displayButtonsWithSpacing = <Widget>[];
    for (final button in displayButtonList) {
      displayButtonsWithSpacing
        ..add(button)
        ..add(zegoLiveButtonPadding);
    }

    return displayButtonsWithSpacing;
  }

  Widget buttonWrapper({required Widget child, ZegoMenuBarButtonName? type}) {
    if (ZegoMenuBarButtonName.expanding == type) {
      return child;
    }

    var buttonSize = widget.buttonSize;

    /// co-host button
    final coHostButtonTextStyle = TextStyle(
      color: Colors.white,
      fontSize: 26.zR,
      fontWeight: FontWeight.w500,
    );
    final iconTextSpacing = 20.zR;
    switch (type) {
      case ZegoMenuBarButtonName.coHostControlButton:
        switch (widget.connectManager.audienceLocalConnectStateNotifier.value) {
          case ZegoLiveStreamingAudienceConnectState.idle:
            final textSize = getTextSize(
              widget.config.bottomMenuBarConfig.buttonStyle
                      ?.requestCoHostButtonText ??
                  widget.config.innerText.requestCoHostButton,
              coHostButtonTextStyle,
            );
            buttonSize = Size(
              textSize.width +
                  (textSize.width > 1 ? iconTextSpacing : 0) +
                  zegoLiveButtonSize.width,
              zegoLiveButtonSize.height,
            );
            break;
          case ZegoLiveStreamingAudienceConnectState.connecting:
            final textSize = getTextSize(
              widget.config.bottomMenuBarConfig.buttonStyle
                      ?.cancelRequestCoHostButtonText ??
                  widget.config.innerText.cancelRequestCoHostButton,
              coHostButtonTextStyle,
            );
            buttonSize = Size(
              textSize.width +
                  (textSize.width > 1 ? iconTextSpacing : 0) +
                  zegoLiveButtonSize.width,
              zegoLiveButtonSize.height,
            );
            break;
          case ZegoLiveStreamingAudienceConnectState.connected:
            final textSize = getTextSize(
              widget.config.bottomMenuBarConfig.buttonStyle
                      ?.endCoHostButtonText ??
                  widget.config.innerText.endCoHostButton,
              coHostButtonTextStyle,
            );
            buttonSize = Size(
              textSize.width +
                  (textSize.width > 1 ? iconTextSpacing : 0) +
                  zegoLiveButtonSize.width,
              zegoLiveButtonSize.height,
            );
            break;
        }
        break;
      default:
        break;
    }

    return SizedBox(
      width: buttonSize.width,
      height: buttonSize.height,
      child: child,
    );
  }

  List<Widget> getDefaultButtons(
    BuildContext context, {
    bool Function()? cameraDefaultValueFunc,
    bool Function()? microphoneDefaultValueFunc,
  }) {
    if (buttons.isEmpty) {
      return [];
    }

    return buttons
        .map((type) => buttonWrapper(
              child: generateDefaultButtonsByEnum(
                context,
                type,
                cameraDefaultValueFunc: cameraDefaultValueFunc,
                microphoneDefaultValueFunc: microphoneDefaultValueFunc,
              ),
              type: type,
            ))
        .toList();
  }

  Widget generateDefaultButtonsByEnum(
    BuildContext context,
    ZegoMenuBarButtonName type, {
    bool Function()? cameraDefaultValueFunc,
    bool Function()? microphoneDefaultValueFunc,
  }) {
    var cameraDefaultOn = widget.config.turnOnCameraWhenJoining;
    var microphoneDefaultOn = widget.config.turnOnMicrophoneWhenJoining;
    if (widget.config.plugins.isNotEmpty &&
        ZegoLiveStreamingAudienceConnectState.connected ==
            widget.connectManager.audienceLocalConnectStateNotifier.value) {
      cameraDefaultOn = widget.config.turnOnCameraWhenCohosted;
      microphoneDefaultOn = true;
    }

    cameraDefaultOn = cameraDefaultValueFunc?.call() ?? cameraDefaultOn;
    microphoneDefaultOn =
        microphoneDefaultValueFunc?.call() ?? microphoneDefaultOn;

    final buttonSize = zegoLiveButtonSize;
    final iconSize = zegoLiveButtonIconSize;
    switch (type) {
      case ZegoMenuBarButtonName.toggleMicrophoneButton:
        return ValueListenableBuilder(
          valueListenable: ZegoLiveStreamingPKBattleManager().state,
          builder: (context, pkBattleState, _) {
            final inPKMode =
                pkBattleState == ZegoLiveStreamingPKBattleState.inPKBattle ||
                    pkBattleState == ZegoLiveStreamingPKBattleState.loading;
            final needUserMuteMode =
                (!widget.config.stopCoHostingWhenMicCameraOff) || inPKMode;
            return ZegoToggleMicrophoneButton(
              buttonSize: buttonSize,
              iconSize: iconSize,
              normalIcon: ButtonIcon(
                icon: widget.config.bottomMenuBarConfig.buttonStyle
                        ?.toggleMicrophoneOnButtonIcon ??
                    PrebuiltLiveStreamingImage.asset(
                      PrebuiltLiveStreamingIconUrls.toolbarMicNormal,
                    ),
                backgroundColor: Colors.transparent,
              ),
              offIcon: ButtonIcon(
                icon: widget.config.bottomMenuBarConfig.buttonStyle
                        ?.toggleMicrophoneOffButtonIcon ??
                    PrebuiltLiveStreamingImage.asset(
                      PrebuiltLiveStreamingIconUrls.toolbarMicOff,
                    ),
                backgroundColor: Colors.transparent,
              ),
              defaultOn: microphoneDefaultOn,
              muteMode: needUserMuteMode,
            );
          },
        );

      case ZegoMenuBarButtonName.switchAudioOutputButton:
        return ZegoSwitchAudioOutputButton(
          buttonSize: buttonSize,
          iconSize: iconSize,
          defaultUseSpeaker: widget.config.useSpeakerWhenJoining,
          speakerIcon: ButtonIcon(
            icon: widget.config.bottomMenuBarConfig.buttonStyle
                ?.switchAudioOutputToSpeakerButtonIcon,
          ),
          headphoneIcon: ButtonIcon(
            icon: widget.config.bottomMenuBarConfig.buttonStyle
                ?.switchAudioOutputToHeadphoneButtonIcon,
          ),
          bluetoothIcon: ButtonIcon(
            icon: widget.config.bottomMenuBarConfig.buttonStyle
                ?.switchAudioOutputToBluetoothButtonIcon,
          ),
        );
      case ZegoMenuBarButtonName.toggleCameraButton:
        return ZegoToggleCameraButton(
          buttonSize: buttonSize,
          iconSize: iconSize,
          normalIcon: ButtonIcon(
            icon: widget.config.bottomMenuBarConfig.buttonStyle
                    ?.toggleCameraOnButtonIcon ??
                PrebuiltLiveStreamingImage.asset(
                  PrebuiltLiveStreamingIconUrls.toolbarCameraNormal,
                ),
            backgroundColor: Colors.transparent,
          ),
          offIcon: ButtonIcon(
            icon: widget.config.bottomMenuBarConfig.buttonStyle
                    ?.toggleCameraOffButtonIcon ??
                PrebuiltLiveStreamingImage.asset(
                  PrebuiltLiveStreamingIconUrls.toolbarCameraOff,
                ),
            backgroundColor: Colors.transparent,
          ),
          defaultOn: cameraDefaultOn,
        );
      case ZegoMenuBarButtonName.switchCameraButton:
        return ZegoSwitchCameraButton(
          buttonSize: buttonSize,
          iconSize: iconSize,
          icon: ButtonIcon(
            icon: widget.config.bottomMenuBarConfig.buttonStyle
                    ?.switchCameraButtonIcon ??
                PrebuiltLiveStreamingImage.asset(
                  PrebuiltLiveStreamingIconUrls.toolbarFlipCamera,
                ),
            backgroundColor: Colors.transparent,
          ),
          defaultUseFrontFacingCamera: ZegoUIKit()
              .getUseFrontFacingCameraStateNotifier(
                  ZegoUIKit().getLocalUser().id)
              .value,
        );
      case ZegoMenuBarButtonName.leaveButton:
        return ZegoLeaveStreamingButton(
          buttonSize: buttonSize,
          iconSize: iconSize,
          icon: ButtonIcon(
            icon: widget
                    .config.bottomMenuBarConfig.buttonStyle?.leaveButtonIcon ??
                const Icon(Icons.close, color: Colors.white),
            backgroundColor: ZegoUIKitDefaultTheme.buttonBackgroundColor,
          ),
          config: widget.config,
          hostManager: widget.hostManager,
          hostUpdateEnabledNotifier: widget.hostUpdateEnabledNotifier,
          isLeaveRequestingNotifier: widget.isLeaveRequestingNotifier,
        );
      case ZegoMenuBarButtonName.beautyEffectButton:
        return ZegoBeautyEffectButton(
          translationText: widget.config.innerText,
          rootNavigator: widget.config.rootNavigator,
          effectConfig: widget.config.effectConfig,
          buttonSize: buttonSize,
          iconSize: iconSize,
          icon: ButtonIcon(
            icon: widget
                .config.bottomMenuBarConfig.buttonStyle?.beautyEffectButtonIcon,
          ),
        );
      case ZegoMenuBarButtonName.soundEffectButton:
        return ZegoSoundEffectButton(
          translationText: widget.config.innerText,
          rootNavigator: widget.config.rootNavigator,
          voiceChangeEffect: widget.config.effectConfig.voiceChangeEffect,
          reverbEffect: widget.config.effectConfig.reverbEffect,
          buttonSize: buttonSize,
          iconSize: iconSize,
          icon: ButtonIcon(
            icon: widget
                .config.bottomMenuBarConfig.buttonStyle?.soundEffectButtonIcon,
          ),
          effectConfig: widget.config.effectConfig,
        );
      case ZegoMenuBarButtonName.coHostControlButton:
        return ZegoCoHostControlButton(
          hostManager: widget.hostManager,
          connectManager: widget.connectManager,
          translationText: widget.config.innerText,
          requestCoHostButtonIcon: ButtonIcon(
            icon: widget.config.bottomMenuBarConfig.buttonStyle
                ?.requestCoHostButtonIcon,
          ),
          cancelRequestCoHostButtonIcon: ButtonIcon(
            icon: widget.config.bottomMenuBarConfig.buttonStyle
                ?.cancelRequestCoHostButtonIcon,
          ),
          endCoHostButtonIcon: ButtonIcon(
            icon: widget
                .config.bottomMenuBarConfig.buttonStyle?.endCoHostButtonIcon,
          ),
          requestCoHostButtonText: widget
              .config.bottomMenuBarConfig.buttonStyle?.requestCoHostButtonText,
          cancelRequestCoHostButtonText: widget.config.bottomMenuBarConfig
              .buttonStyle?.cancelRequestCoHostButtonText,
          endCoHostButtonText: widget
              .config.bottomMenuBarConfig.buttonStyle?.endCoHostButtonText,
        );
      case ZegoMenuBarButtonName.enableChatButton:
        return ZegoDisableChatButton(
          buttonSize: buttonSize,
          iconSize: iconSize,
          enableIcon: ButtonIcon(
            icon: widget
                .config.bottomMenuBarConfig.buttonStyle?.enableChatButtonIcon,
          ),
          disableIcon: ButtonIcon(
            icon: widget
                .config.bottomMenuBarConfig.buttonStyle?.disableChatButtonIcon,
          ),
        );
      case ZegoMenuBarButtonName.toggleScreenSharingButton:
        return ZegoScreenSharingToggleButton(
          buttonSize: buttonSize,
          iconSize: iconSize,
          onPressed: (isScreenSharing) {},
          iconStartSharing: ButtonIcon(
            icon: widget.config.bottomMenuBarConfig.buttonStyle
                ?.toggleScreenSharingOnButtonIcon,
          ),
          iconStopSharing: ButtonIcon(
            icon: widget.config.bottomMenuBarConfig.buttonStyle
                ?.toggleScreenSharingOffButtonIcon,
          ),
        );
      case ZegoMenuBarButtonName.chatButton:
        if (widget.config.bottomMenuBarConfig.showInRoomMessageButton) {
          return ZegoInRoomMessageInputBoardButton(
            translationText: widget.config.innerText,
            hostManager: widget.hostManager,
            onSheetPopUp: (int key) {
              widget.popUpManager.addAPopUpSheet(key);
            },
            onSheetPop: (int key) {
              widget.popUpManager.removeAPopUpSheet(key);
            },
            enabledIcon: ButtonIcon(
              icon: widget.config.bottomMenuBarConfig.buttonStyle
                  ?.chatEnabledButtonIcon,
            ),
            disabledIcon: ButtonIcon(
              icon: widget.config.bottomMenuBarConfig.buttonStyle
                  ?.chatDisabledButtonIcon,
            ),
          );
        } else {
          return const SizedBox();
        }
      case ZegoMenuBarButtonName.expanding:
        return Expanded(child: Container());
      case ZegoMenuBarButtonName.minimizingButton:
        return ZegoUIKitPrebuiltLiveStreamingMinimizingButton(
          prebuiltData: widget.prebuiltData,
        );
    }
  }
}
