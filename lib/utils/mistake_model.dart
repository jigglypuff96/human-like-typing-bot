typedef StateUpdateCallback = void Function(
  String leftText,
  String rightText,
  String fullText,
  int cursorPosition,
);

abstract class TypoCorrector {
  static void add({
    required String word,
    required String rightText,
    required leftText,
    required fullText,
    required cursorPosition,
    required targetCharIndex,
    required Map<dynamic, dynamic> typoInfo,
    required int correctWordIndex,
    required int cursorMovingSpeed,
    required int characterLagTime,
    required StateUpdateCallback stateUpdateCallback,
  }) async {
    // if (typoInfo["action"] == "add") {
    for (int j = word.length - 1; j >= targetCharIndex; j--) {
      await Future.delayed(Duration(milliseconds: cursorMovingSpeed));
      rightText = leftText[leftText.length - 1] + rightText;
      leftText = leftText.substring(0, leftText.length - 1);
      fullText = leftText + rightText;
      cursorPosition--;
      stateUpdateCallback(leftText, rightText, fullText, cursorPosition);
    }

    await Future.delayed(Duration(milliseconds: characterLagTime));
    leftText = leftText + typoInfo["char"];
    fullText = leftText + rightText;
    cursorPosition++;
    stateUpdateCallback(leftText, rightText, fullText, cursorPosition);
  }

  static void remove({
    required String word,
    required String rightText,
    required leftText,
    required fullText,
    required cursorPosition,
    required targetCharIndex,
    required Map<dynamic, dynamic> typoInfo,
    required int correctWordIndex,
    required int cursorMovingSpeed,
    required int characterLagTime,
    required StateUpdateCallback stateUpdateCallback,
  }) async {
    for (int j = word.length - 1; j > targetCharIndex; j--) {
      await Future.delayed(Duration(milliseconds: cursorMovingSpeed));
      rightText = leftText[leftText.length - 1] + rightText;
      leftText = leftText.substring(0, leftText.length - 1);
      fullText = leftText + rightText;
      cursorPosition--;
      stateUpdateCallback(leftText, rightText, fullText, cursorPosition);
    }
    await Future.delayed(Duration(milliseconds: characterLagTime));
    leftText = leftText.substring(0, leftText.length - 1);
    fullText = leftText + rightText;
    cursorPosition--;
    stateUpdateCallback(leftText, rightText, fullText, cursorPosition);
  }

  static void swap({
    required String word,
    required String rightText,
    required leftText,
    required fullText,
    required cursorPosition,
    required targetCharIndex,
    required Map<dynamic, dynamic> typoInfo,
    required int correctWordIndex,
    required int cursorMovingSpeed,
    required int characterLagTime,
    required StateUpdateCallback stateUpdateCallback,
  }) async {
    String characterToSwap = typoInfo["char"];
    for (int j = word.length - 1; j > targetCharIndex; j--) {
      await Future.delayed(Duration(milliseconds: cursorMovingSpeed));
      rightText = leftText[leftText.length - 1] + rightText;
      leftText = leftText.substring(0, leftText.length - 1);
      fullText = leftText + rightText;
      cursorPosition--;
      stateUpdateCallback(leftText, rightText, fullText, cursorPosition);
    }
    // remove that character
    await Future.delayed(Duration(milliseconds: characterLagTime));
    leftText = leftText.substring(0, leftText.length - 1);
    fullText = leftText + rightText;
    cursorPosition--;
    stateUpdateCallback(leftText, rightText, fullText, cursorPosition);
    // move cursor to right for one index
    await Future.delayed(Duration(milliseconds: characterLagTime));
    leftText = leftText + rightText.substring(0, 1);
    rightText = rightText.substring(1);
    fullText = leftText + rightText;
    cursorPosition++;
    stateUpdateCallback(leftText, rightText, fullText, cursorPosition);
    // insert the character
    await Future.delayed(Duration(milliseconds: characterLagTime));
    leftText = leftText + characterToSwap;
    fullText = leftText + rightText;
    cursorPosition++;
    stateUpdateCallback(leftText, rightText, fullText, cursorPosition);
  }
}
