import 'package:human_like_typing_bot/constants/constants.dart';
import 'package:human_like_typing_bot/controller/settings_controller.dart';
import 'package:human_like_typing_bot/services/assets_manager.dart';
import 'package:human_like_typing_bot/widgets/human_typed_text.dart';
import 'package:human_like_typing_bot/widgets/text_widget.dart';
import 'package:flutter/material.dart';

class chatWidget extends StatelessWidget {
  final SettingsController settingsController;

  const chatWidget(
      {super.key,
      required this.msg,
      required this.chatIndex,
      this.synonyms,
      required this.settingsController});

  final String msg;
  final int chatIndex;
  final List<List<String>>? synonyms;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Material(
            color: chatIndex == 0 ? scaffoldBackgroundColor : cardColor,
            child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.asset(
                        chatIndex == 0
                            ? AssetsManager.userImage
                            : AssetsManager.botImage,
                        color: chatIndex == 0 ? Colors.cyan : Colors.teal,
                        colorBlendMode: BlendMode.modulate,
                        height: 30,
                        width: 30),
                    const SizedBox(
                      width: 8,
                    ),
                    Expanded(
                        child: chatIndex == 0
                            ? TextWidget(label: msg)
                            : HumanTypedText(
                                text: msg.trim(),
                                synonyms: synonyms,
                                settingsController: settingsController,
                              )),
                    chatIndex == 0
                        ? const SizedBox.shrink()
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.thumb_up_alt_outlined,
                                color: Colors.white,
                              ),
                              SizedBox(width: 5),
                              Icon(Icons.thumb_down_alt_outlined,
                                  color: Colors.white)
                            ],
                          )
                  ],
                )))
      ],
    );
  }
}
