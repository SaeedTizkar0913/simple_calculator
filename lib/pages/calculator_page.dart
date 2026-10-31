import 'package:flutter/material.dart';

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  // The number the user is currently typing (for example "7" or "12").
  String currentNumber = '0';

  // This list stores everything the user pressed so far,
  // finished numbers and operators, in the order they were pressed.
  // Example: user typed 5, pressed +, typed 3 -> the list holds ['5', '+']
  List<String> pressedItems = [];

  // Called when the user taps a number button (0-9).
  void pressNumber(String number) {
    setState(() {
      // When the display shows the starting '0' or an error,
      // replace it instead of adding to it (so we never get "07").
      if (currentNumber == '0' || currentNumber == 'Error') {
        currentNumber = number;
      } else {
        // Glue the new digit onto the number being typed: "1" + "2" -> "12".
        currentNumber = currentNumber + number;
      }
    });
  }

  // Called when the user taps an operator button (+, -, *, /).
  void pressOperator(String operator) {
    // Ignore taps while an error is on the screen.
    if (currentNumber == 'Error') return;

    setState(() {
      // Save the finished number, then save the operator.
      pressedItems.add(currentNumber);
      pressedItems.add(operator);

      // Start collecting a new number.
      currentNumber = '0';
    });
  }

  // Called when the user taps the = button. This does the actual math.
  void pressEquals() {
    // Nothing to calculate yet if the list is empty.
    if (pressedItems.isEmpty) return;
    // Ignore taps while an error is on the screen.
    if (currentNumber == 'Error') return;

    setState(() {
      // The last number was still being typed, so save it too.
      // Example: list was ['5', '+'] and currentNumber is '3'.
      pressedItems.add(currentNumber);

      // Division by zero is not possible, so we show an error instead.
      bool dividedByZero = false;

      // The math happens in two steps, so that * and / are done
      // before + and -. That is called operator priority.
      //
      // Step 1 copies the list into a new list, but calculates every
      // * and / right away and puts the result back in.
      // Example: 4 + 2 * 3 becomes 4 + 6.
      List<String> stepTwoItems = [pressedItems[0]];

      int pos = 1;
      while (pos < pressedItems.length) {
        String operator = pressedItems[pos];
        double number = double.parse(pressedItems[pos + 1]);

        if (operator == '*') {
          // Multiply with the number before the operator.
          double previous = double.parse(stepTwoItems.removeLast());
          stepTwoItems.add(resultToText(previous * number));
        } else if (operator == '/') {
          if (number == 0) {
            // Can't divide by zero. Stop calculating and show an error.
            dividedByZero = true;
            break;
          }
          // Divide the number before the operator.
          double previous = double.parse(stepTwoItems.removeLast());
          stepTwoItems.add(resultToText(previous / number));
        } else {
          // + and - have to wait for step 2, so we just copy them over.
          stepTwoItems.add(operator);
          stepTwoItems.add(pressedItems[pos + 1]);
        }

        // Move on to the next operator and the number after it.
        pos += 2;
      }

      // Step 2: now the new list only holds numbers with + and -,
      // which are simply calculated from left to right.
      double result = 0;
      if (!dividedByZero) {
        result = double.parse(stepTwoItems[0]);
        for (int i = 1; i < stepTwoItems.length; i += 2) {
          String operator = stepTwoItems[i];
          double number = double.parse(stepTwoItems[i + 1]);

          if (operator == '+') {
            result = result + number;
          } else if (operator == '-') {
            result = result - number;
          }
        }
      }

      // Show the result (or the error) and empty the list
      // so we are ready for the next calculation.
      if (dividedByZero) {
        currentNumber = 'Error';
      } else {
        currentNumber = resultToText(result);
      }
      pressedItems = [];
    });
  }

  // Turns 10.0 into "10" but keeps 2.5 as "2.5".
  String resultToText(double result) {
    // If the result is a whole number (like 10.0), drop the ".0".
    if (result == result.roundToDouble()) {
      return result.toInt().toString();
    }
    return result.toString();
  }

  // Called when the user taps AC (all clear): forget everything.
  void pressClear() {
    setState(() {
      currentNumber = '0';
      pressedItems = [];
    });
  }

  // Called when the user taps the back button (<).
  // Works like the backspace key: removes one character from the last
  // item shown, and removes the whole item when nothing is left of it.
  void pressBack() {
    setState(() {
      // An error message can not be shortened, so go back to 0 instead.
      if (currentNumber == 'Error') {
        currentNumber = '0';
        return;
      }

      // A number is being typed -> it is the last item shown,
      // so remove its last character. "75" -> "7".
      if (currentNumber != '0') {
        currentNumber = currentNumber.substring(0, currentNumber.length - 1);
        // Nothing left of the number? Then go back to the starting 0.
        if (currentNumber.isEmpty) {
          currentNumber = '0';
        }
        return;
      }

      // No number is being typed -> the last item is in the list.
      if (pressedItems.isNotEmpty) {
        // Take the last item out of the list and shorten it.
        String lastItem = pressedItems.removeLast();
        String remaining = lastItem.substring(0, lastItem.length - 1);

        // Something left of the item (e.g. "12" became "1")?
        // Then put the shortened number back into the list.
        if (remaining.isNotEmpty) {
          pressedItems.add(remaining);
        } else if (pressedItems.isNotEmpty && !isOperator(pressedItems.last)) {
          // We removed a whole item (an operator like "+"). If a number
          // is now the last item in the list, it becomes the number
          // being typed again, so the next digit press continues it.
          currentNumber = pressedItems.removeLast();
        }
        // Nothing left of the item and no number before it?
        // Then it simply stays out of the list, because we removed it.
      }
    });
  }

  // A tiny helper: true when an item is one of the four operators.
  bool isOperator(String item) {
    return item == '+' || item == '-' || item == '*' || item == '/';
  }

  // Builds the text shown on the display.
  String displayText() {
    // Show everything from the list, e.g. "5 + 3".
    String text = pressedItems.join(' ');

    // If the list is empty, only show the number being typed.
    if (text.isEmpty) {
      return currentNumber;
    }
    return '$text $currentNumber';
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          // The display, at the top, with a white background.
          Expanded(
            child: Container(
              width: double.infinity,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.all(16.0),
              child: Text(
                displayText(),
                style: const TextStyle(fontSize: 40, color: Colors.black),
              ),
            ),
          ),

          // The buttons, one row at a time.
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                // AC and < at the top, half a row wide each.
                Row(children: [buildClearButton(), buildBackButton()]),
                Row(
                  children: [
                    buildNumberButton('7'),
                    buildNumberButton('8'),
                    buildNumberButton('9'),
                    buildOperatorButton('/'),
                  ],
                ),
                Row(
                  children: [
                    buildNumberButton('4'),
                    buildNumberButton('5'),
                    buildNumberButton('6'),
                    buildOperatorButton('*'),
                  ],
                ),
                Row(
                  children: [
                    buildNumberButton('1'),
                    buildNumberButton('2'),
                    buildNumberButton('3'),
                    buildOperatorButton('-'),
                  ],
                ),
                // 0 and + at the bottom, half a row wide each.
                Row(
                  children: [buildNumberButton('0'), buildOperatorButton('+')],
                ),
                // = fills the whole last row.
                Row(children: [buildEqualsButton()]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // One small helper makes every button, so we don't copy-paste 15
  // buttons. Expanded makes the button take an equal share of the row.
  // The optional color gives special buttons their own look; when it is
  // left out (like for the number buttons) the default color is kept.
  Widget buildButton(String label, VoidCallback onPressed, {Color? color}) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            // White text on the colored buttons, default color otherwise.
            foregroundColor: color == null ? null : Colors.white,
          ),
          onPressed: onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 15),
            child: Text(label, style: const TextStyle(fontSize: 24)),
          ),
        ),
      ),
    );
  }

  Widget buildNumberButton(String number) {
    return buildButton(number, () => pressNumber(number));
  }

  Widget buildOperatorButton(String operator) {
    return buildButton(
      operator,
      () => pressOperator(operator),
      color: Colors.orange,
    );
  }

  Widget buildEqualsButton() {
    return buildButton('=', pressEquals, color: Colors.green);
  }

  Widget buildClearButton() {
    return buildButton('AC', pressClear, color: Colors.red);
  }

  Widget buildBackButton() {
    return buildButton('<', pressBack, color: Colors.blueGrey);
  }
}
