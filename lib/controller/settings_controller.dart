import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// Create a class for the settings controller using ChangeNotifier
class SettingsController extends ChangeNotifier {
  double _characterPace = 100;
  double _wordDeletionRate = 0.2;
  double _replacementRate = 0.1;
  double _wordInsertionRate = 0.1;
  double _typoRate = 0.1;
  double _wordModificationRate = 0.2;

  double _sentenceDeletionRate = 0.1;
  double _sentenceInsertionRate = 0.1;
  double _sentenceModificationRate = 0.2;

  double _characterDeletionRate = 0.1;
  double _characterInsertionRate = 0.1;
  double _characterModificationRate = 0.1;

  // double _sentenceDeletionRate = 0.1;
  // double _sentenceInsertionRate = 0.1;
  // double _sentenceModificationRate = 0.2;

  String _thinkingTime = '3';
  double _hesitationWordsRate = 0.05;
  double _hesitationTime = 400;

  String _sentenceLimit = '4';
  String _wordsLimit = '30';
  // String gender = 'boy';
  // bool isLeftHanded = false;
  double get characterPace => _characterPace;
  double get wordDeletionRate => _wordDeletionRate;
  double get replacementRate => _replacementRate;
  double get wordInsertionRate => _wordInsertionRate;
  double get typoRate => _typoRate;
  double get wordModificationRate => _wordModificationRate;

  double get sentenceDeletionRate => _sentenceDeletionRate;
  double get sentenceInsertionRate => _sentenceInsertionRate;
  double get sentenceModificationRate => _sentenceModificationRate;

  double get characterDeletionRate => _characterDeletionRate;
  double get characterInsertionRate => _characterInsertionRate;
  double get characterModificationRate => _characterModificationRate;

  String get thinkingTime => _thinkingTime;
  double get hesitationWordsRate => _hesitationWordsRate;
  double get hesitationTime => _hesitationTime;

  String get sentenceLimit => _sentenceLimit;
  String get wordsLimit => _wordsLimit;
  // Update the character pace value
  void updateCharacterPace(double value) {
    _characterPace = value;
    notifyListeners();
  }

  // Update the insertion rate value
  void updateTypoRate(double value) {
    _typoRate = value;
    notifyListeners();
  }

  // Update the replacement rate value
  void updateReplacementRate(double value) {
    _replacementRate = value;
    notifyListeners();
  }

  // Update the deletion rate value
  void updateWordDeletionRate(double value) {
    _wordDeletionRate = value;
    notifyListeners();
  }

  // Update the insertion rate value
  void updateWordInsertionRate(double value) {
    _wordInsertionRate = value;
    notifyListeners();
  }

  // Update the insertion rate value
  void updateWordModificationRate(double value) {
    _wordModificationRate = value;
    notifyListeners();
  }

  // Update the deletion rate value
  void updateSentenceDeletionRate(double value) {
    _sentenceDeletionRate = value;
    notifyListeners();
  }

  // Update the insertion rate value
  void updateSentenceInsertionRate(double value) {
    _sentenceInsertionRate = value;
    notifyListeners();
  }

  // Update the insertion rate value
  void updateSentenceModificationRate(double value) {
    _sentenceModificationRate = value;
    notifyListeners();
  }

  // Update the deletion rate value
  void updateCharacterDeletionRate(double value) {
    _characterDeletionRate = value;
    notifyListeners();
  }

  // Update the insertion rate value
  void updateCharacterInsertionRate(double value) {
    _characterInsertionRate = value;
    notifyListeners();
  }

  // Update the insertion rate value
  void updateCharacterModificationRate(double value) {
    _characterModificationRate = value;
    notifyListeners();
  }

  // Update the user input value
  void updateThinkingTime(String value) {
    _thinkingTime = value;
    notifyListeners();
  }

// Update the user input value
  void updateHesitationWordsRate(double value) {
    _hesitationWordsRate = value;
    notifyListeners();
  }

  // Update the user input value
  void updateHesitationTime(double value) {
    _hesitationTime = value;
    notifyListeners();
  }

  // Update the user input value
  void updateSentenceLimit(String value) {
    _sentenceLimit = value;
    notifyListeners();
  }

  // Update the user input value
  void updateWordsLimit(String value) {
    _wordsLimit = value;
    notifyListeners();
  }

  void resetToMinimumValues() {
    _characterPace = 0;
    _wordDeletionRate = 0.0;
    _replacementRate = 0.0;
    _wordInsertionRate = 0.0;
    _typoRate = 0.0;
    _wordModificationRate = 0.0;

    _sentenceDeletionRate = 0.0;
    _sentenceInsertionRate = 0.0;
    _sentenceModificationRate = 0.0;

    _characterDeletionRate = 0.0;
    _characterInsertionRate = 0.0;
    _characterModificationRate = 0.0;

    _thinkingTime = '0';
    _hesitationWordsRate = 0.0;
    _hesitationTime = 0;

    _sentenceLimit = '1';
    _wordsLimit = '20';

    notifyListeners();
  }
}
