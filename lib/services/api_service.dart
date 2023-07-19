import "dart:convert";
import "dart:io";

import "package:human_like_typing_bot/constants/api_constants.dart";
import "package:human_like_typing_bot/constants/api_secret_constants.dart";
import "package:human_like_typing_bot/controller/settings_controller.dart";
import "package:human_like_typing_bot/models/chat_model.dart";
import "package:human_like_typing_bot/models/models_model.dart";
import "package:http/http.dart" as http;

class ApiService {
  static SettingsController settingsController = SettingsController();
  static Future<List<ModelsModel>> getModels() async {
    try {
      var response = await http.get(
        Uri.parse("$OPENAI_BASE_URL/models"),
        headers: {'Authorization': 'Bearer $OPENAI_API_KEY'},
      );

      Map jsonResponse = jsonDecode(response.body);
      if (jsonResponse['error'] != null) {
        print("jsonResponse['error'] $jsonResponse['error']['message']");
        throw HttpException(jsonResponse['error']['message']);
      }
      // print("jsonResonse $jsonResponse");
      List temp = [];
      for (var value in jsonResponse['data']) {
        temp.add(value);
        // log("temp $value");
        print("temp $value");
      }
      return ModelsModel.modelsFromSnapshot(temp);
    } catch (error) {
      print("errorss $error");
      rethrow;
    }
  }

  static Future<List<ChatModel>> sendMessage(
      {required String message,
      required String modelId,
      required SettingsController settingsController}) async {
    var processedMessage = message.trim() +
        " (Please provide a reply with no more than ${settingsController.sentenceLimit} sentences, and less than ${settingsController.wordsLimit} words in total.)";
    try {
      var response = await http.post(Uri.parse("$OPENAI_BASE_URL/completions"),
          headers: {
            'Authorization': 'Bearer $OPENAI_API_KEY',
            "Content-Type": "application/json"
          },
          body: jsonEncode({
            "model": modelId,
            "prompt": processedMessage,
            "max_tokens": 500,
          }));

      Map jsonResponse = jsonDecode(response.body);
      if (jsonResponse['error'] != null) {
        print("jsonResponse['error'] $jsonResponse['error']['message']");
        throw HttpException(jsonResponse['error']['message']);
      }
      String message = (jsonResponse["choices"][0]["text"]).trim();

      List<ChatModel> chatList = [];

      print("jsonResponse[choices]test ${message}");

      // List<List<String>> adjectiveSynonymPairs =
      //     await ApiService.getReplacement(message: message);

      // if (jsonResponse["choices"].length > 0) {
      //   chatList = List.generate(
      //     jsonResponse["choices"].length,
      //     (index) => ChatModel(
      //         msg: jsonResponse["choices"][index]["text"], chatIndex: 1),
      //   );
      // }
      // ApiService.getReplacement(message: jsonResponse["choices"][0]["text"]);

      chatList.add(ChatModel(msg: message, chatIndex: 1, synonyms: []));

      return chatList;
    } catch (error) {
      print("Send Message Error: $error");
      rethrow;
    }
  }

  static Future<List<List<String>>> getReplacement(
      {required String message}) async {
    var fullPrompt =
        "In this given paragraph, \"$message\". Please find me 2 single words in each sentence, and provide their replacements (ONE synonym that fits the context for each selected word). Please give me an output of solely JSON format. In this JSON object, with key = sentence index (which is an integer), the value would be a list of object which each have two key-value pairs, where the keys are word and alternative.";
    try {
      var extraResponse = await http.post(
        Uri.parse("$OPENAI_BASE_URL/completions"),
        headers: {
          'Authorization': 'Bearer $OPENAI_API_KEY',
          "Content-Type": "application/json"
        },
        body: jsonEncode(
          {
            "model": "text-davinci-003",
            "prompt": fullPrompt,
            "temperature": 0,
            "max_tokens": 500
          },
        ),
      );

      Map extraJsonResponse = jsonDecode(extraResponse.body);
      if (extraJsonResponse['error'] != null) {
        print(
            "extraJsonResponse['error'] $extraJsonResponse['error']['message']");
        throw HttpException(extraJsonResponse['error']['message']);
      }

      print(
          "extraJsonResponse[choices]test ${extraJsonResponse["choices"][0]["text"]}");

      List<List<String>> adjectiveSynonymPairs = [];
      List<String> adjectives = [];
      List<String> alternatives = [];
      List<ChatModel> chatList = [];
      if (extraJsonResponse["choices"].length > 0) {
        String textOfSynonyms = extraJsonResponse["choices"][0]["text"];
        Map<String, dynamic> json = jsonDecode(textOfSynonyms);
        json.forEach((key, value) {
          String word = value['word'];
          String alternative = value['alternative'];

          adjectives.add(word);
          alternatives.add(alternative);
        });
        adjectiveSynonymPairs.add(adjectives);
        adjectiveSynonymPairs.add(alternatives);

        chatList.add(ChatModel(
            msg: message, chatIndex: 1, synonyms: adjectiveSynonymPairs));
      }
      return adjectiveSynonymPairs;
      // return chatList;
    } catch (error) {
      print("Get Replacements Error: $error");
      rethrow;
    }
  }

  // static Future<List<List<String>>> getDeletion(
  //     {required String message}) async {
  //   var fullPrompt =
  //       "In this given paragraph, \"$message\", please insert a total of ${settingsController.deletionNum} redundant but kinda relevant words that will make the sentence look weird to the 2nd sentence, and let me know after which word you would like to insert these deletable redundant words. Please reply with solely JSON format. I would like the response to include one key-value pair with the key \"deletion\", and the value should be a list of three key-value pairs. Each key-value pair represents a redundant word to be deleted, with the first key being \"index\" representing the sentence index (e.g., 2 for the second sentence), the second key being \"after\" representing the word after which the redundant word should be inserted, and the third key being \"delete\" representing the redundant word to be deleted.";
  //   try {
  //     var extraResponse = await http.post(
  //       Uri.parse("$OPENAI_BASE_URL/completions"),
  //       headers: {
  //         'Authorization': 'Bearer $OPENAI_API_KEY',
  //         "Content-Type": "application/json"
  //       },
  //       body: jsonEncode(
  //         {
  //           "model": "text-davinci-003",
  //           "prompt": fullPrompt,
  //           "temperature": 0,
  //           "max_tokens": 100
  //         },
  //       ),
  //     );

  //     Map extraJsonResponse = jsonDecode(extraResponse.body);
  //     if (extraJsonResponse['error'] != null) {
  //       print(
  //           "extraJsonResponse['error'] $extraJsonResponse['error']['message']");
  //       throw HttpException(extraJsonResponse['error']['message']);
  //     }

  //     print(
  //         "extraJsonResponse[choices]test ${extraJsonResponse["choices"][0]["text"]}");

  //     List<List<String>> adjectiveSynonymPairs = [];
  //     List<String> adjectives = [];
  //     List<String> alternatives = [];
  //     List<ChatModel> chatList = [];
  //     if (extraJsonResponse["choices"].length > 0) {
  //       String textOfSynonyms = extraJsonResponse["choices"][0]["text"];
  //       Map<String, dynamic> json = jsonDecode(textOfSynonyms);
  //       json.forEach((key, value) {
  //         String word = value['word'];
  //         String alternative = value['alternative'];

  //         adjectives.add(word);
  //         alternatives.add(alternative);
  //       });
  //       adjectiveSynonymPairs.add(adjectives);
  //       adjectiveSynonymPairs.add(alternatives);

  //       chatList.add(ChatModel(
  //           msg: message, chatIndex: 1, synonyms: adjectiveSynonymPairs));
  //     }
  //     return adjectiveSynonymPairs;
  //     // return chatList;
  //   } catch (error) {
  //     print("Get Replacements Error: $error");
  //     rethrow;
  //   }
  // }
}
