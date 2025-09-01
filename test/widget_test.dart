// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:number_guessing_game/main.dart';

void main() {
  testWidgets('App starts successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const NumberGuessingGameApp());

    // Verify that our app title is displayed
    expect(find.text('Number Guessing Game'), findsOneWidget);
    
    // Verify that game mode options are present
    expect(find.text('Single Player'), findsOneWidget);
    expect(find.text('Two Players'), findsOneWidget);
  });
}
