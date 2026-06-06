import 'package:flutter_test/flutter_test.dart';
import 'package:project_mobprog/app.dart';

void main() {
  testWidgets('App loads successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Duta Kampus Mobile'), findsNothing);
  });
}