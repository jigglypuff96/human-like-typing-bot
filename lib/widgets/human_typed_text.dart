import 'dart:async';

import 'package:human_like_typing_bot/controller/settings_controller.dart';
import 'package:human_like_typing_bot/utils/index_generator.dart';
import 'package:human_like_typing_bot/utils/mistake_model.dart';
import 'package:human_like_typing_bot/utils/random_generator.dart';
import 'package:human_like_typing_bot/utils/typing_speed.dart';
import 'package:flutter/material.dart';

import '../utils/message_maker.dart';

class HumanTypedText extends StatefulWidget {
  final SettingsController settingsController;

  final String text;
  // final BuildContext contex;
  final List<List<String>>? synonyms;
  HumanTypedText(
      {required this.text, this.synonyms, required this.settingsController});

  @override
  _HumanTypedTextState createState() => _HumanTypedTextState();
}

class _HumanTypedTextState extends State<HumanTypedText> {
  // SettingsController settingsController = SettingsController();
  List<String> words = [];
  List<String> sentences = [];
  // int cumulativeIndex = 0;
  int sIndex = 0;
  List<int> cumulates = [0];
  String leftText = '';
  String rightText = '';
  String fullText = '';

  int characterLagTime = 100;
  int spaceLagTime = 300;
  int deletionSpeed = 100;
  int cursorMovingSpeed = 20;

  int hesitationWordsRate = 0;
  int hesitationTime = 600;

  int countdown = 0;

  bool showCountdown = true;
  bool isInsertionFinished = false;
  bool isBackSpaceFinished = false;
  bool isCursorVisible = false;
  int cursorPosition = 0;
  bool showCursor = true;
  bool isCursorMovingFinished = true;

  List<String> adjectives = [];
  List<String> alternatives = [];

  Timer? cursorTimer;

  @override
  void initState() {
    super.initState();
    characterLagTime = widget.settingsController.characterPace.toInt();
    hesitationWordsRate =
        (widget.settingsController.hesitationWordsRate * 100).toInt();
    hesitationTime = widget.settingsController.hesitationTime.toInt();
    // countdown = int.parse(settingsController.thinkingTime);
    // cumulativeIndex = 0;
    cumulates = [0];
    leftText = '';
    rightText = '';
    fullText = '';

    // adjectives = (widget.synonyms)![0];
    // alternatives = (widget.synonyms)![1];

    sentences = separateSentences();
    _startCountdown();
    cursorTimer = Timer.periodic(Duration(milliseconds: 500), (Timer timer) {
      setState(() {
        showCursor = !showCursor;
      });
    });
  }

  @override
  void dispose() {
    // Cancel the timer when the widget is disposed
    cursorTimer?.cancel();
    // showCursor = false;
    super.dispose();
  }

  void updateState(
    String rightText,
    String leftText,
    String fullText,
    int cursorPosition,
  ) {
    setState(() {
      this.rightText = rightText;
      this.leftText = leftText;
      this.fullText = fullText;
      this.cursorPosition = cursorPosition;
    });
  }

  List<String> separateSentences() {
    String paragraph = widget.text.trim();
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

    return sentences;
  }

  void _startCountdown() {
    Timer.periodic(Duration(seconds: 1), (timer) {
      print('Countdown: $countdown');
      setState(() {
        countdown--;
      });
      if (countdown <= 0) {
        timer.cancel();
        setState(() {
          showCountdown = false;
        });
        _displayText();
      }
    });
  }

  void _displayText() async {
    Map<dynamic, dynamic> sentencesMap = MessageMaker.markSplittedParagraph(
        sentences, widget.settingsController);
    List<dynamic> sentenceActions = [];
    int processLaterFlag = 0;
    while (sIndex < sentencesMap.length) {
      // for (int sIndex = 0; sIndex < sentences.length; sIndex++) {
      // print("sIndex = $sIndex");
      // String currentSentence = sentences[sIndex];
      Map currentSentenceMap = sentencesMap[sIndex];
      words = currentSentenceMap["original"];
      // words = currentSentence.trim().split(' ');
      if (words.isNotEmpty) {
        if (currentSentenceMap["action"] == "replace") {
          processLaterFlag = 0;
          List<List<dynamic>> originalAndWrong =
              await currentSentenceMap["child"];
          List<dynamic> shouldDisplayed = originalAndWrong[0];
          List<dynamic> firstDisplayed = originalAndWrong[1];
          List<dynamic> wordMark = originalAndWrong[2];
          List<dynamic> typoInfoList = originalAndWrong[3];

          Map<int, List<int>> wordsIndices = {};
          List<dynamic> actions = [];

          // int reducedIndices = 0;

          // Display, delete, and replace the selected words
          int i = 0;
          int startingIndex = 0;
          while (i < firstDisplayed.length) {
            // print("Word index i = $i");
            String word = firstDisplayed[i];
            String rightWord = shouldDisplayed[i];

            bool isToBeDeleted = false;
            bool isToBeInserted = false;
            bool isToBeReplaced = false;
            bool isToBeTypoCorrected = false;
            if (wordMark[i] == 'delete') {
              isToBeDeleted = true;
            } else if (wordMark[i] == "insert") {
              isToBeInserted = true;
            } else if (wordMark[i] == "replace") {
              isToBeReplaced = true;
            } else if (wordMark[i] == "typo") {
              isToBeTypoCorrected = true;
            }

            // Display the word
            // hesitate before word
            if (RandomGenerator.randomInt(1, 100) < hesitationWordsRate) {
              print("hesitating,,,,");
              await Future.delayed(Duration(
                  milliseconds:
                      (hesitationTime * TypingSpeed.generateRandomNumber())
                          .toInt()));
            }

            for (int j = 0; j < word.length; j++) {
              await Future.delayed(Duration(
                  milliseconds:
                      (characterLagTime * TypingSpeed.generateRandomNumber())
                          .toInt()));
              setState(() {
                leftText += word[j];
                fullText = leftText + rightText;
                cursorPosition++;
              });
            }

            wordsIndices[i] = [startingIndex, startingIndex + word.length];
            startingIndex += word.length;

            if (isToBeInserted) // word.length == 0
            {
              actions.add(["insert", i, rightWord]);
              i++;
              continue;
            }

            if (isToBeDeleted) {
              if (RandomGenerator.randomZeroOne() == 0) {
                actions.add(["delete", i, rightWord]);
              } else {
                for (int j = word.length - 1; j >= 0; j--) {
                  await Future.delayed(Duration(milliseconds: deletionSpeed));
                  setState(() {
                    leftText = leftText.substring(0, leftText.length - 1);
                    fullText = leftText + rightText;
                    cursorPosition--;
                  });
                }

                wordsIndices[i] = [
                  startingIndex - word.length,
                  startingIndex - word.length
                ];
                startingIndex -= word.length;
                i++;
                continue; // for the next word, since it will be added by one at the end: i != words.length-1
              }
            }

            if (isToBeTypoCorrected) {
              if (RandomGenerator.randomZeroOne() == 0) {
                typoInfoList[i]["wrong"] = word;
                actions.add(["typo", i, typoInfoList[i]]);
              } else {
                // Delete the word character by character
                int targetCharIndex = typoInfoList[i]["index"];
                if (typoInfoList[i]["action"] == "add") {
                  for (int j = word.length - 1; j >= targetCharIndex; j--) {
                    await Future.delayed(
                        Duration(milliseconds: cursorMovingSpeed));
                    setState(() {
                      rightText = leftText[leftText.length - 1] + rightText;
                      leftText = leftText.substring(0, leftText.length - 1);
                      fullText = leftText + rightText;
                      cursorPosition--;
                    });
                  }
                  await Future.delayed(
                      Duration(milliseconds: characterLagTime));
                  setState(() {
                    leftText = leftText + typoInfoList[i]["char"];
                    fullText = leftText + rightText;
                    cursorPosition++;
                  });

                  wordsIndices[i] = [
                    startingIndex - word.length,
                    startingIndex + 1
                  ];
                  startingIndex = startingIndex + 1;
                  await _moveCursor(
                      cursorPosition + word.length - targetCharIndex);
                } else if (typoInfoList[i]["action"] == "remove") {
                  for (int j = word.length - 1; j > targetCharIndex; j--) {
                    await Future.delayed(
                        Duration(milliseconds: cursorMovingSpeed));
                    setState(() {
                      rightText = leftText[leftText.length - 1] + rightText;
                      leftText = leftText.substring(0, leftText.length - 1);
                      fullText = leftText + rightText;
                      cursorPosition--;
                    });
                  }
                  await Future.delayed(
                      Duration(milliseconds: characterLagTime));
                  setState(() {
                    leftText = leftText.substring(0, leftText.length - 1);
                    fullText = leftText + rightText;
                    cursorPosition--;
                  });

                  wordsIndices[i] = [
                    startingIndex - word.length,
                    startingIndex - 1
                  ];
                  startingIndex = startingIndex - 1;

                  await _moveCursor(
                      cursorPosition + word.length - 1 - targetCharIndex);
                } else if (typoInfoList[i]["action"] == "swap") {
                  String characterToSwap = typoInfoList[i]["char"];
                  for (int j = word.length - 1; j > targetCharIndex; j--) {
                    await Future.delayed(
                        Duration(milliseconds: cursorMovingSpeed));
                    setState(() {
                      rightText = leftText[leftText.length - 1] + rightText;
                      leftText = leftText.substring(0, leftText.length - 1);
                      fullText = leftText + rightText;
                      cursorPosition--;
                    });
                  }
                  // remove that character
                  await Future.delayed(
                      Duration(milliseconds: characterLagTime));
                  setState(() {
                    leftText = leftText.substring(0, leftText.length - 1);
                    fullText = leftText + rightText;
                    cursorPosition--;
                  });
                  // move cursor to right for one index
                  await Future.delayed(
                      Duration(milliseconds: characterLagTime));
                  setState(() {
                    leftText = leftText + rightText.substring(0, 1);
                    rightText = rightText.substring(1);
                    fullText = leftText + rightText;
                    cursorPosition++;
                  });
                  // insert the character
                  await Future.delayed(
                      Duration(milliseconds: characterLagTime));
                  setState(() {
                    leftText = leftText + characterToSwap;
                    fullText = leftText + rightText;
                    cursorPosition++;
                  });

                  // wordsIndices[i] remain the same

                  await _moveCursor(
                      cursorPosition + word.length - 1 - targetCharIndex - 1);
                }
              }
            }

            if (isToBeReplaced) {
              if (RandomGenerator.randomZeroOne() == 0) {
                actions.add(["replace", i, rightWord]);
              } else {
                // Delete the word character by character
                for (int j = word.length - 1; j >= 0; j--) {
                  await Future.delayed(Duration(milliseconds: deletionSpeed));
                  setState(() {
                    leftText = leftText.substring(0, leftText.length - 1);
                    fullText = leftText + rightText;
                    cursorPosition--;
                  });
                }

                // Display the right word
                for (int j = 0; j < rightWord.length; j++) {
                  await Future.delayed(Duration(
                      milliseconds: (characterLagTime *
                              TypingSpeed.generateRandomNumber())
                          .toInt()));
                  setState(() {
                    leftText += rightWord[j];
                    fullText = leftText + rightText;
                    cursorPosition++;
                  });
                }

                wordsIndices[i] = [
                  startingIndex - word.length,
                  startingIndex - word.length + rightWord.length
                ];
                startingIndex = startingIndex - word.length + rightWord.length;
              }
            }

            if (i != words.length - 1) {
              await Future.delayed(Duration(
                  milliseconds:
                      (spaceLagTime * TypingSpeed.generateRandomNumber())
                          .toInt()));
              setState(() {
                leftText += ' ';
                fullText = leftText + rightText;
                cursorPosition++;
              });
              startingIndex++;
            }

            i++;
          }

          // TODO: think about ways to make sure the entire sentence displayed
          // // Wait for the entire sentence to be displayed

          await _moveCursor(fullText.length);

          // Perform insertion behavior after all words are displayed
          await _performRemainingBehavior(actions, wordsIndices);

          // await _performDeletionBehavior()
        }
        // await _performBackSpaceBehavior(fullText.length);
        else if (currentSentenceMap["action"] == "delete") {
          int startDeletionWordIndex;
          int deleteAfter = RandomGenerator.randomZeroOne();
          if (deleteAfter == 1) {
            startDeletionWordIndex = -1; // nonexist
            processLaterFlag = 1;
          } else {
            int deleteIncomplete = RandomGenerator.randomZeroOne();
            if (words.length > 3 && deleteIncomplete == 1) {
              startDeletionWordIndex =
                  IndexGenerator.getRandomInt(1, words.length - 1 - 1);
            } else {
              startDeletionWordIndex = words.length - 1;
              // delete right after the whole sentence is being typed out.
            }
          }
          int typedIndex = 0;
          for (int wIndex = 0; wIndex < words.length; wIndex++) {
            String word = words[wIndex];
            // Display the word
            for (int j = 0; j < word.length; j++) {
              await Future.delayed(Duration(
                  milliseconds:
                      (characterLagTime * TypingSpeed.generateRandomNumber())
                          .toInt()));
              setState(() {
                leftText += word[j];
                fullText = leftText + rightText;
                cursorPosition++;
              });
              typedIndex++;
            }
            // add space
            if (wIndex != words.length - 1) {
              await Future.delayed(Duration(
                  milliseconds:
                      (spaceLagTime * TypingSpeed.generateRandomNumber())
                          .toInt()));
              setState(() {
                leftText += ' ';
                fullText = leftText + rightText;
                cursorPosition++;
              });
              typedIndex++;
            }
            // check if the sentence needs to be deleted
            if (startDeletionWordIndex == wIndex) {
              while (typedIndex > 0) {
                await Future.delayed(Duration(
                    milliseconds:
                        (characterLagTime * TypingSpeed.generateRandomNumber())
                            .toInt()));
                setState(() {
                  leftText = leftText.substring(0, leftText.length - 1);
                  fullText = leftText + rightText;
                  cursorPosition--;
                });
                typedIndex--;
              }
              wIndex = words.length; // exit the loop
            }
          }
          await _moveCursor(fullText.length);
        } else if (currentSentenceMap["action"] == "insert") {
          processLaterFlag = 1;
        }

        // add a space to end of the sentence.
        setState(() {
          fullText = leftText + rightText;
          // cumulativeIndex = fullText.length; //??? -1
          cumulates = [...cumulates, fullText.length];
          leftText = fullText;
          rightText = '';

          if (fullText[fullText.length - 1] != " " ||
              fullText[fullText.length - 1] != ' ' ||
              leftText[leftText.length - 1] != " " ||
              leftText[leftText.length - 1] != ' ') {
            fullText += ' ';
            leftText = fullText;
            // cumulativeIndex++;
            cumulates[sIndex + 1]++;
          }
          if (processLaterFlag == 1) {
            sentenceActions.add(
                [currentSentenceMap["action"], sIndex, cumulates[sIndex + 1]]);
          }
        });

        // sentenceActions.add([currentSentenceMap["action"], sIndex, cumulates[sIndex + 1]]);

        await _moveCursor(fullText.length);
        sIndex++;
      }
    }

    // After the paragraph is typed, do sentence-level operations.
    for (int iSentenceLevelTaskIndex = 0;
        iSentenceLevelTaskIndex < sentenceActions.length;
        iSentenceLevelTaskIndex++) {
      List currentActionInfo = sentenceActions[iSentenceLevelTaskIndex];
      String currentAction = currentActionInfo[0];
      int sentenceIdx = currentActionInfo[1];
      int sentenceEndingIdx = cumulates[sentenceIdx + 1];
      int sentenceStartingIdx = cumulates[sentenceIdx];
      await _moveCursor(cumulates[sentenceIdx + 1]);
      if (currentAction == "delete") {
        int discrepancy = sentenceEndingIdx - sentenceStartingIdx;

        while (discrepancy > 0) {
          await Future.delayed(Duration(
              milliseconds:
                  (characterLagTime * TypingSpeed.generateRandomNumber())
                      .toInt()));
          setState(() {
            leftText = leftText.substring(0, leftText.length - 1);
            fullText = leftText + rightText;
            cursorPosition--;
          });
          discrepancy--;
        }
        discrepancy = sentenceEndingIdx - sentenceStartingIdx;
        // cumulates[sentenceIdx + 1] = cumulates[sentenceIdx];
        for (int temp = sentenceIdx + 1; temp < cumulates.length; temp++) {
          cumulates[temp] -= discrepancy;
        }
      } else if (currentAction == "insert") {
        List<String> wordsToInsert = sentencesMap[sentenceIdx]["original"];
        int i = 0;
        int discrepancy = 0;
        while (i < wordsToInsert.length) {
          String word = wordsToInsert[i];
          // Display the word
          // hesitate before word
          if (RandomGenerator.randomInt(1, 100) < hesitationWordsRate) {
            print("hesitating,,,,");
            await Future.delayed(Duration(
                milliseconds:
                    (hesitationTime * TypingSpeed.generateRandomNumber())
                        .toInt()));
          }
          for (int j = 0; j < word.length; j++) {
            await Future.delayed(Duration(
                milliseconds:
                    (characterLagTime * TypingSpeed.generateRandomNumber())
                        .toInt()));
            setState(() {
              leftText += word[j];
              fullText = leftText + rightText;
              cursorPosition++;
              discrepancy++;
            });
          }

          // add a space after each word
          if (i != wordsToInsert.length - 1) {
            await Future.delayed(Duration(
                milliseconds:
                    (spaceLagTime * TypingSpeed.generateRandomNumber())
                        .toInt()));
            setState(() {
              leftText += ' ';
              fullText = leftText + rightText;
              cursorPosition++;
              discrepancy++;
            });
          }

          i++;
        }
        // add a space since we just add a new sentence.
        setState(() {
          if (leftText[leftText.length - 1] != ' ') {
            leftText += ' ';
            fullText = leftText + rightText;
            discrepancy++;
          }
        });

        for (int temp = sentenceIdx + 1; temp < cumulates.length; temp++) {
          cumulates[temp] += discrepancy;
        }
      }
    }

    cursorTimer?.cancel();
    showCursor = false;
  }

  Future<void> _performRemainingBehavior(
      List<dynamic> actions, Map<int, dynamic> wordsIndices) async {
    isInsertionFinished = false;

    for (int i = 0; i < actions.length; i++) {
      // hesitate before action
      if (RandomGenerator.randomInt(1, 100) < hesitationWordsRate) {
        await Future.delayed(Duration(
            milliseconds:
                (hesitationTime * TypingSpeed.generateRandomNumber()).toInt()));
      }
      // we can randomize the sequence later
      if (actions[i][0] == "insert") {
        int correctWordIndex = actions[i][1];
        String rightWord = actions[i][2];
        int startingIndex = wordsIndices[correctWordIndex][0];
        int endingIndex = wordsIndices[correctWordIndex][1];

        // int wordIndex = startingIndex + cumulativeIndex; //???
        int wordIndex = startingIndex + cumulates[sIndex]; //???
        await _moveCursor(wordIndex);

        // Display the "inserty " text
        String insertionText = rightWord;
        insertionText = insertionText.trim() + ' ';

        for (int i = 0; i < insertionText.length; i++) {
          await Future.delayed(Duration(
              milliseconds:
                  (characterLagTime * TypingSpeed.generateRandomNumber())
                      .toInt()));

          setState(() {
            leftText = fullText.substring(0, cursorPosition) + insertionText[i];
            rightText = fullText.substring(cursorPosition);
            fullText = leftText + rightText;
            cursorPosition++;
          });
        }

        // update all the words indices after this insertion words
        int increment = rightWord.length + 1; // plus 1 for the space.
        wordsIndices[correctWordIndex][1] += increment;
        for (int j = correctWordIndex + 1; j < wordsIndices.length; j++) {
          wordsIndices[j][0] += increment;
          wordsIndices[j][1] += increment;
        }
      } else if (actions[i][0] == "delete") {
        // Delete the word character by character
        int correctWordIndex = actions[i][1];
        int startingIndex = wordsIndices[correctWordIndex][0];
        int endingIndex = wordsIndices[correctWordIndex][1];

        int wrongWordLength = endingIndex - startingIndex;

        // int wordToDeleteEndIndex = endingIndex + cumulativeIndex;
        int wordToDeleteEndIndex = endingIndex + cumulates[sIndex];
        await _moveCursor(wordToDeleteEndIndex);

        int increment = 0;
        for (int j = wrongWordLength; j > 0; j--) {
          await Future.delayed(Duration(milliseconds: deletionSpeed));
          setState(() {
            leftText = leftText.substring(0, leftText.length - 1);
            fullText = leftText + rightText;
            cursorPosition--;
          });
          increment--;
        }

        wordsIndices[correctWordIndex][1] += increment;

        if ((leftText.length > 0) && (leftText[leftText.length - 1] == " ")) {
          await Future.delayed(Duration(milliseconds: deletionSpeed));
          setState(() {
            leftText = leftText.substring(0, leftText.length - 1);
            fullText = leftText + rightText;
            cursorPosition--;
          });
          increment--;
        }

        // update all the words indices after this insertion words
        // int increment = -(wrongWordLength + 1); // plus 1 for the space.

        for (int j = correctWordIndex + 1; j < wordsIndices.length; j++) {
          wordsIndices[j][0] += increment;
          wordsIndices[j][1] += increment;
        }
      } else if (actions[i][0] == "replace") {
        // Delete the word character by character
        int correctWordIndex = actions[i][1];
        String rightWord = actions[i][2];
        int startingIndex = wordsIndices[correctWordIndex][0];
        int endingIndex = wordsIndices[correctWordIndex][1];

        int wrongWordLength = endingIndex - startingIndex;

        // int wordToDeleteEndIndex = endingIndex + cumulativeIndex;
        int wordToDeleteEndIndex = endingIndex + cumulates[sIndex];
        await _moveCursor(wordToDeleteEndIndex);

        int increment = 0;
        for (int j = wrongWordLength; j > 0; j--) {
          await Future.delayed(Duration(milliseconds: deletionSpeed));
          setState(() {
            leftText = leftText.substring(0, leftText.length - 1);
            fullText = leftText + rightText;
            cursorPosition--;
          });
          increment--;
        }
        if (leftText[leftText.length - 1] == " ") {
          await Future.delayed(Duration(milliseconds: deletionSpeed));
          setState(() {
            leftText = leftText.substring(0, leftText.length - 1);
            fullText = leftText + rightText;
            cursorPosition--;
          });
          increment--;
        }
        // Display the "inserty " text

        // move to the end of "space", right before the next word
        if (fullText.length != leftText.length) {
          await Future.delayed(Duration(milliseconds: cursorMovingSpeed));

          setState(() {
            leftText = fullText.substring(0, leftText.length + 1);
            rightText = rightText.substring(1);
            fullText = leftText + rightText;
            cursorPosition++;
          });
        } else {
          setState(() {
            leftText = leftText + ' ';
            fullText = leftText + rightText;
            cursorPosition++;
          });
        }
        // start to insert the right word
        String insertionText = rightWord;
        insertionText = insertionText.trim() + ' ';

        for (int i = 0; i < insertionText.length; i++) {
          await Future.delayed(Duration(
              milliseconds:
                  (characterLagTime * TypingSpeed.generateRandomNumber())
                      .toInt()));

          setState(() {
            leftText = fullText.substring(0, cursorPosition) + insertionText[i];
            rightText = fullText.substring(cursorPosition);
            fullText = leftText + rightText;
            cursorPosition++;
          });
        }

        // update all the words indices after this insertion words
        increment += rightWord.length + 1; // plus 1 for the space.
        wordsIndices[correctWordIndex][1] += increment;
        for (int j = correctWordIndex + 1; j < wordsIndices.length; j++) {
          wordsIndices[j][0] += increment;
          wordsIndices[j][1] += increment;
        }
      } else if (actions[i][0] == "typo") {
        int correctWordIndex = actions[i][1];
        int wordEndingIndex = wordsIndices[correctWordIndex][1];

        Map typoInfo = actions[i][2];
        int targetCharIndex = typoInfo["index"];
        String word = typoInfo["wrong"];

        // await _moveCursor(wordEndingIndex + cumulativeIndex);
        await _moveCursor(wordEndingIndex + cumulates[sIndex]);
        if (typoInfo["action"] == "add") {
          TypoCorrector.add(
              word: word,
              rightText: rightText,
              leftText: leftText,
              fullText: fullText,
              cursorPosition: cursorPosition,
              targetCharIndex: targetCharIndex,
              typoInfo: typoInfo,
              correctWordIndex: correctWordIndex,
              cursorMovingSpeed: cursorMovingSpeed,
              characterLagTime: characterLagTime,
              stateUpdateCallback: updateState);

          // update all the words indices after this insertion words
          int increment = 1; // added 1
          wordsIndices[correctWordIndex][1] += increment;
          for (int j = correctWordIndex + 1; j < wordsIndices.length; j++) {
            wordsIndices[j][0] += increment;
            wordsIndices[j][1] += increment;
          }
        } else if (typoInfo["action"] == "remove") {
          TypoCorrector.remove(
              word: word,
              rightText: rightText,
              leftText: leftText,
              fullText: fullText,
              cursorPosition: cursorPosition,
              targetCharIndex: targetCharIndex,
              typoInfo: typoInfo,
              correctWordIndex: correctWordIndex,
              cursorMovingSpeed: cursorMovingSpeed,
              characterLagTime: characterLagTime,
              stateUpdateCallback: updateState);
          // update all the words indices after this insertion words
          int increment = -1; // added 1
          wordsIndices[correctWordIndex][1] += increment;
          for (int j = correctWordIndex + 1; j < wordsIndices.length; j++) {
            wordsIndices[j][0] += increment;
            wordsIndices[j][1] += increment;
          }
        } else if (typoInfo["action"] == "swap") {
          TypoCorrector.swap(
              word: word,
              rightText: rightText,
              leftText: leftText,
              fullText: fullText,
              cursorPosition: cursorPosition,
              targetCharIndex: targetCharIndex,
              typoInfo: typoInfo,
              correctWordIndex: correctWordIndex,
              cursorMovingSpeed: cursorMovingSpeed,
              characterLagTime: characterLagTime,
              stateUpdateCallback: updateState);
        }
      }
    }

    isInsertionFinished = true;
  }

  Future<void> _moveCursor(int desiredCursorPos) async {
    isCursorMovingFinished = false;
    while (cursorPosition != desiredCursorPos) {
      // print("cursorPosition = $cursorPosition");

      await Future.delayed(Duration(
          milliseconds: (cursorMovingSpeed * TypingSpeed.generateRandomNumber())
              .toInt()));
      setState(() {
        if (desiredCursorPos > fullText.length) {
          desiredCursorPos = fullText.length;
        }
        if (cursorPosition > desiredCursorPos) {
          cursorPosition--;
        } else if (cursorPosition < desiredCursorPos) {
          cursorPosition++;
        }
        leftText = fullText.substring(0, cursorPosition);
        rightText = fullText.substring(cursorPosition);
        fullText = leftText + rightText;
        // cursorPosition = cursorPosition + step;
      });

      if (cursorPosition == desiredCursorPos) {
        break;
      }
    }

    isCursorMovingFinished = true;
  }

  Future<void> _performBackSpaceBehavior(int startingIndex) async {
    isBackSpaceFinished = false;

    await _moveCursor(startingIndex + 1);

    // Delete the displayed text character by character in reverse order
    for (int i = leftText.length - 1; i >= 0; i--) {
      await Future.delayed(Duration(milliseconds: deletionSpeed));
      setState(() {
        leftText = leftText.substring(0, i);
        fullText = leftText + rightText;
        cursorPosition--;
      });
    }

    isBackSpaceFinished = true;
  }

  @override
  Widget build(BuildContext context) {
    return RichText(
        text: TextSpan(
      children: [
        TextSpan(
            text: leftText,
            style: const TextStyle(fontSize: 14, color: Colors.white)),
        WidgetSpan(
          child: AnimatedOpacity(
            opacity: showCursor ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 0),
            child: const Text(
              '|',
              style: TextStyle(fontSize: 14, color: Colors.blueGrey),
            ),
          ),
        ),
        TextSpan(
            text: rightText,
            style: const TextStyle(fontSize: 14, color: Colors.white)),
      ],
    ));
  }
}
