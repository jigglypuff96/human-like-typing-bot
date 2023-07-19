import 'dart:math';

class IndexGenerator {
  static Random random = Random();

  static int getRandomInt(int min, int max) {
    // include min and max
    int randomNumber = random.nextInt(max + 1 - min) + min;
    return randomNumber;
  }

  static List<int> getRandomList(int min, int max, int count) {
    // include min and max
    List<int> result = [];
    int i = 0;
    while (i < count) {
      int randomNumber = random.nextInt(max + 1 - min) + min;
      if (!result.contains(randomNumber)) {
        result.add(randomNumber);
        // randomWords.add(words[randomNumber]);
        i++;
      }
    }
    result.sort();
    return result;
  }

  static List<List<int>> getRandomForCategories(
      int min, int max, List<int> counts) {
    // include min and max
    int numOfCategories = counts.length;
    int sumOfIndices =
        counts.fold(0, (previousValue, element) => previousValue + element);
    double tolerance = 0.75; //TODO: come from settins controller
    List<List<int>> result = [];
    if (sumOfIndices > (max - min + 1) * tolerance) {
      return result; //[]
    }
    List<int> allSelected = [];
    for (int i = 0; i < numOfCategories; i++) {
      var count = counts[i];
      List<int> singleCategorySelected = [];
      while (count > 0) {
        int randomNumber = random.nextInt(max + 1 - min) + min;
        if (!allSelected.contains(randomNumber)) {
          allSelected.add(randomNumber);
          singleCategorySelected.add(randomNumber);
          // randomWords.add(words[randomNumber]);
          count--;
        }
      }
      singleCategorySelected.sort();
      result.add(singleCategorySelected);
    }
    return result;
  }
}
