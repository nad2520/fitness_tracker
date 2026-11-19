import 'package:flutter_test/flutter_test.dart';
import 'package:fitness_tracker/main.dart';

void main() {
  testWidgets('The welcome page is shown', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('FitTrack'), findsOneWidget);
    expect(find.text('Get Started'), findsOneWidget);
  });
}
