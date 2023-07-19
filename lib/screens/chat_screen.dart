import 'package:human_like_typing_bot/constants/constants.dart';
import 'package:human_like_typing_bot/controller/settings_controller.dart';
import 'package:human_like_typing_bot/providers/chats_provider.dart';
import 'package:human_like_typing_bot/providers/models_provider.dart';
import 'package:human_like_typing_bot/services/assets_manager.dart';
import 'package:human_like_typing_bot/widgets/chat_widget.dart';
import 'package:human_like_typing_bot/widgets/settings_page.dart';
import 'package:human_like_typing_bot/widgets/text_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  bool _isTyping = false;
  late TextEditingController textEditingController;
  late ScrollController _listScrollController;
  late FocusNode focusNode;

  @override
  void initState() {
    textEditingController = TextEditingController();
    _listScrollController = ScrollController();
    focusNode = FocusNode();
    super.initState();
  }

  @override
  void dispose() {
    textEditingController.dispose();
    _listScrollController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  // List<ChatModel> chatList = [];
  @override
  Widget build(BuildContext context) {
    final modelsProvider = Provider.of<ModelsProvider>(context);
    final chatProvider = Provider.of<ChatProvider>(context);
    final settingsController = Provider.of<SettingsController>(context);
    return Scaffold(
        appBar: AppBar(
          elevation: 2,
          leading: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset(AssetsManager.chatBotLogo),
          ),
          title: const Text("ChatBot"),
          actions: [
            IconButton(
                onPressed: () async {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return SettingsPage();
                    },
                  );
                },
                icon: const Icon(Icons.more_vert_rounded),
                color: Colors.white)
          ],
        ),
        body: SafeArea(
            child: Column(
          children: [
            Flexible(
              child: ListView.builder(
                  controller: _listScrollController,
                  itemCount: chatProvider.getChatList.length,
                  // itemCount: 6,

                  itemBuilder: (context, index) {
                    return Consumer<SettingsController>(
                        builder: (context, settingsController, _) {
                      return chatWidget(
                        msg: chatProvider
                            .getChatList[index].msg, //chatList[index].msg,
                        chatIndex: chatProvider.getChatList[index].chatIndex,
                        synonyms: chatProvider.getChatList[index].synonyms,
                        settingsController: settingsController,
                        //chatList[index].chatIndex,
                        // msg: chatMessages[index]["msg"].toString(),
                        // chatIndex: int.parse(
                        //     chatMessages[index]["chatIndex"].toString()),
                      );
                    });
                  }),
            ),
            if (_isTyping) ...[
              const SpinKitThreeBounce(color: Colors.white, size: 18),
            ],
            const SizedBox(height: 15),
            Material(
              color: cardColor,
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: TextField(
                        style: TextStyle(color: Colors.grey[400]),
                        focusNode: focusNode,
                        controller: textEditingController,
                        onSubmitted: (value) async {
                          //TODO: send message
                          await sendMessageFCT(
                              modelsProvider: modelsProvider,
                              chatProvider: chatProvider,
                              settingsController: settingsController);
                        },
                        decoration: const InputDecoration.collapsed(
                            hintText: "Send a message here ;)",
                            hintStyle: TextStyle(color: Colors.grey)),
                      ),
                    ),
                  ),
                  IconButton(
                      onPressed: () async {
                        await sendMessageFCT(
                            modelsProvider: modelsProvider,
                            chatProvider: chatProvider,
                            settingsController: settingsController);
                      },
                      icon: const Icon(
                        Icons.send,
                        color: Colors.white,
                      ))
                ],
              ),
            )
          ],
        )));
  }

  void scrollListToEnd() {
    _listScrollController.animateTo(
        _listScrollController.position.maxScrollExtent,
        duration: const Duration(seconds: 2),
        curve: Curves.easeOut);
  }

  Future<void> sendMessageFCT(
      {required ModelsProvider modelsProvider,
      required ChatProvider chatProvider,
      required SettingsController settingsController}) async {
    if (_isTyping) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content:
            TextWidget(label: "You can't send multiple messages at a time"),
        backgroundColor: Colors.red,
      ));
    }
    if (textEditingController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: TextWidget(
          label: "Please type a message",
        ),
        backgroundColor: Colors.red,
      ));
      return;
    }
    try {
      String msg = textEditingController.text;
      setState(() {
        _isTyping = true;
        // chatList.add(ChatModel(msg: textEditingController.text, chatIndex: 0));
        chatProvider.addUserMessage(msg: msg);
        // chatProvider.addUserMessage(msg: textEditingController.text);
        textEditingController.clear();
        focusNode.unfocus();
      });

      await chatProvider.sendMessageAndGetAnswers(
          msg: msg,
          // msg: textEditingController.text,
          chosenModelId: modelsProvider.getCurrentModel,
          settingsController: settingsController);
      // chatList.addAll(await ApiService.sendMessage(
      //     message: textEditingController.text,
      //     modelId: modelsProvider.getCurrentModel));
      setState(() {});
    } catch (error) {
      print("error $error");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: TextWidget(
          label: error.toString(),
        ),
        backgroundColor: Colors.red,
      ));
    } finally {
      setState(() {
        scrollListToEnd();
        _isTyping = false;
      });
    }
  }
}
