import 'package:human_like_typing_bot/controller/settings_controller.dart';
import 'package:human_like_typing_bot/models/chat_model.dart';
import 'package:human_like_typing_bot/services/api_service.dart';
import 'package:flutter/material.dart';

class ChatProvider with ChangeNotifier {
  List<ChatModel> chatList = [];
  List<ChatModel> get getChatList {
    return chatList;
  }

  void addUserMessage({required String msg}) {
    chatList.add(ChatModel(msg: msg, chatIndex: 0));
    notifyListeners();
  }

  Future<void> sendMessageAndGetAnswers(
      {required String msg,
      required String chosenModelId,
      required SettingsController settingsController}) async {
    chatList.addAll(await ApiService.sendMessage(
        message: msg,
        modelId: chosenModelId,
        settingsController: settingsController));
    notifyListeners();
  }
}
