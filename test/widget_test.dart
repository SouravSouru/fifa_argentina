import 'package:flutter_test/flutter_test.dart';
import 'package:fifa_2026/main.dart';

void main() {
  testWidgets('Argentina app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ArgentinaApp());
    expect(find.byType(ArgentinaApp), findsOneWidget);
  });
}
