import 'package:flutter_test/flutter_test.dart';
import 'package:study_mate/main.dart';

void main() {
  testWidgets('Welcome screen shows the Begin button',
          (WidgetTester tester) async {
        await tester.pumpWidget(const StudyMateApp());

        expect(find.text('Begin'), findsOneWidget);
        expect(find.text('STUDYMATE'), findsOneWidget);
      });
}