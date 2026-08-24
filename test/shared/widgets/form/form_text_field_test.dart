import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hatchmobile/shared/widgets/form/form_text_field.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

  TextField textField(WidgetTester tester) => tester.widget<TextField>(find.byType(TextField));

  group('FormTextField isPassword', () {
    testWidgets('starts obscured and shows the eye-off icon', (tester) async {
      await tester.pumpWidget(
        wrap(
          FormTextField(
            label: 'Password',
            isPassword: true,
            controller: TextEditingController(),
          ),
        ),
      );

      expect(textField(tester).obscureText, isTrue);
      expect(find.byIcon(Icons.visibility_off), findsOneWidget);
      expect(find.byIcon(Icons.visibility), findsNothing);
    });

    testWidgets('tapping the eye icon reveals the text', (tester) async {
      await tester.pumpWidget(
        wrap(
          FormTextField(
            label: 'Password',
            isPassword: true,
            controller: TextEditingController(),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.visibility_off));
      await tester.pump();

      expect(textField(tester).obscureText, isFalse);
      expect(find.byIcon(Icons.visibility), findsOneWidget);
      expect(find.byIcon(Icons.visibility_off), findsNothing);
    });

    testWidgets('tapping again re-hides the text', (tester) async {
      await tester.pumpWidget(
        wrap(
          FormTextField(
            label: 'Password',
            isPassword: true,
            controller: TextEditingController(),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.visibility_off));
      await tester.pump();
      await tester.tap(find.byIcon(Icons.visibility));
      await tester.pump();

      expect(textField(tester).obscureText, isTrue);
      expect(find.byIcon(Icons.visibility_off), findsOneWidget);
    });

    testWidgets('does not render an eye icon when isPassword is false', (tester) async {
      await tester.pumpWidget(
        wrap(
          FormTextField(
            label: 'Username',
            controller: TextEditingController(),
          ),
        ),
      );

      expect(find.byIcon(Icons.visibility), findsNothing);
      expect(find.byIcon(Icons.visibility_off), findsNothing);
      expect(textField(tester).obscureText, isFalse);
    });

    testWidgets('isObscure still obscures text when isPassword is false', (tester) async {
      await tester.pumpWidget(
        wrap(
          FormTextField(
            label: 'Secret',
            isObscure: true,
            controller: TextEditingController(),
          ),
        ),
      );

      expect(textField(tester).obscureText, isTrue);
      expect(find.byIcon(Icons.visibility), findsNothing);
      expect(find.byIcon(Icons.visibility_off), findsNothing);
    });
  });
}
