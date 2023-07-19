import 'dart:convert';
import 'package:human_like_typing_bot/constants/api_constants.dart';
import 'package:human_like_typing_bot/constants/api_secret_constants.dart';
import 'package:http/http.dart' as http;

Future<String> getSynonyms(String word) async {
  // check if the
  final apiKey = WORDS_API_KEY; // Replace with your WordsAPI API key
  final url = '$WORDS_BASE_URL/$word/synonyms';

  final response = await http.get(Uri.parse(url), headers: {
    'X-RapidAPI-Key': apiKey,
    'X-RapidAPI-Host': 'wordsapiv1.p.rapidapi.com',
  });

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    final synonyms = data['synonyms'] as List<dynamic>;
    if (synonyms.length > 0) {
      return synonyms[0];
    } else {
      return '';
    }
  } else {
    print("API could not find an synonym for the word.");
    return '';
    // throw Exception(
    //     'Failed to retrieve synonyms. Status code: ${response.statusCode}');
  }
}
