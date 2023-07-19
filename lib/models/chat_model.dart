class ChatModel {
  final String msg;
  final int chatIndex;
  final List<List<String>>? synonyms;

  ChatModel({required this.msg, required this.chatIndex, this.synonyms});

  factory ChatModel.fromJson(Map<String, dynamic> json) => ChatModel(
        msg: json["msg"],
        chatIndex: json["chatIndex"],
        synonyms: json["synonyms"] ?? [],
      );
}
