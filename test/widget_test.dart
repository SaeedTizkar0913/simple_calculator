// A basic widget test for the calculator.
//
// It builds the app, taps some buttons, and checks
// that the math works like it should.

import 'package:flutter_test/flutter_test.dart';

import 'package:simple_calculator/main.dart';

void main() {
  testWidgets('Calculator adds two numbers', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const CalculatorApp());

    // Type 7 + 3 =. We pump after each tap so the display updates.
    await tester.tap(find.text('7'));
    await tester.pump();
    await tester.tap(find.text('+'));
    await tester.pump();
    await tester.tap(find.text('3'));
    await tester.pump();
    await tester.tap(find.text('='));
    await tester.pump();

    // The display should now show 10.
    expect(find.text('10'), findsOneWidget);
  });

  testWidgets('Back button removes the last character',
      (WidgetTester tester) async {
    await tester.pumpWidget(const CalculatorApp());

    // Type 75.
    await tester.tap(find.text('7'));
    await tester.pump();
    await tester.tap(find.text('5'));
    await tester.pump();

    // Press back twice: "75" -> "7" -> "0".
    await tester.tap(find.text('<'));
    await tester.pump();
    await tester.tap(find.text('<'));
    await tester.pump();

    // "75" should be gone from the display.
    expect(find.text('75'), findsNothing);
  });

  testWidgets('Back button removes a whole list item when it gets empty',
      (WidgetTester tester) async {
    await tester.pumpWidget(const CalculatorApp());

    // Type 5 + 3. Press back once: the '3' becomes the starting 0.
    await tester.tap(find.text('5'));
    await tester.pump();
    await tester.tap(find.text('+'));
    await tester.pump();
    await tester.tap(find.text('3'));
    await tester.pump();
    await tester.tap(find.text('<'));
    await tester.pump();

    // Now press back again: it should remove the '+' item from the list.
    await tester.tap(find.text('<'));
    await tester.pump();

    // The list item is gone and the display is back to "5".
    // Pressing digits from here glues onto the 5, like in a real
    // calculator, so we press + again and type the new number.
    await tester.tap(find.text('+'));
    await tester.pump();
    await tester.tap(find.text('7'));
    await tester.pump();
    await tester.tap(find.text('='));
    await tester.pump();

    // 5 + 7 = 12.
    expect(find.text('12'), findsOneWidget);
  });

  testWidgets('Multiplication happens before addition',
      (WidgetTester tester) async {
    await tester.pumpWidget(const CalculatorApp());

    // Type 2 + 3 * 4 =. We pump after each tap so the display updates.
    await tester.tap(find.text('2'));
    await tester.pump();
    await tester.tap(find.text('+'));
    await tester.pump();
    await tester.tap(find.text('3'));
    await tester.pump();
    await tester.tap(find.text('*'));
    await tester.pump();
    await tester.tap(find.text('4'));
    await tester.pump();
    await tester.tap(find.text('='));
    await tester.pump();

    // 2 + 3 * 4 = 14 (not 20, because * comes before +).
    expect(find.text('14'), findsOneWidget);
  });

  testWidgets('Calculator shows Error when dividing by zero',
      (WidgetTester tester) async {
    await tester.pumpWidget(const CalculatorApp());

    // Type 5 / 0 =.
    await tester.tap(find.text('5'));
    await tester.pump();
    await tester.tap(find.text('/'));
    await tester.pump();
    await tester.tap(find.text('0'));
    await tester.pump();
    await tester.tap(find.text('='));
    await tester.pump();

    // The display should show the error.
    expect(find.text('Error'), findsOneWidget);
  });
}
