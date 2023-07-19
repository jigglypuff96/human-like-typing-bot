import 'package:human_like_typing_bot/controller/settings_controller.dart';
import 'package:human_like_typing_bot/services/words_api_service.dart';
import 'package:human_like_typing_bot/utils/index_generator.dart';
import 'package:human_like_typing_bot/utils/random_generator.dart';

import '../constants/words_library.dart';

class MessageMaker {
  static String extractAlphabeticPart(String input) {
    RegExp regex = RegExp(r'[a-zA-Z]+');
    Iterable<Match> matches = regex.allMatches(input);
    return matches.map((match) => match.group(0)).join();
  }

  static List<String> splitIntoSentences(String message) {
    // message is a paragraph
    List<String> sentences = [];
    for (int sIndex = 0; sIndex < message.length; sIndex++) {
      String paragraph = message.trim();
      List<String> sentences = [];

      String currentSentence = '';

      for (int i = 0; i < paragraph.length; i++) {
        String currentChar = paragraph[i];

        if (currentChar == '.' ||
            currentChar == '!' ||
            currentChar == '?' ||
            currentChar == '\n') {
          currentSentence += currentChar;
          sentences.add(currentSentence.trim());
          currentSentence = '';
        } else {
          currentSentence += currentChar;
        }
      }

      if (currentSentence.isNotEmpty) {
        sentences.add(currentSentence.trim());
      }
    }

    return sentences;
  }

  static Map<int, String> getSentencesMap(List<String> splittedParagraph) {
    Map<int, String> sentencesMap = splittedParagraph.asMap();
    return sentencesMap;
  }

  static Map<dynamic, dynamic> markSplittedParagraph(
    List<String> splittedParagraph,
    SettingsController settingsController,
  ) {
    '''
      input: A map with keys = the index of sentence in a paragraph, value = the sentences;
      output: An updated map with keys = the index of sentence in a paragraph, value = [deleted/inserted/replaced, the sentence];
    ''';
    Map<int, String> sentencesMap =
        MessageMaker.getSentencesMap(splittedParagraph);
    // get from Settings controller
    int numOfSentences = splittedParagraph.length;
    // Deletion

    int numOfSentenceToBeDeleted =
        (settingsController.sentenceDeletionRate * numOfSentences).toInt(); //1;
    // Insertion
    int numOfSentenceToBeInserted =
        (settingsController.sentenceInsertionRate * numOfSentences)
            .toInt(); //1;

    List<int> counts = [numOfSentenceToBeDeleted, numOfSentenceToBeInserted];
    //avoid beginning and end
    // have sentence level insertions only if we have more than 5 sentences
    List<int> toBeDeletedIndices = [];
    List<int> toBeInsertedIndices = [];
    //TODO: deal with shorter paragraphs
    if (splittedParagraph.length >= 4) {
      if (numOfSentenceToBeDeleted > 0 && numOfSentenceToBeInserted > 0) {
        List<List<int>> selectedIndices = IndexGenerator.getRandomForCategories(
            1, sentencesMap.length - 1 - 1, counts);
        if (selectedIndices.length >= 2) {
          toBeDeletedIndices = [...selectedIndices[0]];
          toBeInsertedIndices = [...selectedIndices[1]];
        }
      } else if (numOfSentenceToBeDeleted > 0) {
        toBeDeletedIndices = IndexGenerator.getRandomList(
            1, sentencesMap.length - 1 - 1, numOfSentenceToBeDeleted);
      } else if (numOfSentenceToBeInserted > 0) {
        toBeInsertedIndices = IndexGenerator.getRandomList(
            1, sentencesMap.length - 1 - 1, numOfSentenceToBeDeleted);
      }
    }
    print("toBeDeletedIndices: $toBeDeletedIndices");
    print("toBeInsertedIndices: $toBeInsertedIndices");

    Map<dynamic, dynamic> markedSentencesMap =
        {}; // Map<int, Map<String, Object>>

    for (int i = 0; i < sentencesMap.length; i++) {
      List<String> splittedIntoWords =
          MessageMaker.splitIntoWords(splittedParagraph[i]);
      if (toBeDeletedIndices.contains(i)) {
        // 1. delete while the sentence is being typed out
        // 2. delete once the sentence is complete.
        // 3. delete when everything is completed (wordIndices?, cumulative)

        markedSentencesMap[i] = {
          "action": "delete",
          "completed": false,
          "original": splittedIntoWords,
          "child": splittedIntoWords
        };
      } else if (toBeInsertedIndices.contains(i)) {
        markedSentencesMap[i] = {
          "action": "insert",
          "completed": false,
          "original": splittedIntoWords,
          "child": []
        };
      } else {
        markedSentencesMap[i] = {
          "action": "replace",
          "completed": false,
          "original": splittedIntoWords,
          "child": MessageMaker.markSplittedSentence(
              splittedIntoWords, settingsController)
        };
      }
    }
    return markedSentencesMap;
  }

  static List<String> splitIntoWords(String currentSentence) {
    List<String> words = currentSentence.trim().split(' ');
    return words;
  }

  static Map<int, String> getWordsMap(List<String> splittedSingleSentence) {
    Map<int, String> wordsMap = splittedSingleSentence.asMap();
    return wordsMap;
  }

  static Future<List<List>> markSplittedSentence(
    List<String> splittedSentence,
    SettingsController settingsController,
  ) async {
    List<List<dynamic>> originalAndWrong = [];
    List<dynamic> marks =
        List<dynamic>.from(List.filled(splittedSentence.length, ''));

    List<Map<String, dynamic>> typoInfoList = List.generate(
      splittedSentence.length,
      (index) => {},
    );

    // Map<int, String> wordsMap = MessageMaker.getWordsMap(
    //     splittedSentence); // singleSplittedSentence =  MessageMaker.splitIntoWords(String singleSentence);

    // get from Settings controller
    int numOfWords = splittedSentence.length;

    // Deletion
    int numOfWordToBeDeleted =
        (settingsController.wordDeletionRate * numOfWords).toInt(); // 1
    print(
        "settingsController.wordDeletionRate = ${settingsController.wordDeletionRate}");
    print("number of words to be deleted = $numOfWordToBeDeleted");
    // Insertion
    int numOfWordToBeInserted =
        (settingsController.wordInsertionRate * numOfWords).toInt(); // 1;
    print(
        "settingsController.wordInsertionRate = ${settingsController.wordInsertionRate}");
    print("number of words to be inserted = $numOfWordToBeInserted");

    // Replacement and Typo are both change in place,
    int numberOfWordToBeModified =
        (settingsController.wordModificationRate * numOfWords).toInt(); //1;
    // Replacement
    int numOfWordToBeReplaced = (numberOfWordToBeModified * 0.3).toInt();
    // Typo
    int numOfWordToBeTypoed = (numberOfWordToBeModified * 0.7).toInt();

    // int numOfWordToBeReplaced =
    //     (settingsController.replacementRate * numOfWords).toInt(); //1;
    // print(
    //     "settingsController.replacementRate = ${settingsController.replacementRate}");
    // print("number of words to be replaced = $numOfWordToBeReplaced");
    // // Typo
    // int numOfWordToBeTypoed =
    //     (settingsController.typoRate * numOfWords).toInt(); //1;
    // print("settingsController.typoRate = ${settingsController.typoRate}");
    // print("number of words to be typoed = $numOfWordToBeTypoed");

    List<String> updatingSplittedSentence = List.from(splittedSentence);

    List<int> toBeInsertedIndices = IndexGenerator.getRandomList(
        0, updatingSplittedSentence.length - 1, numOfWordToBeInserted);
    for (int i = toBeInsertedIndices.length - 1; i > -1; i--) {
      // updatingSplittedSentence.removeAt(toBeInsertedIndices[i]);
      updatingSplittedSentence[toBeInsertedIndices[i]] = "";
      marks[toBeInsertedIndices[i]] = "insert";
    }

    List<List<int>> toBeChangeInPlacedIndices =
        IndexGenerator.getRandomForCategories(
            0,
            updatingSplittedSentence.length - 1,
            [numOfWordToBeReplaced, numOfWordToBeTypoed]);
    List<int> toBeReplacedIndices = [...toBeChangeInPlacedIndices[0]];
    List<int> toBeTypoedIndices = [...toBeChangeInPlacedIndices[1]];
    for (int i = 0; i < toBeReplacedIndices.length; i++) {
      String shouldPrintWord = splittedSentence[toBeReplacedIndices[i]];
      String onlyAlphabeticalWord = extractAlphabeticPart(shouldPrintWord);
      String synonym = await getSynonyms(onlyAlphabeticalWord);
      if (synonym == '') {
        // do not have a replacement
        // updatingSplittedSentence[toBeReplacedIndices[i]] = splittedSentence[toBeReplacedIndices[i]]; // does not change
        // marks[toBeReplacedIndices[i]] = '';
        print(
            "Should print $shouldPrintWord, but could not find a replacement :(");
      } else {
        print(
            "Should print $shouldPrintWord, will print its synonom: $synonym");
        updatingSplittedSentence[toBeReplacedIndices[i]] = synonym;
        marks[toBeReplacedIndices[i]] = "replace";
      }
    }
    for (int i = 0; i < toBeTypoedIndices.length; i++) {
      int typoIndex = toBeTypoedIndices[i];
      String correctWord = splittedSentence[typoIndex];
      if (correctWord.length <= 2) {
        continue;
      }
      // updatingSplittedSentence[typoIndex] = "TYPOED";
      marks[typoIndex] = "typo";

      // Typo ways: (all will be limited to non beginning, non ending characters)
      // TODO: make the wrong characters, more QWERTY
      int typoType;
      if (correctWord.length <= 3) {
        typoType = IndexGenerator.getRandomInt(
            1, 2); // select 1 index among 1 and 2 , avoid swap, word too short
      } else {
        typoType =
            IndexGenerator.getRandomInt(1, 3); // select 1 index among 1~3
      }
      // one more character
      if (typoType == 1) {
        int indexForExtraChar = IndexGenerator.getRandomInt(
            1, correctWord.length - 1); // avoid beginning or ending
        String extraChar = RandomGenerator.randomAbc();
        updatingSplittedSentence[typoIndex] =
            correctWord.substring(0, indexForExtraChar) +
                extraChar +
                correctWord.substring(indexForExtraChar);
        typoInfoList[typoIndex]["action"] = "remove";
        typoInfoList[typoIndex]["index"] = indexForExtraChar;
        typoInfoList[typoIndex]["char"] = extraChar;
      }
      // one less character
      else if (typoType == 2) {
        int indexForMissingChar = IndexGenerator.getRandomInt(
            1, correctWord.length - 1); // avoid beginning or ending
        String missingChar = correctWord[indexForMissingChar];
        updatingSplittedSentence[typoIndex] =
            correctWord.substring(0, indexForMissingChar) +
                correctWord.substring(indexForMissingChar + 1);
        typoInfoList[typoIndex]["action"] = "add";
        typoInfoList[typoIndex]["index"] = indexForMissingChar;
        typoInfoList[typoIndex]["char"] = missingChar;
      }
      // misplacement
      else if (typoType == 3) {
        int indexForSwappedChar = IndexGenerator.getRandomInt(
            1, correctWord.length - 2); // avoid beginning or ending
        String rightChar = correctWord[indexForSwappedChar + 1];
        String leftChar = correctWord[indexForSwappedChar];
        updatingSplittedSentence[typoIndex] =
            correctWord.substring(0, indexForSwappedChar) +
                rightChar + // [indexForSwappedChar]
                leftChar + // [indexForSwappedChar + 1]
                correctWord.substring(indexForSwappedChar + 2);
        typoInfoList[typoIndex]["action"] = "swap"; // delete + insert
        typoInfoList[typoIndex]["index"] = indexForSwappedChar;
        typoInfoList[typoIndex]["char"] = rightChar;
      }
    }

    List<int> toBeDeletedIndices = IndexGenerator.getRandomList(
        0, updatingSplittedSentence.length - 1, numOfWordToBeDeleted);
    for (int i = 0; i < toBeDeletedIndices.length; i++) {
      int randomCommonWordIndex =
          RandomGenerator.randomInt(0, commonWords.length - 1);
      updatingSplittedSentence.insert(
          toBeDeletedIndices[i] + i, commonWords[randomCommonWordIndex]);
      splittedSentence.insert(toBeDeletedIndices[i] + i, "");
      marks.insert(toBeDeletedIndices[i] + i, "delete");
      typoInfoList.insert(toBeDeletedIndices[i] + i, {});
    }
    originalAndWrong.add(splittedSentence);
    originalAndWrong.add(updatingSplittedSentence);
    originalAndWrong.add(marks);
    originalAndWrong.add(typoInfoList);

    return originalAndWrong;
  }
}
