import 'package:human_like_typing_bot/controller/settings_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // print("building settings page...");
    final settingsController = Provider.of<SettingsController>(context);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                  height: 25,
                  child: const Text("Hesitation",
                      style: TextStyle(
                        fontWeight: FontWeight.bold, // Apply bold style
                        decoration: TextDecoration.underline,
                      ))),

              Container(
                height: 25,
                child: Slider(
                  value: settingsController.characterPace,
                  min: 0,
                  max: 1000,
                  onChanged: (value) {
                    settingsController.updateCharacterPace(value);
                  },
                ),
              ),
              Text(
                  'Average speed (ms): ${settingsController.characterPace.toStringAsFixed(2)}'),
              const SizedBox(height: 5.0),

              Container(
                height: 25,
                child: Slider(
                  value: settingsController.hesitationWordsRate,
                  min: 0,
                  max: 0.5,
                  onChanged: (value) {
                    settingsController.updateHesitationWordsRate(value);
                  },
                ),
              ),
              Text(
                  'Pause rate (%): ${settingsController.hesitationWordsRate.toStringAsFixed(2)}'),
              const SizedBox(height: 5.0),

              Container(
                height: 25,
                child: Slider(
                  value: settingsController.hesitationTime,
                  min: 0,
                  max: 1000,
                  onChanged: (value) {
                    settingsController.updateHesitationTime(value);
                  },
                ),
              ),
              Text(
                  'Thinking time (ms): ${settingsController.hesitationTime.toStringAsFixed(2)}'),
              const SizedBox(height: 10.0),

              Container(
                height: 5, // Set the desired height for the separator
                color: Colors.grey, // Set the color of the separator
              ),
              const SizedBox(height: 10.0),
              Container(
                  height: 25,
                  child: const Text("Self-editing",
                      style: TextStyle(
                        fontWeight: FontWeight.bold, // Apply bold style
                        decoration: TextDecoration.underline,
                      ))),
              // Params: Lag - typing speed per character
              // sentence - layer
              Container(
                height: 2, // Set the desired height for the separator
                color: Colors.blueGrey, // Set the color of the separator
              ),
              Container(
                  height: 15,
                  child: const Text("Sentence Layer",
                      style: TextStyle(
                        fontStyle: FontStyle.italic, // Apply bold style
                      ))),
              Container(
                height: 25,
                child: Slider(
                  value: settingsController.sentenceDeletionRate,
                  min: 0.0,
                  max: 1.0,
                  onChanged: (value) {
                    settingsController.updateSentenceDeletionRate(value);
                  },
                ),
              ),
              Text(
                  'Deletion rate (%): ${settingsController.sentenceDeletionRate.toStringAsFixed(2)}'),
              const SizedBox(height: 5.0),
              // params: deletion rate
              // params: insertion rate
              Container(
                height: 25,
                child: Slider(
                  value: settingsController.sentenceInsertionRate,
                  min: 0.0,
                  max: 1.0,
                  onChanged: (value) {
                    settingsController.updateSentenceInsertionRate(value);
                  },
                ),
              ),
              Text(
                  'Insertion rate (%): ${settingsController.sentenceInsertionRate.toStringAsFixed(2)}'),
              const SizedBox(height: 5.0),

              Container(
                height: 25,
                child: Slider(
                  value: settingsController.sentenceModificationRate,
                  min: 0.0,
                  max: 1.0,
                  onChanged: (value) {
                    settingsController.updateSentenceModificationRate(value);
                  },
                ),
              ),
              Text(
                  'Modification rate (%): ${settingsController.sentenceModificationRate.toStringAsFixed(2)}'),
              const SizedBox(height: 5.0),

              // word - layer
              Container(
                height: 2, // Set the desired height for the separator
                color: Colors.blueGrey, // Set the color of the separator
              ),
              Container(
                  height: 15,
                  child: const Text("Word Layer",
                      style: TextStyle(
                        fontStyle: FontStyle.italic, // Apply bold style
                      ))),
              Container(
                height: 25,
                child: Slider(
                  value: settingsController.wordDeletionRate,
                  min: 0.0,
                  max: 1.0,
                  onChanged: (value) {
                    settingsController.updateWordDeletionRate(value);
                  },
                ),
              ),
              Text(
                  'Deletion rate (%): ${settingsController.wordDeletionRate.toStringAsFixed(2)}'),
              const SizedBox(height: 5.0),
              // params: deletion rate
              // params: insertion rate
              Container(
                height: 25,
                child: Slider(
                  value: settingsController.wordInsertionRate,
                  min: 0.0,
                  max: 1.0,
                  onChanged: (value) {
                    settingsController.updateWordInsertionRate(value);
                  },
                ),
              ),
              Text(
                  'Insertion rate (%): ${settingsController.wordInsertionRate.toStringAsFixed(2)}'),
              const SizedBox(height: 5.0),

              Container(
                height: 25,
                child: Slider(
                  value: settingsController.wordModificationRate,
                  min: 0.0,
                  max: 1.0,
                  onChanged: (value) {
                    settingsController.updateWordModificationRate(value);
                  },
                ),
              ),
              Text(
                  'Modification rate (%): ${settingsController.wordModificationRate.toStringAsFixed(2)}'),
              const SizedBox(height: 5.0),

              // character - layer
              Container(
                height: 2, // Set the desired height for the separator
                color: Colors.blueGrey, // Set the color of the separator
              ),
              Container(
                  height: 15,
                  child: const Text("Character Layer",
                      style: TextStyle(
                        fontStyle: FontStyle.italic, // Apply bold style
                      ))),
              Container(
                height: 25,
                child: Slider(
                  value: settingsController.characterDeletionRate,
                  min: 0.0,
                  max: 1.0,
                  onChanged: (value) {
                    settingsController.updateCharacterDeletionRate(value);
                  },
                ),
              ),
              Text(
                  'Deletion rate (%): ${settingsController.characterDeletionRate.toStringAsFixed(2)}'),
              const SizedBox(height: 5.0),
              // params: deletion rate
              // params: insertion rate
              Container(
                height: 25,
                child: Slider(
                  value: settingsController.characterInsertionRate,
                  min: 0.0,
                  max: 1.0,
                  onChanged: (value) {
                    settingsController.updateCharacterInsertionRate(value);
                  },
                ),
              ),
              Text(
                  'Insertion rate (%): ${settingsController.characterInsertionRate.toStringAsFixed(2)}'),
              const SizedBox(height: 5.0),

              Container(
                height: 25,
                child: Slider(
                  value: settingsController.characterModificationRate,
                  min: 0.0,
                  max: 1.0,
                  onChanged: (value) {
                    settingsController.updateCharacterModificationRate(value);
                  },
                ),
              ),
              Text(
                  'Modification rate (%): ${settingsController.characterModificationRate.toStringAsFixed(2)}'),
              const SizedBox(height: 5.0),

              Container(
                height: 5, // Set the desired height for the separator
                color: Colors.grey, // Set the color of the separator
              ),
              const SizedBox(height: 10.0),
              Container(
                  height: 25,
                  child: const Text("API-service",
                      style: TextStyle(
                        fontWeight: FontWeight.bold, // Apply bold style
                        decoration: TextDecoration.underline,
                      ))),
              Row(
                children: [
                  const Text('Response sentence limit: '),
                  const SizedBox(width: 10),
                  DropdownButton<String>(
                    value: '${settingsController.sentenceLimit}',
                    onChanged: (value) {
                      settingsController.updateSentenceLimit(value!);
                    },
                    items: ['1', '2', '3', '4', '5', '6', '7']
                        .map((value) => DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            ))
                        .toList(),
                  ),
                  const SizedBox(width: 10),
                ],
              ),

              Row(
                children: [
                  const Text('Response words limit: '),
                  const SizedBox(width: 10),
                  DropdownButton<String>(
                    value: '${settingsController.wordsLimit}',
                    onChanged: (value) {
                      settingsController.updateWordsLimit(value!);
                    },
                    items: ['10', '20', '30', '40', '50', '60', '70']
                        .map((value) => DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            ))
                        .toList(),
                  ),
                  const SizedBox(width: 10),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      // Reset all settings parameters to their minimum values
                      settingsController.resetToMinimumValues();

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Settings Reset!'),
                          duration: Duration(
                              milliseconds: 500), // Set the desired duration
                        ),
                      );
                    },
                    icon: const Icon(Icons.restore),
                    label: const Text('Reset'),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Settings Applied!'),
                          duration: Duration(milliseconds: 500),
                        ),
                      );
                    },
                    icon: const Icon(Icons.check),
                    label: const Text('Apply'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
