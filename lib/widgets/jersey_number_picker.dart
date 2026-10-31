import 'dart:math';

import 'package:flutter/material.dart';

class JerseyNumberPicker {
  static Future<int?> show({
    required BuildContext context,
    required Set<int> takenNumbers,
    int preferredNumber = 10,
    int playerOverall = 60,
    bool english = false,
  }) {
    final availableNumbers = List<int>.generate(99, (index) => index + 1)
      ..removeWhere(takenNumbers.contains);

    if (availableNumbers.isEmpty) {
      return Future<int?>.value(null);
    }

    final random = Random();
    final choices = <int>[];
    final prestigeNumbers = [7, 9, 10, 11, 8, 1]
        .where(availableNumbers.contains)
        .toList()
      ..shuffle(random);

    final prestigeCount = playerOverall >= 88
        ? 2
        : playerOverall >= 78
        ? 1
        : random.nextDouble() < 0.25
        ? 1
        : 0;

    if (availableNumbers.contains(preferredNumber)) {
      choices.add(preferredNumber);
    }
    final targetPrestigeCount = prestigeCount +
        (choices.contains(preferredNumber) ? 1 : 0);
    for (final number in prestigeNumbers) {
      if (choices.length >= targetPrestigeCount) break;
      if (!choices.contains(number)) choices.add(number);
    }

    final remaining = availableNumbers.where((n) => !choices.contains(n)).toList()
      ..shuffle(random);
    while (choices.length < 4 && remaining.isNotEmpty) {
      choices.add(remaining.removeAt(0));
    }
    choices.shuffle(random);
    final initialNumber = choices.contains(preferredNumber)
        ? preferredNumber
        : choices.first;

    return showDialog<int>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF0B2A12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFF347644)),
        ),
        title: Text(
          english ? 'CHOOSE YOUR NUMBER' : 'ВЫБЕРИ ИГРОВОЙ НОМЕР',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w900,
          ),
        ),
        content: SizedBox(
          width: 340,
          height: 340,
          child: GridView.builder(
            itemCount: choices.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 1.15,
            ),
            itemBuilder: (context, index) {
              final number = choices[index];
              final isPreferred = number == initialNumber;
              return Material(
                color: isPreferred
                    ? const Color(0xFF286638)
                    : const Color(0xFF123A1D),
                borderRadius: BorderRadius.circular(11),
                child: InkWell(
                  borderRadius: BorderRadius.circular(11),
                  onTap: () => Navigator.pop(dialogContext, number),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(11),
                      border: Border.all(
                        color: isPreferred
                            ? const Color(0xFF8BE07F)
                            : const Color(0xFF24552C),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '$number',
                      style: TextStyle(
                        color: isPreferred
                            ? const Color(0xFFB8FFAA)
                            : Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              english ? 'CANCEL' : 'ОТМЕНА',
              style: const TextStyle(color: Colors.white60),
            ),
          ),
        ],
      ),
    );
  }
}
